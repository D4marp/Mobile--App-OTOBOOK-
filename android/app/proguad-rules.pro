# Keep ML Kit classes untuk OTOBOOK
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.mlkit.vision.text.** { *; }

# Keep specific text recognition classes
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Keep text recognition options and builders
-keep class com.google.mlkit.vision.text.*.***Options { *; }
-keep class com.google.mlkit.vision.text.*.***Options$Builder { *; }

# Prevent obfuscation of ML Kit
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep Google ML Kit Commons
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# Preserve annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep OTOBOOK specific classes
-keep class com.otobook.perpustakaan.** { *; }