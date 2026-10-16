# MaCElectricos - Documentación de Base de Datos

## 1. Estrategia de Persistencia

### Dual Storage: Local (Isar) + Remoto (Firestore)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PERSISTENCIA DUAL                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌──────────────┐           ┌──────────────┐                           │
│   │   ISAR DB    │           │  FIRESTORE   │                           │
│   │  (Local)     │           │  (Remoto)    │                           │
│   ├──────────────┤           ├──────────────┤                           │
│   │ - Datos tipados          │ - JSON docs  │                           │
│   │ - Índices rápidos        │ - Collections│                           │
│   │ - Streams reactivos      │ - Queries    │                           │
│   │ - Sin dependencia red    │ - Auth rules │                           │
│   │ - CRUD instantáneo       │ - Real-time  │                           │
│   │ - Offline 100%           │              │                           │
│   └──────────────┘           └──────────────┘                           │
│          │                          │                                   │
│          │    ┌─────────────────┐   │                                   │
│          └────│  SYNC QUEUE     │───┘                                   │
│               │ (Isar-based)    │                                       │
│               ├─────────────────┤                                       │
│               │ - Cola offline  │                                       │
│               │ - Retry logic   │                                       │
│               │ - Conflict res  │                                       │
│               │ - Batch writes  │                                       │
│               └─────────────────┘                                       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Entidades Principales

### 2.1 User (Usuario)

**Firestore**: `usuarios/{userId}`
**Isar**: `UserCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `nombre` | String | ✅ | Nombre completo | `indexed` |
| `email` | String | ✅ | Correo electrónico único | `unique` |
| `passwordHash` | String | ✅ | Hash bcrypt (nunca plain) | - |
| `role` | Enum | ✅ | tecnico / supervisor / admin | `indexed` |
| `equipoId` | String? | ❌ | Referencia a Crew | `indexed` |
| `telefono` | String? | ❌ | Contacto | - |
| `fotoUrl` | String? | ❌ | URL Storage | - |
| `activo` | bool | ✅ | Soft delete / habilitado | `indexed` |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `fechaActualizacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class User {
  Id id = Isar.autoIncrement;
  late String uid;              // Firebase UID
  late String nombre;
  late String email;
  late String role;             // 'tecnico' | 'supervisor' | 'admin'
  String? equipoId;             // FK → Crew
  String? telefono;
  String? fotoUrl;
  late bool activo;
  late DateTime fechaCreacion;
  late DateTime fechaActualizacion;
  late bool sincronizado;

  // Índices
  @Index(type: IndexType.value)
  late String email;

  @Index(type: IndexType.value)
  late String role;

  @Index(type: IndexType.value)
  String? equipoId;
}
```

---

### 2.2 Crew (Cuadrilla)

**Firestore**: `cuadrillas/{crewId}`
**Isar**: `CrewCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `nombre` | String | ✅ | Nombre de la cuadrilla | `indexed` |
| `descripcion` | String? | ❌ | Descripción | - |
| `supervisorId` | String | ✅ | FK → User (supervisor) | `indexed` |
| `tecnicoIds` | List<String> | ✅ | FK → User[] (técnicos) | - |
| `zona` | String? | ❌ | Zona geográfica | `indexed` |
| `activo` | bool | ✅ | Habilitado | `indexed` |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `fechaActualizacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class Crew {
  Id id = Isar.autoIncrement;
  late String crewId;           // UUID propio
  late String nombre;
  String? descripcion;
  late String supervisorId;     // FK → User
  late List<String> tecnicoIds; // FKs → User[]
  String? zona;
  late bool activo;
  late DateTime fechaCreacion;
  late DateTime fechaActualizacion;
  late bool sincronizado;

  @Index(type: IndexType.value)
  late String nombre;

  @Index(type: IndexType.value)
  late String supervisorId;

  @Index(type: IndexType.value)
  String? zona;
}
```

---

### 2.3 Pole (Poste)

**Firestore**: `postos/{poleId}`
**Isar**: `PoleCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `sessionId` | String | ✅ | FK → Session | `indexed` |
| `userId` | String | ✅ | FK → User (creador) | `indexed` |
| `equipoId` | String | ✅ | FK → Crew | `indexed` |
| `latitude` | double | ✅ | Coordenada GPS lat | - |
| `longitude` | double | ✅ | Coordenada GPS lng | - |
| `altitude` | double? | ❌ | Altitud metros | - |
| `codigoPoste` | String? | ❌ | Código identificador | `indexed` |
| `tipoPoste` | String? | ❌ | concreto / madera / acero | `indexed` |
| `altura` | double? | ❌ | Altura en metros | - |
| `observaciones` | String? | ❌ | Notas | - |
| `fotosIds` | List<String> | ❌ | FK → FotoEvidencia[] | - |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `fechaActualizacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class Pole {
  Id id = Isar.autoIncrement;
  late String poleId;           // UUID propio
  late String sessionId;        // FK → Session
  late String userId;           // FK → User
  late String equipoId;         // FK → Crew
  late double latitude;
  late double longitude;
  double? altitude;
  String? codigoPoste;
  String? tipoPoste;            // 'concreto' | 'madera' | 'acero'
  double? altura;
  String? observaciones;
  late List<String> fotosIds;
  late DateTime fechaCreacion;
  late DateTime fechaActualizacion;
  late bool sincronizado;

  // Índices compuestos
  @Index(type: IndexType.value)
  late String sessionId;

  @Index(type: IndexType.value)
  late String userId;

  @Index(type: IndexType.value)
  late String equipoId;

  @Index(type: IndexType.value)
  String? codigoPoste;

  // Índice compuesto para consultas frecuentes
  @Index(composite: [CompositeIndex('sessionId'), CompositeIndex('userId')])
  late String sessionUserKey;
}
```

---

### 2.4 Transformer (Transformador)

**Firestore**: `transformadores/{trafoId}`
**Isar**: `TransformerCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `sessionId` | String | ✅ | FK → Session | `indexed` |
| `userId` | String | ✅ | FK → User | `indexed` |
| `equipoId` | String | ✅ | FK → Crew | `indexed` |
| `latitude` | double | ✅ | Coordenada GPS lat | - |
| `longitude` | double | ✅ | Coordenada GPS lng | - |
| `codigoTransformador` | String? | ❌ | Código identificador | `indexed` |
| `potenciaKva` | double? | ❌ | Potencia en KVA | - |
| `tipoTransformador` | String? | ❌ | tipo / fabricante | - |
| `numeroFases` | int? | ❌ | 1 / 3 | - |
| `posteIdAsociado` | String? | ❌ | FK → Pole | `indexed` |
| `observaciones` | String? | ❌ | Notas | - |
| `fotosIds` | List<String> | ❌ | FK → FotoEvidencia[] | - |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `fechaActualizacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class Transformer {
  Id id = Isar.autoIncrement;
  late String trafoId;
  late String sessionId;
  late String userId;
  late String equipoId;
  late double latitude;
  late double longitude;
  String? codigoTransformador;
  double? potenciaKva;
  String? tipoTransformador;
  int? numeroFases;
  String? posteIdAsociado;     // FK → Pole
  String? observaciones;
  late List<String> fotosIds;
  late DateTime fechaCreacion;
  late DateTime fechaActualizacion;
  late bool sincronizado;

  @Index(type: IndexType.value)
  late String sessionId;

  @Index(type: IndexType.value)
  String? codigoTransformador;

  @Index(type: IndexType.value)
  String? posteIdAsociado;
}
```

---

### 2.5 Tree (Árbol)

**Firestore**: `arboles/{treeId}`
**Isar**: `TreeCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `sessionId` | String | ✅ | FK → Session | `indexed` |
| `userId` | String | ✅ | FK → User | `indexed` |
| `equipoId` | String | ✅ | FK → Crew | `indexed` |
| `latitude` | double | ✅ | Coordenada GPS lat | - |
| `longitude` | double | ✅ | Coordenada GPS lng | - |
| `especie` | String? | ❌ | Tipo de árbol | `indexed` |
| `alturaAproximada` | double? | ❌ | Altura metros | - |
| `distanciaAlPoste` | double? | ❌ | Distancia metros a poste cercano | - |
| `posteCercanoId` | String? | ❌ | FK → Pole más cercano | `indexed` |
| `riesgo` | String? | ❌ | alto / medio / bajo | `indexed` |
| `observaciones` | String? | ❌ | Notas | - |
| `fotosIds` | List<String> | ❌ | FK → FotoEvidencia[] | - |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `fechaActualizacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class Tree {
  Id id = Isar.autoIncrement;
  late String treeId;
  late String sessionId;
  late String userId;
  late String equipoId;
  late double latitude;
  late double longitude;
  String? especie;
  double? alturaAproximada;
  double? distanciaAlPoste;
  String? posteCercanoId;      // FK → Pole
  String? riesgo;              // 'alto' | 'medio' | 'bajo'
  String? observaciones;
  late List<String> fotosIds;
  late DateTime fechaCreacion;
  late DateTime fechaActualizacion;
  late bool sincronizado;

  @Index(type: IndexType.value)
  late String sessionId;

  @Index(type: IndexType.value)
  String? riesgo;

  @Index(type: IndexType.value)
  String? posteCercanoId;
}
```

---

### 2.6 PruningJob (Trabajo de Poda)

**Firestore**: `podas/{podaId}`
**Isar**: `PruningJobCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `sessionId` | String | ✅ | FK → Session | `indexed` |
| `userId` | String | ✅ | FK → User | `indexed` |
| `equipoId` | String | ✅ | FK → Crew | `indexed` |
| `arbolId` | String | ✅ | FK → Tree | `indexed` |
| `latitude` | double | ✅ | Ubicación trabajo | - |
| `longitude` | double | ✅ | Ubicación trabajo | - |
| `fechaInicio` | DateTime | ✅ | Inicio poda | `indexed` |
| `fechaFin` | DateTime | ✅ | Fin poda | - |
| `responsable` | String? | ❌ | Nombre responsable | - |
| `herramientaUtilizada` | String? | ❌ | Herramienta | - |
| `observaciones` | String? | ❌ | Notas | - |
| `fotosIds` | List<String> | ❌ | FK → FotoEvidencia[] | - |
| `completada` | bool | ✅ | Estado trabajo | `indexed` |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `fechaActualizacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class PruningJob {
  Id id = Isar.autoIncrement;
  late String podaId;
  late String sessionId;
  late String userId;
  late String equipoId;
  late String arbolId;         // FK → Tree
  late double latitude;
  late double longitude;
  late DateTime fechaInicio;
  late DateTime fechaFin;
  String? responsable;
  String? herramientaUtilizada;
  String? observaciones;
  late List<String> fotosIds;
  late bool completada;
  late DateTime fechaCreacion;
  late DateTime fechaActualizacion;
  late bool sincronizado;

  @Index(type: IndexType.value)
  late String sessionId;

  @Index(type: IndexType.value)
  late String arbolId;

  @Index(type: IndexType.value)
  late bool completada;

  Duration get duracion => fechaFin.difference(fechaInicio);
}
```

---

### 2.7 Span (Claro)

**Firestore**: `claros/{claroId}`
**Isar**: `SpanCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `sessionId` | String | ✅ | FK → Session | `indexed` |
| `userId` | String | ✅ | FK → User | `indexed` |
| `equipoId` | String | ✅ | FK → Crew | `indexed` |
| `posteOrigenId` | String | ✅ | FK → Pole origen | `indexed` |
| `posteDestinoId` | String | ✅ | FK → Pole destino | `indexed` |
| `distanciaMetros` | double | ✅ | Distancia calculada | - |
| `latitudeOrigen` | double | ✅ | Coords origen | - |
| `longitudeOrigen` | double | ✅ | Coords origen | - |
| `latitudeDestino` | double | ✅ | Coords destino | - |
| `longitudeDestino` | double | ✅ | Coords destino | - |
| `tipoCable` | String? | ❌ | Tipo cableado | - |
| `numeroCables` | int? | ❌ | Cantidad cables | - |
| `observaciones` | String? | ❌ | Notas | - |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `fechaActualizacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class Span {
  Id id = Isar.autoIncrement;
  late String claroId;
  late String sessionId;
  late String userId;
  late String equipoId;
  late String posteOrigenId;    // FK → Pole
  late String posteDestinoId;   // FK → Pole
  late double distanciaMetros;
  late double latitudeOrigen;
  late double longitudeOrigen;
  late double latitudeDestino;
  late double longitudeDestino;
  String? tipoCable;
  int? numeroCables;
  String? observaciones;
  late DateTime fechaCreacion;
  late DateTime fechaActualizacion;
  late bool sincronizado;

  @Index(type: IndexType.value)
  late String sessionId;

  @Index(type: IndexType.value)
  late String posteOrigenId;

  @Index(type: IndexType.value)
  late String posteDestinoId;
}
```

---

### 2.8 PhotoEvidence (Foto Evidencia)

**Firestore**: `fotos/{fotoId}`
**Isar**: `PhotoEvidenceCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `sessionId` | String | ✅ | FK → Session | `indexed` |
| `userId` | String | ✅ | FK → User | `indexed` |
| `equipoId` | String | ✅ | FK → Crew | `indexed` |
| `rutaLocal` | String | ✅ | Path dispositivo | - |
| `rutaRemota` | String? | ❌ | URL Storage | `indexed` |
| `latitude` | double | ✅ | GPS foto | - |
| `longitude` | double | ✅ | GPS foto | - |
| `descripcion` | String? | ❌ | Descripción | - |
| `elementoAsociadoId` | String? | ❌ | FK → Elemento padre | `indexed` |
| `elementoAsociadoTipo` | String? | ❌ | Tipo elemento padre | - |
| `tamañoBytes` | int? | ❌ | Tamaño archivo | - |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `fechaActualizacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status (data) | - |
| `fotosincronizado` | bool | ✅ | Sync status (archivo) | - |

```dart
// Isar Schema
@Collection()
class PhotoEvidence {
  Id id = Isar.autoIncrement;
  late String fotoId;
  late String sessionId;
  late String userId;
  late String equipoId;
  late String rutaLocal;
  String? rutaRemota;
  late double latitude;
  late double longitude;
  String? descripcion;
  String? elementoAsociadoId;
  String? elementoAsociadoTipo;  // 'poste' | 'arbol' | 'poda' | etc.
  int? tamañoBytes;
  late DateTime fechaCreacion;
  late DateTime fechaActualizacion;
  late bool sincronizado;
  late bool fotosincronizado;    // Imagen subida a Storage

  @Index(type: IndexType.value)
  late String sessionId;

  @Index(type: IndexType.value)
  String? rutaRemota;

  @Index(type: IndexType.value)
  String? elementoAsociadoId;
}
```

---

### 2.9 WorkRecord (Registro de Trabajo / Historial)

**Firestore**: `registros/{recordId}`
**Isar**: `WorkRecordCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `sessionId` | String | ✅ | FK → Session | `indexed` |
| `userId` | String | ✅ | FK → User | `indexed` |
| `equipoId` | String | ✅ | FK → Crew | `indexed` |
| `tipoElemento` | String | ✅ | Tipo elemento registrado | `indexed` |
| `elementoId` | String | ✅ | FK → Elemento específico | `indexed` |
| `accion` | String | ✅ | crear / editar / eliminar | - |
| `latitude` | double | ✅ | GPS registro | - |
| `longitude` | double | ✅ | GPS registro | - |
| `resumen` | String? | ❌ | Descripción legible | - |
| `metadata` | Map<String, dynamic> | ❌ | Datos adicionales | - |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class WorkRecord {
  Id id = Isar.autoIncrement;
  late String recordId;
  late String sessionId;
  late String userId;
  late String equipoId;
  late String tipoElemento;     // 'poste' | 'transformador' | 'arbol' | etc.
  late String elementoId;       // FK → Elemento
  late String accion;           // 'crear' | 'editar' | 'eliminar'
  late double latitude;
  late double longitude;
  String? resumen;
  Map<String, dynamic> metadata;
  late DateTime fechaCreacion;
  late bool sincronizado;

  @Index(type: IndexType.value)
  late String sessionId;

  @Index(type: IndexType.value)
  late String tipoElemento;

  @Index(type: IndexType.value)
  late DateTime fechaCreacion;
}
```

---

### 2.10 Session (Sesión de Trabajo)

**Firestore**: `sesiones/{sessionId}`
**Isar**: `SessionCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `userId` | String | ✅ | FK → User (creador) | `indexed` |
| `equipoId` | String | ✅ | FK → Crew | `indexed` |
| `fechaInicio` | DateTime | ✅ | Inicio sesión | `indexed` |
| `fechaFin` | DateTime? | ❌ | Fin sesión | - |
| `activa` | bool | ✅ | Sesión activa | `indexed` |
| `totalPostes` | int | ✅ | Contador postes | - |
| `totalTransformadores` | int | ✅ | Contador transformadores | - |
| `totalArboles` | int | ✅ | Contador árboles | - |
| `totalPodas` | int | ✅ | Contador podas | - |
| `totalClaros` | int | ✅ | Contador claros | - |
| `totalFotos` | int | ✅ | Contador fotos | - |
| `distanciaTotalClaros` | double | ✅ | Suma distancias claros | - |
| `fechaCreacion` | DateTime | ✅ | Auto-generado | - |
| `fechaActualizacion` | DateTime | ✅ | Auto-generado | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class SessionRecord {
  Id id = Isar.autoIncrement;
  late String sessionId;
  late String userId;
  late String equipoId;
  late DateTime fechaInicio;
  DateTime? fechaFin;
  late bool activa;
  late int totalPostes;
  late int totalTransformadores;
  late int totalArboles;
  late int totalPodas;
  late int totalClaros;
  late int totalFotos;
  late double distanciaTotalClaros;
  late DateTime fechaCreacion;
  late DateTime fechaActualizacion;
  late bool sincronizado;

  @Index(type: IndexType.value)
  late String userId;

  @Index(type: IndexType.value)
  late String equipoId;

  @Index(type: IndexType.value)
  late bool activa;

  Duration get duracion =>
      (fechaFin ?? DateTime.now()).difference(fechaInicio);
}
```

---

### 2.11 SyncQueue (Cola de Sincronización)

**Firestore**: No aplica (solo local)
**Isar**: `SyncQueueCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `entidad` | String | ✅ | Nombre colección Firestore | `indexed` |
| `entidadId` | String | ✅ | ID documento Firestore | `indexed` |
| `operacion` | String | ✅ | create / update / delete | `indexed` |
| `datos` | Map<String, dynamic> | ✅ | Payload completo | - |
| `intentos` | int | ✅ | Veces intentado | - |
| `maxIntentos` | int | ✅ | Límite reintentos (default 5) | - |
| `proximoReintent`o | DateTime | ✅ | Próximo intento (backoff) | `indexed` |
| `error` | String? | ❌ | Último error | - |
| `creadoEn` | DateTime | ✅ | Cuando se encoló | - |
| `procesadoEn` | DateTime? | ❌ | Cuando se procesó | - |
| `estado` | String | ✅ | pendiente / procesando / completado / fallido | `indexed` |

```dart
// Isar Schema
@Collection()
class SyncQueueItem {
  Id id = Isar.autoIncrement;
  late String syncId;
  late String entidad;
  late String entidadId;
  late String operacion;        // 'create' | 'update' | 'delete'
  late Map<String, dynamic> datos;
  late int intentos;
  late int maxIntentos;
  late DateTime proximoReintento;
  String? error;
  late DateTime creadoEn;
  DateTime? procesadoEn;
  late String estado;           // 'pendiente' | 'procesando' | 'completado' | 'fallido'

  @Index(type: IndexType.value)
  late String entidad;

  @Index(type: IndexType.value)
  late String estado;

  @Index(type: IndexType.value)
  late DateTime proximoReintento;

  // Para batch processing
  @Index(composite: [CompositeIndex('entidad'), CompositeIndex('estado')])
  late String entidadEstadoKey;
}
```

---

### 2.12 SyncConflict (Conflicto de Sincronización)

**Firestore**: `conflictos/{conflictId}`
**Isar**: `SyncConflictCollection`

| Campo | Tipo | Requerido | Descripción | Índice |
|-------|------|-----------|-------------|--------|
| `id` | String (UUID) | ✅ | Identificador único | Primary Key |
| `entidad` | String | ✅ | Nombre colección | `indexed` |
| `entidadId` | String | ✅ | ID documento | `indexed` |
| `datosLocales` | Map<String, dynamic> | ✅ | Versión local | - |
| `datosRemotos` | Map<String, dynamic> | ✅ | Versión remota | - |
| `resuelto` | bool | ✅ | Resuelto o no | `indexed` |
| `solucion` | String? | ❌ | local / remoto / merge | - |
| `resueltoPor` | String? | ❌ | FK → User (supervisor) | - |
| `fechaDeteccion` | DateTime | ✅ | Cuando se detectó | - |
| `fechaResolucion` | DateTime? | ❌ | Cuando se resolvió | - |
| `sincronizado` | bool | ✅ | Sync status | - |

```dart
// Isar Schema
@Collection()
class SyncConflict {
  Id id = Isar.autoIncrement;
  late String conflictId;
  late String entidad;
  late String entidadId;
  late Map<String, dynamic> datosLocales;
  late Map<String, dynamic> datosRemotos;
  late bool resuelto;
  String? solucion;             // 'local' | 'remoto' | 'merge'
  String? resueltoPor;
  late DateTime fechaDeteccion;
  DateTime? fechaResolucion;
  late bool sincronizado;

  @Index(type: IndexType.value)
  late String entidad;

  @Index(type: IndexType.value)
  late bool resuelto;
}
```

---

## 3. Relaciones entre Entidades

### Diagrama ER (Entidad-Relación)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              MAPEO DE RELACIONES                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│   ┌─────────┐         ┌─────────┐         ┌─────────┐                          │
│   │  USER   │1      N │  CREW   │1      N │ SESSION │                          │
│   │         │────────▶│         │────────▶│         │                          │
│   │ userId  │         │ crewId  │         │sesionId │                          │
│   │ role    │         │ nombre  │         │ fecha   │                          │
│   └─────────┘         └─────────┘         └─────────┘                          │
│        │                   │                   │                                │
│        │                   │                   │                                │
│        │                   │                   │ 1                              │
│        │                   │                   │                                │
│        │                   │                   ▼ N                              │
│        │                   │              ┌──────────┐                          │
│        │                   │              │ ELEMENTOS│ (Polimórfico)             │
│        │                   │              ├──────────┤                          │
│        │                   │              │ POSTE    │                          │
│        │                   │              │ TRAFO    │                          │
│        │                   │              │ ARBOL    │                          │
│        │                   │              │ PODA     │                          │
│        │                   │              │ CLARO    │                          │
│        │                   │              │ FOTO     │                          │
│        │                   │              └──────────┘                          │
│        │                   │                   │                                │
│        │                   │                   │ 1                              │
│        │                   │                   │                                │
│        │                   │                   ▼ N                              │
│        │                   │              ┌──────────┐                          │
│        │                   │              │WORK_RECORD│ (Historial)             │
│        │                   │              └──────────┘                          │
│        │                   │                                                    │
│        │                   │                                                    │
│        │ 1                N│                                                    │
│        │───────────────────┘                                                    │
│        │ (User es Creador de Crew)                                              │
│        │                                                                        │
│        │ 1                          N                                           │
│        │─────────────────────────────────────────────────────────────────────┐   │
│        │ (User crea Elementos)                                               │   │
│        │                                                                     │   │
│        │                                                                     │   │
└────────┴─────────────────────────────────────────────────────────────────────┘   │
                                                                                 │
│  RELACIONES ESPECÍFICAS:                                                       │
│                                                                                 │
│  Poste ←──────────────────┐                                                    │
│     │                     │                                                    │
│     │ 1                 N │ (Transformador.posteIdAsociado)                    │
│     ▼                     │                                                    │
│  Transformador ───────────┘                                                    │
│                                                                                 │
│  Poste ←──────────────────┐                                                    │
│     │                     │                                                    │
│     │ 1                 N │ (Arbol.posteCercanoId)                             │
│     ▼                     │                                                    │
│  Arbol ───────────────────┘                                                    │
│                                                                                 │
│  Arbol ←───────────────────┐                                                   │
│     │                      │                                                   │
│     │ 1                  N │ (Poda.arbolId)                                    │
│     ▼                      │                                                   │
│  Poda ─────────────────────┘                                                   │
│                                                                                 │
│  Poste ←──┐    ┌── Poste                                                      │
│     │     │    │     │                                                         │
│     │ 1   │    │   1 │ (Span: posteOrigenId ↔ posteDestinoId)                │
│     ▼ N   │    │   ▼ N                                                        │
│  Span ────┘    └─────┘                                                        │
│                                                                                 │
│  FotoEvidencia ←─────────────┐                                                │
│     │                        │                                                │
│     │ N                    1 │ (Polimórfico: elementoAsociadoId + Tipo)       │
│     │                        │                                                │
│     ▼                        ▼                                                │
│  Poste / Transformador / Arbol / Poda                                         │
│                                                                                 │
│  SYNC_QUEUE ──────┐                                                           │
│     │             │ (Referencia cualquier entidad)                             │
│     │ N         1 │                                                           │
│     ▼             ▼                                                           │
│  Cualquier entidad local                                                      │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

### Tabla Resumen de Relaciones

| Relación | Cardinalidad | FK Field | Descripción |
|----------|-------------|----------|-------------|
| User → Crew | N:1 | `Crew.supervisorId` | Supervisor dirige cuadrilla |
| User → Crew | N:M | `Crew.tecnicoIds[]` | Técnicos en cuadrilla |
| Crew → Session | 1:N | `Session.equipoId` | Cuadrilla tiene múltiples sesiones |
| User → Session | 1:N | `Session.userId` | Usuario crea sesiones |
| Session → Pole | 1:N | `Pole.sessionId` | Sesión registra postes |
| Session → Transformer | 1:N | `Transformer.sessionId` | Sesión registra transformadores |
| Session → Tree | 1:N | `Tree.sessionId` | Sesión registra árboles |
| Session → PruningJob | 1:N | `PruningJob.sessionId` | Sesión registra podas |
| Session → Span | 1:N | `Span.sessionId` | Sesión registra claros |
| Session → PhotoEvidence | 1:N | `PhotoEvidence.sessionId` | Sesión registra fotos |
| Session → WorkRecord | 1:N | `WorkRecord.sessionId` | Sesión genera historial |
| Pole → Transformer | 1:N | `Transformer.posteIdAsociado` | Poste tiene transformadores |
| Pole → Tree | 1:N | `Tree.posteCercanoId` | Poste cercano a árboles |
| Pole → Span (origen) | 1:N | `Span.posteOrigenId` | Poste origen de claros |
| Pole → Span (destino) | 1:N | `Span.posteDestinoId` | Poste destino de claros |
| Tree → PruningJob | 1:N | `PruningJob.arbolId` | Árbol tiene trabajos de poda |
| Cualquier → PhotoEvidence | 1:N | `PhotoEvidence.elementoAsociadoId` | Fotos asociadas a elementos |
| Cualquier → SyncQueue | 1:N | `SyncQueue.entidadId` | Cola sync por entidad |
| User → WorkRecord | 1:N | `WorkRecord.userId` | Historial por usuario |

---

## 4. Colecciones Firestore

### 4.1 Estructura de Colecciones

```
firestore/
├── usuarios/
│   └── {userId}
│       ├── nombre: string
│       ├── email: string
│       ├── role: 'tecnico' | 'supervisor' | 'admin'
│       ├── equipoId: reference → cuadrillas/{crewId}
│       ├── telefono: string
│       ├── fotoUrl: string
│       ├── activo: boolean
│       ├── fechaCreacion: timestamp
│       └── fechaActualizacion: timestamp
│
├── cuadrillas/
│   └── {crewId}
│       ├── nombre: string
│       ├── descripcion: string
│       ├── supervisorId: reference → usuarios/{userId}
│       ├── tecnicoIds: array<string>
│       ├── zona: string
│       ├── activo: boolean
│       ├── fechaCreacion: timestamp
│       └── fechaActualizacion: timestamp
│
├── sesiones/
│   └── {sessionId}
│       ├── userId: reference → usuarios/{userId}
│       ├── equipoId: reference → cuadrillas/{crewId}
│       ├── fechaInicio: timestamp
│       ├── fechaFin: timestamp
│       ├── activa: boolean
│       ├── totalPostes: number
│       ├── totalTransformadores: number
│       ├── totalArboles: number
│       ├── totalPodas: number
│       ├── totalClaros: number
│       ├── totalFotos: number
│       ├── distanciaTotalClaros: number
│       └── fechaCreacion: timestamp
│
├── postes/
│   └── {poleId}
│       ├── sessionId: reference → sesiones/{sessionId}
│       ├── userId: reference → usuarios/{userId}
│       ├── equipoId: reference → cuadrillas/{crewId}
│       ├── latitude: number
│       ├── longitude: number
│       ├── altitude: number
│       ├── codigoPoste: string
│       ├── tipoPoste: string
│       ├── altura: number
│       ├── observaciones: string
│       ├── fotosIds: array<string>
│       ├── fechaCreacion: timestamp
│       └── fechaActualizacion: timestamp
│
├── transformadores/
│   └── {trafoId}
│       ├── (mismos campos que Pole + campos específicos)
│       ├── posteIdAsociado: reference → postes/{poleId}
│       ├── codigoTransformador: string
│       ├── potenciaKva: number
│       ├── tipoTransformador: string
│       └── numeroFases: number
│
├── arboles/
│   └── {treeId}
│       ├── (campos base)
│       ├── especie: string
│       ├── alturaAproximada: number
│       ├── distanciaAlPoste: number
│       ├── posteCercanoId: reference → postes/{poleId}
│       └── riesgo: 'alto' | 'medio' | 'bajo'
│
├── podas/
│   └── {podaId}
│       ├── (campos base)
│       ├── arbolId: reference → arboles/{treeId}
│       ├── fechaInicio: timestamp
│       ├── fechaFin: timestamp
│       ├── responsable: string
│       ├── herramientaUtilizada: string
│       └── completada: boolean
│
├── claros/
│   └── {claroId}
│       ├── (campos base)
│       ├── posteOrigenId: reference → postes/{poleId}
│       ├── posteDestinoId: reference → postes/{poleId}
│       ├── distanciaMetros: number
│       ├── latitudeOrigen: number
│       ├── longitudeOrigen: number
│       ├── latitudeDestino: number
│       ├── longitudeDestino: number
│       ├── tipoCable: string
│       └── numeroCables: number
│
├── fotos/
│   └── {fotoId}
│       ├── (campos base)
│       ├── rutaLocal: string
│       ├── rutaRemota: string
│       ├── descripcion: string
│       ├── elementoAsociadoId: string
│       ├── elementoAsociadoTipo: string
│       └── tamañoBytes: number
│
├── registros/
│   └── {recordId}
│       ├── (campos base)
│       ├── tipoElemento: string
│       ├── elementoId: string
│       ├── accion: 'crear' | 'editar' | 'eliminar'
│       ├── resumen: string
│       └── metadata: map
│
└── conflictos/
    └── {conflictId}
        ├── entidad: string
        ├── entidadId: string
        ├── datosLocales: map
        ├── datosRemotos: map
        ├── resuelto: boolean
        ├── solucion: string
        ├── resueltoPor: reference → usuarios/{userId}
        ├── fechaDeteccion: timestamp
        └── fechaResolucion: timestamp
```

---

## 5. Índices Firestore Recomendados

```javascript
// Reglas de índice compuestas
const rules = {
  // Postes por sesión y usuario
  'postes': {
    'sessionId': 'ASCENDING',
    'userId': 'ASCENDING',
    'fechaCreacion': 'DESCENDING'
  },

  // Transformadores por código
  'transformadores': {
    'codigoTransformador': 'ASCENDING'
  },

  // Árboles por riesgo y sesión
  'arboles': {
    'sessionId': 'ASCENDING',
    'riesgo': 'ASCENDING'
  },

  // Podas por árbol y fecha
  'podas': {
    'arbolId': 'ASCENDING',
    'fechaInicio': 'DESCENDING'
  },

  // Claros por postes
  'claros': {
    'sessionId': 'ASCENDING',
    'posteOrigenId': 'ASCENDING',
    'posteDestinoId': 'ASCENDING'
  },

  // Registros por tipo y fecha
  'registros': {
    'tipoElemento': 'ASCENDING',
    'fechaCreacion': 'DESCENDING'
  },

  // Conflictos pendientes
  'conflictos': {
    'resuelto': 'ASCENDING',
    'fechaDeteccion': 'ASCENDING'
  }
};
```

---

## 6. Estrategia Offline-First (Detalle)

### 6.1 Flujo de Escritura

```
┌──────────────────────────────────────────────────────────────────────────┐
│                      FLUJO DE ESCRITURA OFFLINE-FIRST                   │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  USUARIO TAP "GUARDAR"                                                   │
│         │                                                                │
│         ▼                                                                │
│  ┌─────────────────────┐                                                │
│  │ 1. UI Provider      │  Riverpod StateNotifier                         │
│  │    Estado: Loading   │                                                │
│  └──────────┬──────────┘                                                │
│             │                                                            │
│             ▼                                                            │
│  ┌─────────────────────┐                                                │
│  │ 2. UseCase          │  Valida reglas de negocio                       │
│  │    - Campos req     │  (campos obligatorios, formato)                │
│  │    - Formato GPS    │                                                │
│  │    - Duplicados     │                                                │
│  └──────────┬──────────┘                                                │
│             │                                                            │
│             ▼                                                            │
│  ┌─────────────────────┐                                                │
│  │ 3. Repository       │                                                │
│  │    save(entity)     │                                                │
│  └──────────┬──────────┘                                                │
│             │                                                            │
│             ├──────────────────────┐                                     │
│             │                      │                                     │
│             ▼                      ▼                                     │
│  ┌─────────────────────┐  ┌─────────────────────┐                       │
│  │ 4a. Isar            │  │ 4b. SyncQueue        │                       │
│  │     write(entity)   │  │     enqueue({        │                       │
│  │     < 50ms          │  │       entidad,       │                       │
│  │     ↓               │  │       entidadId,     │                       │
│  │     Stream emits    │  │       operacion,     │                       │
│  │     UI updates      │  │       datos: entity  │                       │
│  └──────────┬──────────┘  │     })               │                       │
│             │              └──────────┬──────────┘                       │
│             │                         │                                  │
│             ▼                         ▼                                  │
│  ┌─────────────────────┐  ┌─────────────────────┐                       │
│  │ 5. UI Provider      │  │ 6. Cola local        │                       │
│  │    Estado: Success   │  │    Pendiente sync    │                       │
│  │    Lista refresh    │  │    (offline-safe)    │                       │
│  └─────────────────────┘  └──────────┬──────────┘                       │
│                                      │                                   │
│                                      ▼                                   │
│                           ┌─────────────────────┐                       │
│                           │ 7. WorkManager      │                       │
│                           │    periodic (15min)  │                       │
│                           │    on Connectivity   │                       │
│                           │    change             │                       │
│                           └──────────┬──────────┘                       │
│                                      │                                   │
│                    ┌─────────────────┼─────────────────┐                 │
│                    │ HAY RED         │ NO HAY RED       │                 │
│                    ▼                 ▼                  │                 │
│  ┌─────────────────────┐  ┌─────────────────────┐     │                 │
│  │ 8a. Process Queue   │  │ 8b. Reintenta       │     │                 │
│  │     Batch Firestore │  │     backoff expon.  │     │                 │
│  │     500 ops/batch   │  │     1min→2min→4min  │     │                 │
│  └──────────┬──────────┘  └─────────────────────┘     │                 │
│             │                                          │                 │
│             ▼                                          │                 │
│  ┌─────────────────────┐                               │                 │
│  │ 9. Marcar           │                               │                 │
│  │    sincronizado=true│                               │                 │
│  │    en Isar          │                               │                 │
│  └──────────┬──────────┘                               │                 │
│             │                                          │                 │
│             ▼                                          │                 │
│  ┌─────────────────────┐                               │                 │
│  │ 10. UI refresh      │                               │                 │
│  │     via Stream      │                               │                 │
│  └─────────────────────┘                               │                 │
│                                                        │                 │
└──────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Detección de Conectividad

```dart
// Service: ConnectivityService
class ConnectivityService {
  late StreamSubscription _subscription;
  final Connectivity _connectivity = Connectivity();
  
  // Estado actual
  bool _isOnline = false;
  bool get isOnline => _isOnline;
  
  // Stream para UI
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChange => _controller.stream;
  
  void init() {
    // Verificar estado inicial
    _checkConnectivity();
    
    // Escuchar cambios
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      _controller.add(_isOnline);
      
      if (_isOnline) {
        _triggerSync();  // Hay red → sincronizar cola
      }
    });
  }
  
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }
}
```

### 6.3 Batch Sync Firestore

```dart
// Service: SyncService
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> processQueue(List<SyncQueueItem> items) async {
    // Agrupar por colección para batch
    final batches = <String, List<SyncQueueItem>>{};
    for (final item in items) {
      batches.putIfAbsent(item.entidad, () => []).add(item);
    }
    
    for (final entry in batches.entries) {
      final batch = _firestore.batch();
      
      for (final item in entry.value) {
        final docRef = _firestore.collection(item.entidad).doc(item.entidadId);
        
        switch (item.operacion) {
          case 'create':
          case 'update':
            batch.set(docRef, item.datos, SetOptions(merge: true));
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
        
        // Limit 500 ops por batch Firestore
        if (batch.length >= 500) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }
      
      // Commit último batch
      if (batch.length > 0) {
        await batch.commit();
      }
      
      // Marcar items como procesados
      for (final item in entry.value) {
        await _markProcessed(item.id);
      }
    }
  }
}
```

### 6.4 Exponential Backoff

```dart
// En SyncQueueItem
DateTime calcularProximoReintento(int intentos) {
  // Base: 1 minuto
  // Backoff exponencial: 1min, 2min, 4min, 8min, 16min
  // Máximo: 30 minutos
  final minutes = math.min(math.pow(2, intentos).toInt(), 30);
  return DateTime.now().add(Duration(minutes: minutes));
}

// Ejemplo:
// Intento 0 → 1 min
// Intento 1 → 2 min
// Intento 2 → 4 min
// Intento 3 → 8 min
// Intento 4 → 16 min
// Intento 5+ → 30 min (cap)
```

### 6.5 Resolución de Conflictos

```dart
// Estrategia: Last-Write-Wins (LWW) por defecto
class ConflictResolver {
  
  // Detectar conflicto: misma entidad modificada offline + online
  SyncConflict? detectarConflicto(
    Map<String, dynamic> local,
    Map<String, dynamic> remoto,
  ) {
    final localUpdated = local['fechaActualizacion'] as DateTime;
    final remotoUpdated = remoto['fechaActualizacion'] as DateTime;
    
    // Si difieren por > 1 segundo, hay conflicto
    if ((localUpdated.difference(remotoUpdated)).inSeconds.abs() > 1) {
      return SyncConflict(
        datosLocales: local,
        datosRemotos: remoto,
      );
    }
    return null;
  }
  
  // Solución automática LWW
  Map<String, dynamic> resolverLWW(SyncConflict conflict) {
    final local = conflict.datosLocales;
    final remoto = conflict.datosRemotos;
    
    final localTime = local['fechaActualizacion'] as DateTime;
    final remotoTime = remoto['fechaActualizacion'] as DateTime;
    
    // Gana el más reciente
    if (localTime.isAfter(remotoTime)) {
      conflict.solucion = 'local';
      return local;
    } else {
      conflict.solucion = 'remoto';
      return remoto;
    }
  }
  
  // Para entidades críticas: merge manual (Supervisor revisa)
  Future<Map<String, dynamic>> mergeManual(SyncConflict conflict) {
    // Guardar en Firestore /conflictos para que Supervisor resuelva
    // La UI mostrará ambos campos side-by-side
    throw UnimplementedError('Requiere intervención manual del Supervisor');
  }
}
```

---

## 7. Migraciones de Schema

### 7.1 Versionado Isar

```dart
// Isar maneja migraciones automáticamente, pero para cambios complejos:
final isar = await Isar.open(
  [UserSchema, CrewSchema, SessionSchema, PoleSchema, ...],
  directory: directory.path,
  name: 'macelectricos',
  version: 2,  // Incrementar en cambios de schema
  onCreate: (isar, version) {
    // Primera instalación
    _createIndexes(isar);
  },
  onUpgrade: (isar, oldVersion, newVersion) {
    // Migración entre versiones
    if (oldVersion < 2) {
      // Agregar campos nuevos a schema existente
      _migrateV1toV2(isar);
    }
  },
);
```

### 7.2 Estrategia de Migración

| Tipo de Cambio | Estrategia |
|----------------|------------|
| Campo nuevo opcional | automático (default null/false) |
| Campo nuevo requerido | migración con default value |
| Renombrar campo | migración: copy old → new, delete old |
| Cambiar tipo | migración: parse + convert |
| Eliminar campo | ignorar (Isar conserva datos) |
| Nuevo índice | rebuild index en background |
| Nueva colección | automático |

---

## 8. Backup y Restore

### 8.1 Export Isar

```dart
// Backup local completo
Future<void> exportBackup(Isar isar, String path) async {
  // Isar no tiene export directo, usar:
  // 1. JSON de cada colección
  // 2. Copiar archivo .isar
  
  final backupData = {
    'version': 1,
    'fecha': DateTime.now().toIso8601String(),
    'usuarios': await isar.users.where().findAll(),
    'cuadrillas': await isar.crews.where().findAll(),
    'sesiones': await isar.sessions.where().findAll(),
    // ... todas las colecciones
  };
  
  final file = File('$path/backup_${DateTime.now().millisecondsSinceEpoch}.json');
  await file.writeAsString(jsonEncode(backupData));
}
```

### 8.2 Restore

```dart
Future<void> importBackup(Isar isar, String backupPath) async {
  final data = jsonDecode(await File(backupPath).readAsString());
  
  await isar.writeTxn(() async {
    // Limpiar colecciones existentes
    await isar.users.clear();
    await isar.crews.clear();
    // ...
    
    // Insertar datos del backup
    for (final user in data['usuarios']) {
      await isar.users.put(User.fromJson(user));
    }
    // ... para cada colección
  });
}
```

---

## 9. Queries Frecuentes

### 9.1 Por Sesión

```dart
// Todos los postes de una sesión
final postes = await isar.poles
    .where()
    .sessionIdEqualTo(sessionId)
    .sortByFechaCreacionDesc()
    .findAll();

// Contadores de sesión
final session = await isar.sessions.get(sessionId);
print('Postes: ${session.totalPostes}');
print('Árboles: ${session.totalArboles}');
```

### 9.2 Por Equipo (Cuadrilla)

```dart
// Sesiones de un equipo
final sesiones = await isar.sessions
    .where()
    .equipoIdEqualTo(equipoId)
    .sortByFechaInicioDesc()
    .findAll();

// Postes de un equipo
final postesEquipo = await isar.poles
    .where()
    .equipoIdEqualTo(equipoId)
    .findAll();
```

### 9.3 Por Fecha

```dart
// Trabajos de poda en rango
final podasRango = await isar.pruningJobs
    .where()
    .fechaInicioBetween(fechaInicio, fechaFin)
    .findAll();

// Registros de hoy
final hoy = DateTime.now();
final inicio = DateTime(hoy.year, hoy.month, hoy.day);
final registrosHoy = await isar.workRecords
    .where()
    .fechaCreacionBetween(inicio, hoy)
    .findAll();
```

### 9.4 Sync Pendiente

```dart
// Items pendientes de sincronización
final pendientes = await isar.syncQueueItems
    .where()
    .estadoEqualTo('pendiente')
    .sortByProximoReintentoAsc()
    .limit(50)
    .findAll();

// Conflictos sin resolver
final conflictos = await isar.syncConflicts
    .where()
    .resueltoEqualTo(false)
    .sortByFechaDeteccionDesc()
    .findAll();
```

---

## 10. Consideraciones de Rendimiento

| Aspecto | Estrategia |
|---------|------------|
| **Reads frecuentes** | Isar Streams (reactivos, <10ms) |
| **Writes batch** | Isar writeTxn() (transacción atómica) |
| **Índices** | Compuestos en campos de filtro frecuentes |
| **Pagineo** | `.offset().limit()` en queries grandes |
| **Fotos** | Thumbnails en BD, originales en filesystem |
| **Maps** | Clustering (Google Maps), solo cargar bbox visible |
| **Sync** | Batch Firestore 500 ops, cola paginada 50 items |

---

## 11. Checklist de Implementación

- [ ] 1. Isar schema para cada entidad (12 schemas)
- [ ] 2. Índices compuestos definidos
- [ ] 3. Mappers Isar ↔ Firestore
- [ ] 4. Repositories con CRUD + Streams
- [ ] 5. SyncQueue lógica completa
- [ ] 6. Conflict detection + resolution
- [ ] 7. Batch processing Firestore
- [ ] 8. WorkManager periodic sync
- [ ] 9. Connectivity listener
- [ ] 10. Export backup
- [ ] 11. Import restore
- [ ] 12. Tests unitarios repositories