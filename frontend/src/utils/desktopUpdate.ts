/**
 * desktopUpdate.ts — Tauri auto-update checker.
 * Only active on desktop (Tauri) platform.
 * Requires: tauri-plugin-updater + tauri-plugin-process in Cargo.toml
 * Requires: valid Ed25519 pubkey in tauri.conf.json
 */
import { Capacitor } from '@capacitor/core';

export async function checkForDesktopUpdates(): Promise<void> {
  // Only run on Tauri desktop
  if (Capacitor.isNativePlatform() || !window.__TAURI__) return;

  try {
    const { check } = await import('@tauri-apps/plugin-updater');
    const { restart } = await import('@tauri-apps/plugin-process');

    const update = await check();
    if (update) {
      console.log(`Update available: ${update.version}`);

      // Download and install
      let downloaded = 0;
      let contentLength = 0;

      await update.downloadAndInstall((event) => {
        switch (event.event) {
          case 'Started':
            contentLength = event.data.contentLength || 0;
            console.log(`Downloading update (${contentLength} bytes)...`);
            break;
          case 'Progress': {
            downloaded += event.data.chunkLength;
            const pct = contentLength ? Math.round(downloaded / contentLength * 100) : 0;
            console.log(`Download progress: ${pct}%`);
            break;
          }
          case 'Finished':
            console.log('Download complete, installing...');
            break;
        }
      });

      // Restart to apply update
      await restart();
    } else {
      console.log('No updates available');
    }
  } catch (e) {
    // Silently fail — updater may not be configured (no pubkey, no server)
    console.warn('Desktop update check failed:', e);
  }
}
