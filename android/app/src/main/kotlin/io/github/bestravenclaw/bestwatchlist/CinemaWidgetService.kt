package io.github.bestravenclaw.bestwatchlist

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import androidx.core.content.ContextCompat
import java.util.Calendar
import java.util.concurrent.TimeUnit

class CinemaWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        Log.d("CinemaWidgetService", "=== onGetViewFactory called, creating new factory ===")
        Log.d("CinemaWidgetService", "Intent data URI: ${intent.data}")
        return CinemaWidgetFactory(this.applicationContext)
    }
}

class CinemaWidgetFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private data class MovieItem(val title: String, val date: String)
    private var movieList = mutableListOf<MovieItem>()

    override fun onCreate() {
        Log.d("CinemaWidgetFactory", "Factory created")
    }

    override fun onDataSetChanged() {
        // This is called when the widget needs to update its data
        // The "days until" is recalculated here on each refresh
        Log.d("CinemaWidgetFactory", "Data set changed, loading movies")
        movieList.clear()

        try {
            // Get fresh SharedPreferences data directly (not via HomeWidgetPlugin)
            val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            // Log all available keys for debugging
            val allKeys = widgetData.all.keys
            Log.d("CinemaWidgetFactory", "Available SharedPreferences keys: $allKeys")

            val movieCount = widgetData.getInt("movie_count", 0)
            Log.d("CinemaWidgetFactory", "Loading $movieCount movies (timestamp: ${System.currentTimeMillis()})")

            if (movieCount == 0) {
                movieList.add(MovieItem("No cinema movies yet", "Add movies from the Browse tab!"))
            } else {
                // Load all movies (no limit since ListView is scrollable)
                for (i in 0 until movieCount) {
                    val title = widgetData.getString("movie_title_$i", "") ?: ""
                    // Read date - handle both old (String) and new (Long timestamp) formats
                    val formattedDate = getFormattedDate(widgetData, "movie_date_$i")

                    if (title.isNotEmpty()) {
                        movieList.add(MovieItem(title, formattedDate))
                        Log.d("CinemaWidgetFactory", "Added movie: $title - $formattedDate")
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("CinemaWidgetFactory", "Error loading movies", e)
            movieList.add(MovieItem("Error loading movies", e.message ?: "Unknown error"))
        }
    }

    /**
     * Get formatted date from widget data, handling both old (String) and new (Long) formats.
     * Old format: pre-formatted string like "In 5 days"
     * New format: timestamp in milliseconds
     */
    private fun getFormattedDate(widgetData: SharedPreferences, key: String): String {
        // Check the actual stored type
        val allData = widgetData.all
        return when (val value = allData[key]) {
            is Long -> formatReleaseDate(value)
            is Int -> formatReleaseDate(value.toLong())
            is String -> value.replace("/", ".") // Old format - convert slashes to dots
            else -> "TBD"
        }
    }

    /**
     * Format release date relative to today.
     * This is calculated fresh on each widget refresh so "days until" stays accurate.
     */
    private fun formatReleaseDate(timestamp: Long): String {
        if (timestamp == 0L) return "TBD"

        val releaseDate = Calendar.getInstance().apply { timeInMillis = timestamp }

        // Check for TBD date (year 9999)
        if (releaseDate.get(Calendar.YEAR) == 9999) {
            return "TBD"
        }

        // Get today at midnight for accurate day comparison
        val today = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        val releaseDay = Calendar.getInstance().apply {
            timeInMillis = timestamp
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        val diffMillis = releaseDay.timeInMillis - today.timeInMillis
        val diffDays = TimeUnit.MILLISECONDS.toDays(diffMillis).toInt()

        return when {
            diffDays < 0 -> "Released"
            diffDays == 0 -> "Today"
            diffDays == 1 -> "Tomorrow"
            diffDays <= 7 -> "In $diffDays days"
            else -> "${releaseDate.get(Calendar.DAY_OF_MONTH)}.${releaseDate.get(Calendar.MONTH) + 1}.${releaseDate.get(Calendar.YEAR)}"
        }
    }

    override fun onDestroy() {
        movieList.clear()
    }

    override fun getCount(): Int = movieList.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.cinema_widget_item)

        if (position < movieList.size) {
            val movie = movieList[position]
            views.setTextViewText(R.id.movie_title, movie.title)
            views.setTextViewText(R.id.movie_date, movie.date)

            // Set the date color to green if released (including today = release day)
            if (movie.date == "Released" || movie.date == "Today") {
                views.setTextColor(R.id.movie_date, ContextCompat.getColor(context, R.color.widget_released_green))
            } else {
                views.setTextColor(R.id.movie_date, ContextCompat.getColor(context, R.color.widget_text_secondary))
            }

            // Set up fill-in intent for item clicks to open the app
            val fillInIntent = Intent()
            fillInIntent.putExtras(Bundle().apply {
                putInt("position", position)
                putString("movie_title", movie.title)
            })
            // Make the entire item row clickable
            views.setOnClickFillInIntent(R.id.widget_item_container, fillInIntent)
            views.setOnClickFillInIntent(R.id.movie_title, fillInIntent)
            views.setOnClickFillInIntent(R.id.movie_date, fillInIntent)
        }

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}
