# ===============================
# STRIPE PUSH PROVISIONING FIX
# ===============================

-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }

# Needed because Java 8 desugaring + R8 removes synthetic classes
-keepclassmembers class com.stripe.android.pushProvisioning.** {
    *;
}

# Keep sealed classes and companion objects
-keep class com.stripe.android.pushProvisioning.*$* { *; }

# Avoid stripping enums required by the library
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
