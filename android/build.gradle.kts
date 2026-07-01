allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// file_picker 11.0.2 guards `apply plugin: 'org.jetbrains.kotlin.android'` behind
// `if (!isAgp9OrAbove)`, so on AGP 9 it never applies the Kotlin plugin — it wrongly
// assumes Flutter's built-in Kotlin will compile its sources. But built-in Kotlin is
// off here (android.builtInKotlin=false), and Flutter's auto-apply also skips
// file_picker because the (guarded) apply string is still present in its script text.
// Net effect: file_picker's Kotlin never compiles and FilePickerPlugin goes missing
// ("cannot find symbol" in GeneratedPluginRegistrant). Apply KGP to it ourselves —
// exactly what the Flutter Gradle plugin does for plugins that don't apply it.
subprojects {
    if (name == "file_picker") {
        pluginManager.apply("kotlin-android")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
