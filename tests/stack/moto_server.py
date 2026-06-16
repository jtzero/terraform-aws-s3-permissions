#!/usr/bin/env python
"""Moto server that validates every ``s3:`` IAM action against the real list.

Moto's built-in IAM policy validation only checks the *shape* of a policy
document -- it happily accepts made-up action names like
``s3:GetObjectPermissionDoesNotExist``.  This launcher closes that gap by
pulling AWS's authoritative action list from Ian Mckay's ``iam-dataset``
project, which tracks the full IAM action surface scraped from AWS docs:

    https://github.com/iann0036/iam-dataset.git  (aws/iam_definition.json)

It then monkeypatches moto's ``IAMPolicyDocumentValidator`` so that any
``s3:`` action which is not in that list causes ``create_policy`` (and friends)
to fail with ``MalformedPolicyDocument`` -- which in turn makes
``terraform apply`` in the stack test fail.  That way the module's action
lists are checked against real AWS S3 actions on every CI run.
"""

import json
import os
import subprocess
import sys

from moto.iam import policy_validation
from moto.iam.exceptions import MalformedPolicyDocument
from moto.server import ThreadedMotoServer

IAM_DATASET_REPO = "https://github.com/iann0036/iam-dataset.git"
IAM_DATASET_BRANCH = "main"
# Path to the action definition file within the repo.
IAM_DEFINITION_PATH = os.path.join("aws", "iam_definition.json")
# Local clone cache, sits next to this script (git-ignored).
CACHE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "iam-dataset")
PORT = int(os.environ.get("MOTO_PORT", "5000"))


def _git(*args: str) -> None:
    subprocess.run(["git", *args], check=True, stdout=subprocess.DEVNULL)


def _ensure_dataset() -> str:
    """Clone/update the iam-dataset repo and return the path to the JSON file.

    Uses a shallow, sparse checkout so only ``aws/iam_definition.json`` is
    fetched rather than the whole (large) repository.  Falls back to a
    previously cached clone if the network is unavailable.
    """
    json_path = os.path.join(CACHE_DIR, IAM_DEFINITION_PATH)
    try:
        if os.path.isdir(os.path.join(CACHE_DIR, ".git")):
            _git("-C", CACHE_DIR, "fetch", "--depth", "1", "origin", IAM_DATASET_BRANCH)
            _git("-C", CACHE_DIR, "reset", "--hard", f"origin/{IAM_DATASET_BRANCH}")
        else:
            _git(
                "clone",
                "--depth", "1",
                "--filter=blob:none",
                "--sparse",
                "--branch", IAM_DATASET_BRANCH,
                IAM_DATASET_REPO,
                CACHE_DIR,
            )
            # Leading slash anchors the pattern to this single file (see the
            # NON-CONE PROBLEMS section of the git-sparse-checkout manual).
            _git(
                "-C", CACHE_DIR,
                "sparse-checkout", "set", "--no-cone",
                "/" + IAM_DEFINITION_PATH.replace(os.sep, "/"),
            )
        return json_path
    except Exception as exc:  # network blip -- fall back to cached copy
        if os.path.exists(json_path):
            sys.stderr.write(f"WARN: using cached iam-dataset ({exc})\n")
            return json_path
        raise


def _valid_s3_actions() -> set[str]:
    """Parse iam_definition.json and return the set of valid s3 actions."""
    json_path = _ensure_dataset()
    with open(json_path, encoding="utf-8") as fh:
        definition = json.load(fh)
    # The file is a list of services, each with a "prefix" and a list of
    # "privileges" (the action names).
    for service in definition:
        if service.get("prefix") == "s3":
            return {
                f"s3:{p['privilege']}".lower() for p in service["privileges"]
            }
    raise RuntimeError("Could not find the s3 service in iam_definition.json")


def _install_s3_action_validation() -> None:
    valid = _valid_s3_actions()
    print(f"Loaded {len(valid)} valid s3 actions from {IAM_DATASET_REPO}", flush=True)

    Validator = policy_validation.IAMPolicyDocumentValidator
    original_validate = Validator.validate

    def validate(self) -> None:
        original_validate(self)
        for statement in self._statements:
            for key in ("Action", "NotAction"):
                actions = statement.get(key, [])
                if isinstance(actions, str):
                    actions = [actions]
                for action in actions:
                    # Only check concrete s3 actions; leave wildcards and
                    # other services to moto's normal handling.
                    if not action.lower().startswith("s3:") or "*" in action:
                        continue
                    if action.lower() not in valid:
                        raise MalformedPolicyDocument(
                            f"'{action}' is not a valid S3 action "
                            f"(not found in {IAM_DATASET_REPO})"
                        )

    Validator.validate = validate


def main() -> None:
    _install_s3_action_validation()
    server = ThreadedMotoServer(port=PORT, verbose=False)
    server.start()
    print(f"Moto server with s3 action validation listening on :{PORT}", flush=True)
    try:
        while True:
            import time

            time.sleep(3600)
    except KeyboardInterrupt:
        server.stop()


if __name__ == "__main__":
    main()
