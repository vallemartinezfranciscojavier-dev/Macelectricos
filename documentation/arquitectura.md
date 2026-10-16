# MaCElectricos - Documentación de Arquitectura

## 1. Visión General

MaCElectricos es una aplicación móvil Flutter para gestión de infraestructura eléctrica y trabajos de campo, diseñada con arquitectura **Clean Architecture** + **Feature-First** y patrón **Offline-First**.

### Stack Tecnológico
- **Frontend**: Flutter 3.19+ / Dart 3.2+
- **Estado**: Riverpod 2.5+ (StateNotifier + Providers)
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **Local DB**: Isar (embebido, rápido, tipado)
- **Mapas**: Google Maps Flutter
- **Ubicación**: Geolocator + Geocoding
- **Serialización**: Freezed + JSON Serializable
- **Inyección**: Riverpod Providers

---

## 2. Estructura de Carpetas (Feature-First)

```
lib/
├── core/                          # Núcleo compartido
│   ├── config/                    # Configuración app (env, theme, routes)
│   ├── models/                    # Modelos base (User, Crew, etc.)
│   ├── services/                  # Servicios transversales (Auth, Sync, Location)
│   ├── utils/                     # Utilidades (extensions, helpers, constants)
│   ├── errors/                    # Failure types, exceptions
│   └── di/                        # Dependency injection (providers globales)
│
├── features/                      # Módulos de negocio (features)
│   ├── auth/                      # Autenticación (login, register, roles)
│   ├── usuarios/                  # Gestión de usuarios (Admin)
│   ├── tecnicos/                  # Perfil técnico, dashboard campo
│   ├── supervisores/              # Dashboard supervisor, revisión
│   ├── cuadrillas/                # CRUD cuadrillas, asignaciones
│   ├── mapa/                      # Mapa base, capas, navegación
│   ├── postes/                    # CRUD postes + GPS + validaciones
│   ├── transformadores/           # CRUD transformadores + asociación poste
│   ├── arboles/                   # CRUD árboles + riesgo + proximidad
│   ├── podas/                     # Registro podas + evidencias
│   ├── claros/                    # Registro claros (poste A ↔ poste B)
│   ├── fotos/                     # Captura, galería, subida Storage
│   ├── historial/                 # Listado, filtros, detalle actividades
│   ├── sincronizacion/            # Cola sync, conflictos, estado red
│   ├── reportes/                  # Generación PDF/CSV/GeoJSON/KML
│   └── session_tracking/          # Sesión trabajo (ya implementado)
│
└── main.dart                      # Entry point + ProviderScope
```

### Convención por Feature
```
features/<feature>/
├── data/                          # Capa de datos
│   ├── datasources/               # Local (Isar) / Remote (Firestore)
│   ├── models/                    # DTOs / Entity mappers
│   └── repositories/              # Implementación Repository
├── domain/                        # Capa de dominio (pura, sin Flutter)
│   ├── entities/                  # Entidades de negocio
│   ├── repositories/              # Contratos (abstract class)
│   ├── usecases/                  # Casos de uso (single responsibility)
│   └── failures/                  # Tipos de error del dominio
└── presentation/                  # Capa UI
    ├── providers/                 # Riverpod StateNotifiers/Providers
    ├── screens/                   # Pages/Widgets principales
    ├── widgets/                   # Componentes reutilizables del feature
    └── dialogs/                   # BottomSheets, AlertDialogs
```

---

## 3. Principios Arquitectónicos

| Principio | Aplicación |
|-----------|------------|
| **Clean Architecture** | Domain no conoce Data/Presentation. Data implementa Domain. Presentation usa Domain via UseCases. |
| **Offline-First** | Todo se escribe en Isar local. SyncQueue maneja subida background. UI siempre lee local. |
| **Single Source of Truth** | Isar = verdad local. Firestore = verdad remota. Sync resuelve conflictos. |
| **Dependency Inversion** | Repositories son interfaces en Domain. Data las implementa. |
| **Unidirectional Data Flow** | UI → UseCase → Repository → DataSource. Estado via Riverpod. |
| **Feature Isolation** | Features no se importan entre sí. Comunicación via Core services o Events. |

---

## 4. Flujo de Datos (Offline-First)

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│    UI       │────▶│  UseCase     │────▶│ Repository  │────▶│ Local DS     │
│ (Riverpod)  │     │ (Domain)     │     │ (Interface) │     │ (Isar)       │
└─────────────┘     └──────────────┘     └─────────────┘     └──────────────┘
                                                                        │
                                                                        ▼
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│  Usuario    │◀───│  SyncWorker  │◀───│ SyncQueue   │◀───│  Isar Change │
│  ve datos   │     │ (WorkManager)│     │ (Isar)      │     │  Notifier    │
└─────────────┘     └──────────────┘     └─────────────┘     └──────────────┘
                           │
                           ▼
                  ┌──────────────┐
                  │ Remote DS    │
                  │ (Firestore)  │
                  └──────────────┘
```

### Escritura (Create/Update)
1. UI llama UseCase
2. UseCase valida reglas de negocio
3. Repository guarda en Isar (inmediato, < 50ms)
4. Repository encola en SyncQueue (tabla Isar)
5. UI actualiza via Stream Isar (reactivo)
6. WorkManager detecta red → procesa cola → sube a Firestore
7. Marca `sincronizado = true` local

### Lectura
1. UI suscribe a Stream Isar (Provider.watch)
2. Datos llegan instantáneos (offline OK)
3. Si hay red y datos stale > 5min → background refresh opcional

### Conflictos Sync
- **Last-Write-Wins** por defecto (timestamp servidor)
- **Merge manual** para entidades críticas (Poste, Transformador)
- **Cola de revisión** en UI Supervisor para conflictos no resueltos

---

## 5. Módulos Principales y Responsabilidades

| Módulo | Responsabilidad | Entidades Principales |
|--------|-----------------|----------------------|
| **auth** | Login, roles, tokens, biometría | User, Role, AuthToken |
| **usuarios** | CRUD usuarios, permisos (Admin) | User, Permission |
| **tecnicos** | Dashboard campo, registro rápido | Session, FieldRecord |
| **supervisores** | Revisión, métricas, asignaciones | Review, Metric, Assignment |
| **cuadrillas** | Gestión equipos, miembros, turnos | Crew, CrewMember, Shift |
| **mapa** | Mapa base, capas, clustering, offline tiles | MapLayer, MapTile, Cluster |
| **postes** | Registro GPS, validación, códigos, fotos | Poste, PostePhoto |
| **transformadores** | Registro, asociación poste, specs | Transformador |
| **arboles** | Registro, especie, riesgo, proximidad poste | Arbol |
| **podas** | Trabajo poda, tiempos, evidencias | Poda |
| **claros** | Vinculación poste A-B, distancia auto | Claro |
| **fotos** | Captura, compresión, metadatos EXIF, subida | FotoEvidencia |
| **historial** | Filtros, búsqueda, export, timeline | WorkRecord |
| **sincronizacion** | Cola, conflictos, estado, retry | SyncQueue, SyncConflict |
| **reportes** | PDF, CSV, GeoJSON, KML, plantillas | ReportTemplate, ExportJob |
| **session_tracking** | Sesión jornada, contadores, grafo | Session, SessionGraph |

---

## 6. Servicios Core (Transversales)

### AuthService
- Firebase Auth + custom claims (role: tecnico/supervisor/admin)
- Persistencia sesión local (SharedPreferences)
- Auto-refresh token

### SyncService
- WorkManager periodic sync (15 min + on connectivity change)
- Batch writes Firestore (500 ops/batch)
- Exponential backoff retry
- Conflict resolution strategies

### LocationService
- GPS alta precisión (10m target)
- Cache última ubicación conocida
- Geocoding inverso opcional
- Background location (permiso)

### StorageService
- Isar wrapper (CRUD + Streams + Queries)
- SharedPreferences para keys simples
- File system para fotos cache

### NotificationService
- FCM tokens, topics por cuadrilla
- Local notifications (sync completada, conflictos)

---

## 7. Seguridad y Permisos

| Rol | Permisos |
|-----|----------|
| **Técnico** | Crear/editar sus registros, ver su mapa, offline, fotos, sync own |
| **Supervisor** | Leer todo, revisar/aprobar, reportes, ver cuadrillas, métricas |
| **Admin** | CRUD usuarios, cuadrillas, catálogos, config, todo acceso |

### Reglas Firestore (resumen)
```javascript
// Usuario solo ve su cuadrilla
match /sesiones/{sesionId} {
  allow read: if request.auth.uid in get(/databases/$(database)/documents/cuadrillas/$(cuadrillaId)).data.tecnicosIds;
  allow write: if request.auth.uid == resource.data.userId;
}

// Admin ve todo
allow read, write: if get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.role == 'admin';
```

---

## 8. Navegación y Rutas

```
/                                    → Splash / Auth check
/login                               → LoginScreen
/tecnico/dashboard                   → TecnicoDashboard (mapa + acciones)
/tecnico/sesion/:sessionId           → SessionTrackingScreen
/tecnico/registro/:tipo              → RegistroFormScreen (poste/trafo/arbol/poda/claro/foto)
/supervisor/dashboard                → SupervisorDashboard
/supervisor/revision/:sessionId      → RevisionScreen
/supervisor/reportes                 → ReportesScreen
/admin/usuarios                      → UsuariosManagement
/admin/cuadrillas                    → CuadrillasManagement
/admin/catalogos                     → CatalogosConfig
/mapa                                → MapaFullScreen (con capas)
/historial                           → HistorialScreen (filtros)
/configuracion                       → SettingsScreen
```

---

## 9. Testing Strategy

| Nivel | Herramienta | Cobertura Objetivo |
|-------|-------------|-------------------|
| **Unit** | flutter_test + mocktail | Domain UseCases, Repositories, Mappers (>80%) |
| **Widget** | flutter_test + golden_toolkit | Presentation Providers, Screens (>60%) |
| **Integration** | integration_test + Firebase Emulators | Flujos completos offline→online, sync (>40%) |
| **E2E** | patrol / flutter_driver | Critical paths: login → sesión → registro → sync |

---

## 10. Performance & Optimización

- **Isar**: Índices compuestos en `sessionId + type + timestamp`
- **Mapa**: Clustering (100+ marcadores), tile caching offline
- **Imágenes**: Compresión WebP 80% antes de Storage, thumbnails 200px
- **Streams**: `distinct()` + `debounce(300ms)` en providers UI
- **Build**: `--split-per-abi`, `--obfuscate`, `--split-debug-info`

---

## 11. Próximos Pasos (Post Fase 1)

1. ✅ **Fase 1**: Arquitectura, entidades, documentación (ESTE DOC)
2. **Fase 2**: Core setup (Firebase, Isar, DI, Theme, Routing, Auth)
3. **Fase 3**: Features base (Cuadrillas, Usuarios, Mapa base)
4. **Fase 4**: Features campo (Postes, Transformadores, Árboles, Claros)
5. **Fase 5**: Features trabajo (Podas, Fotos, Sesión tracking completa)
6. **Fase 6**: Supervisor (Revisión, Métricas, Dashboard)
7. **Fase 7**: Admin (Usuarios, Catálogos, Permisos)
8. **Fase 8**: Sync robusta, Reportes, Export, Testing, Release