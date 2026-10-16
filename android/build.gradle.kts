allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fuerza un compileSdk moderno en TODOS los plugins de Android (hijos de :app).
// Muchos plugins de pub.dev estan fijados a android-33/34 y fallan el
// checkDebugAarMetadata contra las librerias AndroidX mas recientes.
// Este hook evita tener que subir cada plugin de uno en uno.
val buildGradleKts = this
subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            val androidExtension = extensions.findByName("android")
            if (androidExtension != null) {
                val setCompileSdk = androidExtension.javaClass.methods.firstOrNull {
                    (it.name == "setCompileSdk" || it.name == "setCompileSdkVersion") &&
                        it.parameterCount == 1 &&
                        (it.parameterTypes[0] == java.lang.Integer.TYPE)
                }
                if (setCompileSdk != null) {
                    try {
                        setCompileSdk.invoke(androidExtension, 36)
                        buildGradleKts.logger.lifecycle("Macelectricos: compileSdk forçado a 36 en ${project.name}")
                    } catch (e: Exception) {
                        buildGradleKts.logger.warn("Macelectricos: no se pudo forzar compileSdk en ${project.name}: ${e.message}")
                    }
                }
            }
        }
    }
}