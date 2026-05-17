# flutter_local_notifications: keep all classes so R8 doesn't strip the
# scheduling internals that ScheduledNotificationReceiver depends on at runtime.
-keep class com.dexterous.** { *; }
