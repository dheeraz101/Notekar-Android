import os

path = "android/build.gradle.kts"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

bad_block = """
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                if (namespace == null) {
                    namespace = project.group.toString()
                }
            }
        }
    }
}"""
content = content.replace(bad_block, "")

good_block = """
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            try {
                project.extensions.configure(com.android.build.gradle.LibraryExtension::class.java) {
                    if (namespace == null) {
                        namespace = project.group.toString()
                    }
                }
            } catch (e: Exception) {}
        }
    }
}
"""

target = """subprojects {
    project.evaluationDependsOn(":app")
}"""

content = content.replace(target, good_block + target)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
