# 📱 Cómo Instalar MaCElectricos en tu Dispositivo

## Opción 1: Instalar APK (Más Rápido)

### En dispositivo Android físico:

1. **Activar instalación de fuentes desconocidas:**
   - Ajustes → Seguridad → Fuentes desconocidas ✅
   
2. **Copiar APK al celular:**
   - Cable USB o Google Drive
   - Ubicación: `build/app/outputs/flutter-apk/app-debug.apk`

3. **Instalar:**
   - Abrir archivo APK desde el celular
   - Permitir instalación

### Con ADB (Android Debug Bridge):

```bash
adb install "build/app/outputs/flutter-apk/app-debug.apk"
```

---

## Opción 2: Ejecutar desde Flutter (Desarrollo)

### 1. Conectar dispositivo Android:
```bash
adb devices
```

Deberías ver algo como:
```
List of devices attached
ABC123456   device
```

### 2. Ejecutar la app:
```bash
"/c/flutter/bin/flutter.bat" run
```

### 3. Para hot reload:
- Presiona `r` en la terminal para recargar
- Presiona `R` para hot restart completo

---

## Opción 3: Emulador Android

### 1. Listar emuladores disponibles:
```bash
"/c/flutter/bin/flutter.bat" emulators
```

### 2. Iniciar emulador:
```bash
"/c/flutter/bin/flutter.bat" emulators --launch <nombre_emulador>
```

### 3. Ejecutar app:
```bash
"/c/flutter/bin/flutter.bat" run
```

---

## 🔐 Usuarios de Prueba

Una vez instalada, usa estas credenciales para probar cada rol:

### Administrador
- **Email:** `admin@macelectricos.com`
- **Password:** `admin123`
- **Acceso:** Panel administrativo completo

### Supervisor
- **Email:** `supervisor@macelectricos.com`
- **Password:** `super123`
- **Acceso:** Dashboard de supervisión

### Técnico
- **Email:** `tecnico@macelectricos.com`
- **Password:** `tech123`
- **Acceso:** Dashboard técnico + tracking de sesión

---

## ⚠️ Problemas Comunes

### "App no instalada" o "Error al instalar"
**Solución:** Desinstala versiones anteriores primero
```bash
adb uninstall com.macelectricos.app
```

### "Dispositivo no autorizado"
**Solución:** Acepta la solicitud de depuración USB en el celular

### "No se encontró ningún dispositivo"
**Solución:** 
1. Verifica que la depuración USB esté activada
2. Reconecta el cable
3. Ejecuta `adb kill-server && adb start-server`

---

## 🧪 Qué Probar

### Como Administrador:
- ✅ Crear/editar usuarios
- ✅ Gestionar cuadrillas
- ✅ Configurar catálogos

### Como Supervisor:
- ✅ Revisar sesiones de cuadrillas
- ✅ Aprobar/rechazar registros
- ✅ Ver reportes

### Como Técnico:
- ✅ Iniciar sesión de trabajo
- ✅ Registrar postes/transformadores/árboles
- ✅ Crear claros entre postes
- ✅ Ver mapa con elementos
- ✅ Sincronizar datos

---

**¡Listo para testear!** 🚀
