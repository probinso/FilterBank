set dotenv-load := true

# Default recipe
default:
    @just --list

# --- Environment ---

env-create:
    conda env create -f environment.yml

env-update:
    conda env update -f environment.yml --prune

install:
    cd tauri && cargo fetch
    cd backend && pip install -r requirements.txt

# --- Backend ---

backend:
    cd backend && uvicorn main:app --reload --host 127.0.0.1 --port 8008

# --- Frontend (Gleam/Lustre) ---

frontend-build:
    cd frontend && gleam run -m lustre/dev build

frontend-watch:
    cd frontend && gleam run -m lustre/dev start

# --- Tauri ---

tauri-dev:
    cd tauri && cargo tauri dev

tauri-build:
    cd tauri && cargo tauri build

# --- Sidecar (Python → binary) ---

sidecar-build:
    cd backend && pyinstaller --onefile --name backend main.py
    mv backend/dist/backend tauri/binaries/backend-x86_64-unknown-linux-gnu

# --- Dev orchestration ---

dev-all:
    @echo "Starting development environment..."
    @echo "Run in separate terminals:"
    @echo "  just backend"
    @echo "  just frontend-watch"
    @echo "  just tauri-dev"

# --- Clean ---

clean:
    cd backend && find . -type d -name __pycache__ -exec rm -rf {} +
    cd backend && find . -type d -name .pytest_cache -exec rm -rf {} +
    cd backend && rm -rf build dist
    cd frontend && rm -rf build dist
    cd tauri && cargo clean
    rm -rf .env

clean-py:
    cd backend && find . -type d -name __pycache__ -exec rm -rf {} +
    cd backend && find . -type d -name .pytest_cache -exec rm -rf {} +

# --- Lint / Format ---

lint-backend:
    cd backend && python -m py_compile $(find . -name "*.py")

format-backend:
    cd backend && black --check .

check-rust:
    cd tauri && cargo fmt --check

format-rust:
    cd tauri && cargo fmt

check: lint-backend check-rust

format: format-backend format-rust

# --- Setup / Health ---

setup: clean install

health:
    @echo "Checking backend..."
    @curl -s http://127.0.0.1:8008/health || echo "Backend not running"   