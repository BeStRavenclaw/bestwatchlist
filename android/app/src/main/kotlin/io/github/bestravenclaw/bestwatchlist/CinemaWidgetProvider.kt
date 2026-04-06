package io.github.bestravenclaw.bestwatchlist

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews

class CinemaWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("CinemaWidget", "=== onUpdate called with ${appWidgetIds.size} widgets ===")
        for (appWidgetId in appWidgetIds) {
            Log.d("CinemaWidget", "Updating widget ID: $appWidgetId")
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
        // Ensure midnight alarm is scheduled (handles app updates and edge cases)
        MidnightUpdateReceiver.scheduleMidnightAlarm(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("CinemaWidget", "=== onReceive: action=${intent.action} ===")
        super.onReceive(context, intent)
    }

    override fun onEnabled(context: Context) {
        // First widget instance created - schedule daily midnight updates
        Log.d("CinemaWidget", "Widget enabled - scheduling midnight alarm")
        MidnightUpdateReceiver.scheduleMidnightAlarm(context)
    }

    override fun onDisabled(context: Context) {
        // Last widget instance removed - cancel the midnight alarm
        Log.d("CinemaWidget", "Widget disabled - cancelling midnight alarm")
        MidnightUpdateReceiver.cancelMidnightAlarm(context)
    }
}


internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    try {
        Log.d("CinemaWidget", "Starting widget update for ID: $appWidgetId at ${System.currentTimeMillis()}")

        // Read from our direct SharedPreferences (not HomeWidgetPlugin)
        val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        // Log the current data to verify it's been updated
        val movieCount = widgetData.getInt("movie_count", -1)
        val lastUpdate = widgetData.getLong("last_update", 0)
        Log.d("CinemaWidget", "SharedPreferences data: movie_count=$movieCount, last_update=$lastUpdate")
        // Log first movie if exists
        if (movieCount > 0) {
            val firstTitle = widgetData.getString("movie_title_0", "N/A")
            Log.d("CinemaWidget", "First movie: $firstTitle")
        }
        Log.d("CinemaWidget", "Got widget data successfully")
        val views = RemoteViews(context.packageName, R.layout.cinema_widget_simple)
        Log.d("CinemaWidget", "Created RemoteViews")

        // Add click handler to open the app when tapping anywhere on the widget
        try {
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (intent != null) {
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                // Set click handler on the header (logo + title area)
                views.setOnClickPendingIntent(R.id.widget_header, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_logo, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_title_be, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_title_st, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

                // Set up pending intent template for list items
                views.setPendingIntentTemplate(R.id.widget_list, pendingIntent)
                Log.d("CinemaWidget", "Added click handlers to header, logo, title, and list items")
            } else {
                Log.w("CinemaWidget", "Launch intent is null, skipping click handler")
            }
        } catch (e: Exception) {
            Log.e("CinemaWidget", "Error setting click handlers", e)
        }

        // Set up the ListView with RemoteViewsService
        // CRITICAL: The Intent must have unique data URI, otherwise Android caches
        // the RemoteViewsService and won't call onDataSetChanged() on updates
        val serviceIntent = Intent(context, CinemaWidgetService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            // Unique URI forces Android to create/refresh the service instance
            data = Uri.parse("widget://bestwatchlist/$appWidgetId/${System.currentTimeMillis()}")
        }
        views.setRemoteAdapter(R.id.widget_list, serviceIntent)

        Log.d("CinemaWidget", "ListView adapter set")

        // First commit the RemoteViews to the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
        Log.d("CinemaWidget", "Widget views updated")

        // Then notify the ListView that data has changed (must be after updateAppWidget)
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list)
        Log.d("CinemaWidget", "Widget data refresh triggered")
    } catch (e: Exception) {
        // If there's an error, show a simple fallback widget
        Log.e("CinemaWidget", "Error updating widget: ${e.javaClass.simpleName}", e)
        Log.e("CinemaWidget", "Error message: ${e.message}")
        Log.e("CinemaWidget", "Stack trace: ${e.stackTraceToString()}")
        try {
            val views = RemoteViews(context.packageName, R.layout.cinema_widget_simple)
            // Show error in the main title part
            views.setTextViewText(R.id.widget_title_be, "")
            views.setTextViewText(R.id.widget_title_st, "")
            views.setTextViewText(R.id.widget_title, "Error: Tap to open")

            // Add click handler to error widget too
            try {
                val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                if (intent != null) {
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        0,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    // Set click handlers on header elements
                    views.setOnClickPendingIntent(R.id.widget_header, pendingIntent)
                    views.setOnClickPendingIntent(R.id.widget_logo, pendingIntent)
                    views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)
                }
            } catch (intentError: Exception) {
                Log.e("CinemaWidget", "Error setting error widget click handler", intentError)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (fallbackError: Exception) {
            Log.e("CinemaWidget", "Even fallback widget failed", fallbackError)
        }
    }
}
