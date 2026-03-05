-ignorewarnings
-keep class * {
  public private *;
 }

# qr_code_scanner / ZXing
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**
