allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: org.gradle.api.file.Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: org.gradle.api.file.Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Compatibility shim for older Android library plugins that don't declare
// `namespace` (required by AGP 8+).
//
// Uses plugins.withId (lifecycle-safe; fires even after plugin is applied)
// and handles both AGP <8 (String getter/setter) and AGP 8+ (Property<String>
// returned by getNamespace()).
subprojects {
    plugins.withId("com.android.library") {
        val android = extensions.findByName("android") ?: return@withId
        try {
            val getNamespace = android.javaClass.getMethod("getNamespace")
            val nsPropOrValue = getNamespace.invoke(android)

            val hasNamespace: Boolean = when (nsPropOrValue) {
                null      -> false
                is String -> nsPropOrValue.isNotBlank()
                else      -> try {
                    // AGP 8+: namespace is a Property<String>; isPresent() = true if set
                    nsPropOrValue.javaClass.getMethod("isPresent").invoke(nsPropOrValue) as Boolean
                } catch (_: Exception) { false }
            }

            if (!hasNamespace) {
                val ns = "com.fractals.legacy.${project.name.replace('-', '_')}"
                when {
                    nsPropOrValue == null || nsPropOrValue is String -> {
                        // AGP <8: setNamespace(String)
                        android.javaClass
                            .getMethod("setNamespace", String::class.java)
                            .invoke(android, ns)
                    }
                    else -> {
                        // AGP 8+: Property<String>.set(String)
                        val setMethod = nsPropOrValue.javaClass.methods
                            .firstOrNull { m -> m.name == "set" && m.parameterCount == 1 }
                        setMethod?.invoke(nsPropOrValue, ns)
                    }
                }
            }
        } catch (e: Exception) {
            logger.warn("namespace-shim: could not patch ${project.name}: ${e.message}")
        }
    }
}

// AGP 8.8+ rejects the deprecated `package` attribute in source AndroidManifest.xml
// files.  Old Flutter plugins (e.g. arcore_flutter_plugin 0.1.0) still carry it.
// Strip it before Gradle manifest-merging kicks in.
subprojects {
    plugins.withId("com.android.library") {
        afterEvaluate {
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val original = manifestFile.readText()
                val patched = original.replace(
                    Regex("""(\s+)package\s*=\s*"[^"]*""""),
                    ""
                )
                if (patched != original) {
                    manifestFile.writeText(patched)
                    logger.lifecycle("manifest-patch: stripped package attr from ${project.name}")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
