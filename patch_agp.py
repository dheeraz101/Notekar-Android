import os

path = "android/build.gradle"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

fix_script = """
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            project.android {
                if (namespace == null) {
                    namespace project.group
                }
            }
        }
    }
}
"""

if "subprojects {" not in content:
    content += "\n" + fix_script
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Patched android/build.gradle")
