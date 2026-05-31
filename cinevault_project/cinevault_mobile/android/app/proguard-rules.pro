-keepattributes *Annotation*
-keepclassmembers class * {
    @jakarta.persistence.* <fields>;
    @jakarta.persistence.* <methods>;
}
-dontwarn jakarta.**
-dontwarn javax.**
-dontwarn com.google.errorprone.**
