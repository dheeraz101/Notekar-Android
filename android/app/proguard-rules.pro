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

# Flutter Play Store split / deferred components (ignore warnings for unused Play Core SDK)
-dontwarn com.google.android.play.core.**

# NoteKar Native App Classes & Receivers
-keep class app.notekar.notekar.** { *; }

# Isar Database Engine & Collection Schemas
-keep class * extends isar.CollectionSchema { *; }
-keep class * implements isar.IsarCollection { *; }
