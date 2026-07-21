# Flutter Wrapper Proguard Rules

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native plugin classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class dev.flutter.plugins.** { *; }

# Hive / Binary persistence
-keep class com.topjohnwu.libsu.** { *; }
