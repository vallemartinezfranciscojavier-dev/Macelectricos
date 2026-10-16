# MaCElectricos — Aplicación Flutter

## Estado
- **Versión**: 1.0 (Beta)
- **Última actualización**: 2026-10-16
- **Plataforma**: Android (Flutter)
- **APK compilado**: Sí, debug y release

## Descripción
Aplicación móvil para gestión de usuarios y cuadrillas de trabajo en empresa eléctrica:
- Sistema de login con 3 roles: Admin, Supervisor, Técnico
- Dashboard de gestión de usuarios
- Panel de administración (AdminDashboard)
- Gestión de cuadrillas y catálogos
- Routing automático por rol

## Arquitectura
```
lib/
  main.dart              # Punto de entrada
  screens/               # Pantallas principales
    login_screen.dart
    dashboard_screen.dart
    session_screen.dart
    admin_dashboard.dart
  models/                # Modelos de datos
  services/              # Servicios (API, autenticación)
  widgets/               # Componentes reutilizables
  utils/                 # Utilidades
android/                 # Configuración Android
test/                    # Tests (Flutter)
```

## Compilación

### Debug APK
```bash
"/c/flutter/bin/flutter.bat" build apk
```

### Release APK
```bash
"/c/flutter/bin/flutter.bat" build apk --release
```

## Importante
- Usar **C:\flutter** (sin espacios en la ruta)
- No usar flutter del PATH (rompe build_hooks)
- Emulador requiere boot completo para compilación

## Features implementados
- ✅ Sistema de autenticación por rol (Admin, Supervisor, Técnico)
- ✅ Routing dinámico basado en rol
- ✅ AdminDashboard con gestión de usuarios/cuadrillas
- ✅ Compilación APK exitosa
- ⚠️ Testing en vivo: pendiente (emulador OOM)

## Próximas mejoras
- Integración con backend real
- Testing completo en emulador/dispositivo
- Optimización de memoria
- Pantallas adicionales según roles
