import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.egco.erp',
  appName: 'EG-CO ERP',
  webDir: 'dist',
  server: {
    // In production, point to your server. For dev, use the local server.
    // Change this to your public IP/domain when building for distribution.
    url: 'http://192.168.1.50',
    cleartext: true, // allow HTTP (not just HTTPS) on Android
  },
  android: {
    allowMixedContent: true,
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 1000,
      backgroundColor: '#1e3a5f',
      showSpinner: false,
    },
  },
};

export default config;
