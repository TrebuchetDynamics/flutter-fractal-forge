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
subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android") ?: return@withId
        val getNamespace = androidExt::class.java.methods.firstOrNull {
            it.name == "getNamespace" && it.parameterCount == 0
        }
        val setNamespace = androidExt::class.java.methods.firstOrNull {
            it.name == "setNamespace" && it.parameterCount == 1
        }
        val currentNamespace = getNamespace?.invoke(androidExt) as? String
        if (currentNamespace.isNullOrBlank()) {
            setNamespace?.invoke(
                androidExt,
                "com.fractals.legacy.${project.name.replace('-', '_')}"
            )
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
