use tauri::{Emitter, Manager};

#[tauri::command]
fn is_online() -> bool {
    true
}

#[tauri::command]
fn get_offline_queue() -> Vec<String> {
    vec![]
}

#[tauri::command]
fn show_notification(app_handle: tauri::AppHandle, title: String, body: String) {
    app_handle.emit("notification", serde_json::json!({ "title": title, "body": body })).ok();
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_notification::init())
        .plugin(tauri_plugin_updater::Builder::new().build())
        .plugin(tauri_plugin_process::init())
        .setup(|app| {
            use tauri::tray::{TrayIconBuilder, MouseButton, MouseButtonState};
            let _tray = TrayIconBuilder::new()
                .tooltip("EG-CO ERP")
                .on_menu_event(|app, event| {
                    if event.id == "show" {
                        if let Some(window) = app.get_webview_window("main") {
                            window.show().ok();
                            window.set_focus().ok();
                        }
                    }
                    if event.id == "quit" {
                        app.exit(0);
                    }
                })
                .build(app)?;
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![is_online, get_offline_queue, show_notification])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
