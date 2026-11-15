# python-devcontainer

A personal Python devcontainer image for `linux/amd64` and `linux/arm64`.

```json
{
  "image": "ghcr.io/navan-hassan/python-devcontainer:3.12-trixie",
  "customizations": {
    "vscode": {
      "settings": {
        "python.defaultInterpreterPath": "/home/vscode/.venv/bin/python"
      }
    }
  }
}
```

It includes Python 3.12, uv, and GitHub CLI. A venv is set up at `/home/vscode/.venv`.
