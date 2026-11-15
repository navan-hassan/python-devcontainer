import os
import pwd
import shutil
import subprocess
import sys

VENV = "/home/vscode/.venv"


def main() -> None:
    python_version = sys.version.split()[0]
    print(f"Python {python_version}", flush=True)
    assert sys.version_info[:2] == (3, 12), (
        f"expected Python 3.12, got {python_version}"
    )

    uid = os.getuid()
    user = pwd.getpwuid(uid).pw_name
    assert uid != 0, "running as root"
    assert user == "vscode", f"running as {user} (uid {uid}), expected vscode"

    path_python = shutil.which("python")
    assert path_python == f"{VENV}/bin/python", (
        f"python on PATH is {path_python}, expected {VENV}/bin/python"
    )
    assert sys.prefix == VENV, f"sys.prefix is {sys.prefix}, expected {VENV}"
    assert sys.base_prefix != sys.prefix, (
        "python is not running in a virtual environment"
    )

    for command in (["uv", "--version"], ["uvx", "--version"], ["gh", "--version"]):
        subprocess.run(command, check=True)

    import six

    print(f"six {six.__version__} from {six.__file__}")
    print(f"environment verified as {user} (uid {uid})")


if __name__ == "__main__":
    main()
