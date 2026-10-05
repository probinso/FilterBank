fn main() {
    #[cfg(target_os = "linux")]
    std::env::set_var("GDK_BACKEND", "wayland");

    tauri::Builder::default()
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
