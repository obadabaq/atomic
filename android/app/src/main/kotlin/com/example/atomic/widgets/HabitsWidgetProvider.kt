package com.example.atomic.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.atomic.R
import android.app.PendingIntent
import android.util.Log

class HabitsWidgetProvider : AppWidgetProvider() {
    private val TAG = "HabitsWidgetProvider"

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate called for ${appWidgetIds.size} widgets")
        appWidgetIds.forEach { widgetId ->
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        private const val TAG = "HabitsWidgetProvider"
        const val EXTRA_TAB_INDEX = "tab_index"
        const val TAB_TODOS = 0
        const val TAB_FOOD = 1
        const val TAB_HABITS = 2
        const val TAB_NOTES = 3

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.habits_widget)

            // Set click handlers for each section
            views.setOnClickPendingIntent(
                R.id.section_todos,
                createPendingIntent(context, TAB_TODOS)
            )
            views.setOnClickPendingIntent(
                R.id.section_food,
                createPendingIntent(context, TAB_FOOD)
            )
            views.setOnClickPendingIntent(
                R.id.section_habits,
                createPendingIntent(context, TAB_HABITS)
            )
            views.setOnClickPendingIntent(
                R.id.section_notes,
                createPendingIntent(context, TAB_NOTES)
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        private fun createPendingIntent(context: Context, tabIndex: Int): PendingIntent {
            Log.d(TAG, "Creating PendingIntent for tab index: $tabIndex")
            val intent = Intent(context, Class.forName("com.example.atomic.MainActivity"))
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            intent.putExtra(EXTRA_TAB_INDEX, tabIndex)

            return PendingIntent.getActivity(
                context,
                tabIndex, // Use tabIndex as request code to make each PendingIntent unique
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = android.content.ComponentName(context, HabitsWidgetProvider::class.java)
            val widgetIds = appWidgetManager.getAppWidgetIds(componentName)

            widgetIds.forEach { widgetId ->
                updateWidget(context, appWidgetManager, widgetId)
            }
        }
    }
}
