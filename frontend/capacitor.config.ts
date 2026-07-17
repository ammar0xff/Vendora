import { CapacitorConfig } from '@capacitor/cli';

const serverUrl = import.meta.env.VITE_API_URL || 'http://localhost:8080';

const config: CapacitorConfig = {
  appId: 'com.egco.erp',
  appName: 'EG-CO ERP',
  webDir: 'dist',
  server: {
    url: serverUrl,
    cleartext: !serverUrl.startsWith('https'),
  },
  android: {
    allowMixedContent: !serverUrl.startsWith('https'),
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 1000,
      backgroundColor: '#1e3a5f',
      showSpinner: false,
    },
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#1e3a5f',
      overlaysWebView: false,
    },
    PushNotifications: {
      presentationOptions: ['badge', 'sound', 'alert'],
    },
  },
};

export default config;
