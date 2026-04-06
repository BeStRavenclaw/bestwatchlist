package io.github.bestravenclaw.bestwatchlist

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import java.util.Calendar

/**
 * BroadcastReceiver that triggers widget updates at midnight.
 * This is more efficient than polling every 30 minutes since the
 * "days until" text only changes once per day.
 */
class MidnightUpdateReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("MidnightUpdate", "Midnight alarm triggered, updating widget")

        // Update all widget instances
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val widgetIds = appWidgetManager.getAppWidgetIds(
            ComponentName(context, CinemaWidgetProvider::class.java)
        )

        for (widgetId in widgetIds) {
            updateAppWidget(context, appWidgetManager, widgetId)
        }

        // Schedule the next midnight alarm
        scheduleMidnightAlarm(context)
    }

    companion object {
        private const val REQUEST_CODE = 1001

        /**
         * Schedule an alarm to update the widget at the next midnight.
         */
        fun scheduleMidnightAlarm(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            val intent = Intent(context, MidnightUpdateReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Calculate next midnight
            val midnight = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 5) // 5 seconds past midnight for safety
                set(Calendar.MILLISECOND, 0)
            }

            Log.d("MidnightUpdate", "Scheduling next update for: ${midnight.time}")

            // Try to use exact alarm if permission is granted (Android 12+)
            try {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                    if (alarmManager.canScheduleExactAlarms()) {
                        alarmManager.setExactAndAllowWhileIdle(
                            AlarmManager.RTC_WAKEUP,
                            midnight.timeInMillis,
                            pendingIntent
                        )
                        Log.d("MidnightUpdate", "Scheduled exact alarm")
                    } else {
                        // Fall back to inexact alarm if permission not granted
                        alarmManager.setAndAllowWhileIdle(
                            AlarmManager.RTC_WAKEUP,
                            midnight.timeInMillis,
                            pendingIntent
                        )
                        Log.d("MidnightUpdate", "Scheduled inexact alarm (exact alarm permission not granted)")
                    }
                } else {
                    // Pre-Android 12: can always use exact alarms
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        midnight.timeInMillis,
                        pendingIntent
                    )
                    Log.d("MidnightUpdate", "Scheduled exact alarm (pre-Android 12)")
                }
            } catch (e: SecurityException) {
                // If exact alarm fails, fall back to inexact
                Log.w("MidnightUpdate", "Exact alarm failed, using inexact: ${e.message}")
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    midnight.timeInMillis,
                    pendingIntent
                )
            }
        }

        /**
         * Cancel any scheduled midnight alarms.
         */
        fun cancelMidnightAlarm(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, MidnightUpdateReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
            Log.d("MidnightUpdate", "Midnight alarm cancelled")
        }
    }
}
