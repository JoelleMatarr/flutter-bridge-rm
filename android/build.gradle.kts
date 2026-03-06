buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // IMPORTANT: Replace "2.0.0" with your exact Kotlin version (e.g., 2.0.21, 2.1.0).
        // You can check your current Kotlin version inside your android/settings.gradle file.
        classpath("org.jetbrains.kotlin.plugin.compose:org.jetbrains.kotlin.plugin.compose.gradle.plugin:2.3.10")
    }
}

    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }



allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://maven.fpregistry.io/releases") }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

