/**
 * pushNotifications.ts — Registers device for FCM push notifications.
 * Only active on native platforms (Android via Capacitor).
 * Web PWA uses service worker push (separate flow).
 */
import { PushNotifications } from '@capacitor/push-notifications';
import { Capacitor } from '@capacitor/core';
import { notificationsApi } from '../api/endpoints';

let registered = false;

export async function registerForPushNotifications(): Promise<void> {
  if (!Capacitor.isNativePlatform()) return;
  if (registered) return;

  try {
    const perm = await PushNotifications.requestPermissions();
    if (perm.receive !== 'granted') {
      console.warn('Push notification permission denied');
      return;
    }

    await PushNotifications.register();

    PushNotifications.addListener('registration', async (token: { value: string }) => {
      try {
        await notificationsApi.register({
          token: token.value,
          platform: Capacitor.getPlatform() as 'android' | 'ios',
          device_name: navigator.userAgent.slice(0, 200),
        });
        registered = true;
        console.log('FCM token registered with server');
      } catch (e) {
        console.error('Failed to register FCM token:', e);
      }
    });

    PushNotifications.addListener('registrationError', (err) => {
      console.error('FCM registration error:', err);
    });

    PushNotifications.addListener('pushNotificationReceived', (notification) => {
      console.log('Push received:', notification);
      // Show local notification if app is in foreground
      if (Capacitor.getPlatform() === 'android') {
        PushNotifications.createChannel({
          id: 'egco-erp',
          name: 'Vendora',
          importance: 4,
          vibration: true,
        });
      }
    });

    PushNotifications.addListener('pushNotificationActionPerformed', (action) => {
      console.log('Push action:', action);
      const data = action.notification.data;
      if (data?.url) {
        window.location.hash = data.url;
      }
    });
  } catch (e) {
    console.error('Push notification setup failed:', e);
  }
}

export async function unregisterPushNotifications(): Promise<void> {
  if (!Capacitor.isNativePlatform() || !registered) return;
  try {
    const perm = await PushNotifications.requestPermissions();
    if (perm.receive === 'granted') {
      // We don't have the token here, but the server can deactivate stale tokens
    }
    registered = false;
  } catch (e) {
    console.error('Failed to unregister push notifications:', e);
  }
}
