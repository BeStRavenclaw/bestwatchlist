package io.github.bestravenclaw.bestwatchlist

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Reschedules the midnight widget update alarm after device boot.
 * AlarmManager alarms are lost when the device restarts, so we need
 * to reschedule them.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Device booted, checking for active widgets")

            // Only schedule alarm if there are active widget instances
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val widgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, CinemaWidgetProvider::class.java)
            )

            if (widgetIds.isNotEmpty()) {
                Log.d("BootReceiver", "Found ${widgetIds.size} widgets, scheduling midnight alarm")
                MidnightUpdateReceiver.scheduleMidnightAlarm(context)

                // Also trigger an immediate update in case it's a new day
                for (widgetId in widgetIds) {
                    updateAppWidget(context, appWidgetManager, widgetId)
                }
            }
        }
    }
}
