# Project Template

Minimal three-tier architecture: Tauri desktop shell → Luster frontend → FastAPI backend.

## Structure

```
.
|-- backend
|   |-- api
|   |-- backend.spec
|   |-- config.py
|   `-- main.py
|-- environment.yml  # filterbank
|-- frontend
|   |-- assets
|   |-- gleam.toml
|   |-- manifest.toml
|   `-- src
|-- justfile
|-- LICENSE.txt
|-- README.md
`-- tauri
    |-- binaries
    |-- build.rs
    |-- src
    `-- tauri.conf.json
```

## Development

### Setup Environment

Using conda (includes Python, Erlang, Gleam, and all dependencies):
```bash
just env-create
conda activate filterbank
just install
```

## Usage with Just

```bash
# First time setup
just setup

# Development (run in separate terminals)
just backend
just frontend-watch
just tauri-dev

# Quality checks
just check
just format

# Production build
just tauri-build
```

## Architecture Notes

- **Tauri**: Handles window, file system, OS integration
- **Luster**: Frontend logic (compiles to WASM)
- **FastAPI**: Business logic, data, external services
- **Gleam/Erlang**: Optional for backend services (included in conda env)
- **CORS**: Configured for `tauri://localhost`

Single return principle, type annotations throughout, minimal dependencies.

