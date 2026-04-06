package io.github.bestravenclaw.bestwatchlist

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "io.github.bestravenclaw.bestwatchlist/widget"
    private val PREFS_NAME = "HomeWidgetPreferences"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveAndUpdateWidget" -> {
                    Log.d("MainActivity", "=== saveAndUpdateWidget called ===")
                    try {
                        // Get movie data from arguments
                        val args = call.arguments as Map<*, *>
                        val movieCount = args["movie_count"] as Int
                        val titles = args["titles"] as List<*>
                        val dates = args["dates"] as List<*>

                        Log.d("MainActivity", "Saving $movieCount movies to SharedPreferences")

                        // Save directly to SharedPreferences (same file home_widget uses)
                        val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                        val editor = prefs.edit()

                        // Clear old data first
                        editor.clear()

                        // Save new data
                        editor.putInt("movie_count", movieCount)
                        editor.putLong("last_update", System.currentTimeMillis())

                        for (i in 0 until movieCount) {
                            editor.putString("movie_title_$i", titles[i] as String)
                            editor.putLong("movie_date_$i", (dates[i] as Number).toLong())
                        }

                        // Commit synchronously to ensure data is written before widget update
                        editor.commit()
                        Log.d("MainActivity", "SharedPreferences saved successfully")

                        // Now update the widget
                        val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
                        val widgetComponent = ComponentName(applicationContext, CinemaWidgetProvider::class.java)
                        val widgetIds = appWidgetManager.getAppWidgetIds(widgetComponent)

                        Log.d("MainActivity", "Found ${widgetIds.size} widget(s) to update")

                        for (widgetId in widgetIds) {
                            Log.d("MainActivity", "Updating widget ID: $widgetId")
                            updateAppWidget(applicationContext, appWidgetManager, widgetId)
                        }

                        result.success(widgetIds.size)
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Error in saveAndUpdateWidget", e)
                        result.error("UPDATE_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
