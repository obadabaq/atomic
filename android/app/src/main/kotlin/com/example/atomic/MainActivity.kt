package com.example.atomic

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.atomic/widget"
    private val TAG = "MainActivity"
    private var methodChannel: MethodChannel? = null
    private var pendingTabIndex: Int? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialTabIndex") {
                val tabIndex = intent.getIntExtra("tab_index", 0)
                Log.d(TAG, "getInitialTabIndex called, returning: $tabIndex")
                result.success(tabIndex)
                // Clear the intent extra after reading it
                intent.removeExtra("tab_index")
            } else {
                result.notImplemented()
            }
        }

        // If we have a pending tab index from onNewIntent, notify Flutter
        pendingTabIndex?.let { tabIndex ->
            Log.d(TAG, "Notifying Flutter of pending tab index: $tabIndex")
            methodChannel?.invokeMethod("navigateToTab", tabIndex)
            pendingTabIndex = null
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent) // Update the intent

        val tabIndex = intent.getIntExtra("tab_index", -1)
        if (tabIndex != -1) {
            Log.d(TAG, "onNewIntent received with tab_index: $tabIndex")

            // If Flutter engine is ready, notify immediately
            methodChannel?.let { channel ->
                Log.d(TAG, "Notifying Flutter to navigate to tab: $tabIndex")
                channel.invokeMethod("navigateToTab", tabIndex)
            } ?: run {
                // If Flutter engine is not ready yet, store the index for later
                Log.d(TAG, "Flutter engine not ready, storing tab index for later")
                pendingTabIndex = tabIndex
            }
        }
    }
}
