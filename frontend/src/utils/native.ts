export function isNativeApp(): boolean {
  return typeof window !== 'undefined' &&
    (window.location.protocol === 'capacitor:' ||
     window.location.protocol === 'ionic:')
}

export function isTauriApp(): boolean {
  return typeof window !== 'undefined' &&
    '__TAURI__' in window
}

export function getPlatform(): 'web' | 'android' | 'ios' | 'desktop' {
  if (typeof window === 'undefined') return 'web'
  if (isTauriApp()) return 'desktop'
  if (window.location.protocol === 'capacitor:') return 'android'
  if (window.location.protocol === 'ionic:') return 'ios'
  return 'web'
}

export async function scanBarcode(): Promise<string | null> {
  if (!isNativeApp()) return null
  try {
    const { Camera } = await import('@capacitor/camera')
    const image = await Camera.pickImages({ limit: 1 })
    if (!image.photos?.[0]?.path) return null
    return image.photos[0].path
  } catch {
    return null
  }
}

export async function requestBiometricAuth(reason = 'تأكيد الهوية'): Promise<boolean> {
  try {
    const mod = await import('@aparajita/capacitor-biometric-auth')
    await mod.BiometricAuth.authenticate({ reason, title: 'المصادقة', subtitle: '' })
    return true
  } catch {
    return false
  }
}

export async function isBiometricAvailable(): Promise<boolean> {
  try {
    const mod = await import('@aparajita/capacitor-biometric-auth')
    const result = await mod.BiometricAuth.isAvailable()
    return result.isAvailable
  } catch {
    return false
  }
}

export async function printBluetooth(text: string): Promise<boolean> {
  try {
    const mod = await import('@capacitor-community/bluetooth-le')
    const PRINTER_SERVICE = '000018f0-0000-1000-8000-00805f9b34fb'
    const PRINTER_CHAR = '00002af1-0000-1000-8000-00805f9b34fb'
    const device = await mod.BluetoothLe.requestDevice({
      services: [PRINTER_SERVICE],
    })
    await mod.BluetoothLe.connect({ deviceId: device.device.deviceId })
    const encoder = new TextEncoder()
    const data = encoder.encode(text)
    await mod.BluetoothLe.write({
      deviceId: device.device.deviceId,
      service: PRINTER_SERVICE,
      characteristic: PRINTER_CHAR,
      value: data.buffer,
    })
    await mod.BluetoothLe.disconnect({ deviceId: device.device.deviceId })
    return true
  } catch {
    return false
  }
}
