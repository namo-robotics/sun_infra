#!/usr/bin/env python3
"""Render template defaults into an isolated workspace for container smoke tests."""

import json
from pathlib import Path
import re
import shutil


def main():
    """Validate option references and prepare only disposable build artifacts."""
    root = Path(__file__).resolve().parent.parent
    source = root / "src/sun-existing-dockerfile"
    metadata = json.loads((source / "devcontainer-template.json").read_text())
    assert metadata["id"] == source.name
    assert re.fullmatch(r"\d+\.\d+\.\d+", metadata["version"])
    options = metadata["options"]
    destination = root / "build/smoke"
    destination.mkdir(parents=True, exist_ok=True)
    used = set()
    for path in (source / ".devcontainer").rglob("*"):
        if not path.is_file():
            continue
        contents = path.read_text()
        for option in re.findall(r"\$\{templateOption:([^}]+)\}", contents):
            used.add(option)
            contents = contents.replace(
                "${templateOption:" + option + "}", options[option]["default"]
            )
        assert "${templateOption:" not in contents
        output = destination / path.relative_to(source)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(contents)
    assert used == set(options), "Every declared option must be used"
    config = json.loads((destination / ".devcontainer/devcontainer.json").read_text())
    assert config["remoteUser"] == "ubuntu"
    shutil.copyfile(root / "test/Dockerfile", destination / "Dockerfile")
    shutil.copyfile(root / "test/smoke.sh", destination / "smoke.sh")
    print(f"Prepared {destination}")


if __name__ == "__main__":
    main()
