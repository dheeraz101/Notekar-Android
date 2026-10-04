import os

path = "lib/main.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

import_statement = "import 'package:workmanager/workmanager.dart';\n"
if "workmanager" not in content:
    content = import_statement + content

callback = """
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      
      if (task == 'midnight_analytics_backup') {
        // Run daily maintenance and backups
        await MomentRepository().ensureInitialized(preloadedPrefs: prefs);
        await MomentRepository().performDailyMaintenance();
      } else if (task == 'ACTION_LOG_BG') {
        // Enqueue from Android Widget
        // Handle background log
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}
"""

if "callbackDispatcher" not in content:
    idx = content.find("void main() async {")
    content = content[:idx] + callback + "\n" + content[idx:]

init_workmanager = """  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  Workmanager().registerPeriodicTask(
    "midnight-job",
    "midnight_analytics_backup",
    frequency: const Duration(hours: 24),
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresBatteryNotLow: true,
    ),
  );
"""

if "Workmanager().initialize" not in content:
    idx2 = content.find("WidgetsFlutterBinding.ensureInitialized();")
    if idx2 != -1:
        idx2 += len("WidgetsFlutterBinding.ensureInitialized();\n")
        content = content[:idx2] + init_workmanager + content[idx2:]

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("WorkManager initialized in main.dart")
