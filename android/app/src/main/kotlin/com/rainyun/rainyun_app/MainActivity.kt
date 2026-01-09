package com.summer.rainyun3rd

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.rainyun.widget/navigation"
    private var widgetId: Int? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWidgetIntent(intent)
    }
    
    private fun handleWidgetIntent(intent: Intent?) {
        intent?.let {
            if (it.hasExtra("widget_id")) {
                widgetId = it.getIntExtra("widget_id", -1)
            }
            if (it.hasExtra("navigate_to") && it.getStringExtra("navigate_to") == "widget_settings") {
                // 通知Flutter跳转到小组件设置页面
                flutterEngine?.dartExecutor?.let { executor ->
                    MethodChannel(executor.binaryMessenger, CHANNEL).invokeMethod(
                        "navigateToWidgetSettings",
                        mapOf("widgetId" to widgetId)
                    )
                }
            }
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getWidgetId" -> {
                    result.success(widgetId)
                    widgetId = null // 重置
                }
                else -> result.notImplemented()
            }
        }
    }
}
