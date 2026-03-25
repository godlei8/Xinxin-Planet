package com.example.just_light

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "xinxin_planet/native"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "clearNotificationCache" -> {
                    clearNotificationCache()
                    result.success(true)
                }
                "getTimeZoneId" -> {
                    result.success(TimeZone.getDefault().id)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun clearNotificationCache() {
        val names = listOf(
            "scheduled_notifications",
            "notification_plugin_cache",
            "flutter_local_notifications_plugin"
        )

        names.forEach { name ->
            getSharedPreferences(name, Context.MODE_PRIVATE).edit().clear().apply()
        }
    }
}
