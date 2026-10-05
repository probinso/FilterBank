set minimum-version := "1.58.0"
set default-list
set dotenv-load
set lazy

host := "127.0.0.1"
port := "8008"
target := `rustc --print host-tuple`

[group('setup')]
env-create:
    conda env create -f environment.yml

[group('setup')]
env-update:
    conda env update -f environment.yml --prune

[group('setup'), parallel]
install: install-rust install-py

[private, working-directory('tauri')]
install-rust:
    cargo fetch

[private, working-directory('backend')]
install-py:
    pip install -r requirements.txt

[group('setup')]
setup: clean install

[group('dev'), parallel]
dev: backend frontend-watch tauri-dev

[group('dev'), working-directory('backend')]
backend:
    uvicorn main:app --reload --host {{ host }} --port {{ port }}

[group('dev'), working-directory('frontend')]
frontend-watch:
    gleam run -m lustre/dev start

[group('dev'), working-directory('tauri')]
tauri-dev:
    cargo tauri dev

[group('dev')]
health:
    @curl -fsS http://{{ host }}:{{ port }}/health || echo "Backend not running"

[group('build'), working-directory('frontend')]
frontend-build:
    gleam run -m lustre/dev build

[group('build')]
sidecar-build:
    cd backend && pyinstaller --onefile --name backend main.py
    mkdir -p tauri/binaries
    mv backend/dist/backend tauri/binaries/backend-{{ target }}

[group('build'), working-directory('tauri')]
tauri-build:
    cargo tauri build

[group('lint'), parallel]
check: check-backend check-rust

[group('lint'), parallel]
format: format-backend format-rust

[group('lint'), working-directory('backend')]
check-backend:
    ruff check .
    ruff format --check .

[group('lint'), working-directory('backend')]
format-backend:
    ruff check --fix .
    ruff format .

[group('lint'), working-directory('tauri')]
check-rust:
    cargo fmt --check

[group('lint'), working-directory('tauri')]
format-rust:
    cargo fmt

[group('clean')]
clean: clean-py
    rm -rf backend/build backend/dist frontend/build frontend/dist
    cd tauri && cargo clean

[group('clean'), working-directory('backend')]
clean-py:
    find . -type d \( -name __pycache__ -o -name .pytest_cache \) -prune -exec rm -rf {} +
