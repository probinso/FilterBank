# Project Template

Minimal three-tier architecture: Tauri desktop shell → Luster frontend → FastAPI backend.

## Structure

```
├── backend/              # Python FastAPI server
│   ├── api/             # API handlers and routes
│   ├── main.py          # FastAPI app entry
│   ├── config.py        # Settings
│   └── requirements.txt
├── frontend-luster/      # Luster/WASM frontend
│   ├── src/
│   └── Cargo.toml
└── tauri-app/           # Tauri desktop shell
    ├── src-tauri/       # Rust code (minimal)
    └── tauri.conf.json
```

## Development

### Setup Environment

Using conda (includes Python, Erlang, Gleam, and all dependencies):
```bash
just env-create
conda activate project
just install
```

Or manually:
```bash
conda env create -f environment.yml
conda activate project
cd backend && pip install -r requirements.txt
```

### Backend
```bash
cd backend
uvicorn main:app --reload
```

Runs on `http://localhost:8000`

### Frontend
```bash
cd frontend-luster
wasm-pack build --target web
```

### Tauri App
```bash
cd tauri-app
cargo tauri dev
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

## Conda Environment

`environment.yml` includes:
- Python 3.12
- Erlang 27
- Gleam
- FastAPI, Uvicorn, Pydantic
- Rust + Cargo (for frontend/Tauri builds)
- Dev tools: black, ruff, mypy
