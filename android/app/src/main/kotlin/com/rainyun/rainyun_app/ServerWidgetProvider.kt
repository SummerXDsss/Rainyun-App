package com.rainyun.rainyun_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.graphics.Color
import android.util.Log
import com.summer.rainyun3rd.R
import com.summer.rainyun3rd.MainActivity

class ServerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("ServerWidget", "onUpdate called with ${appWidgetIds.size} widgets")
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("ServerWidget", "onReceive: ${intent.action}")
        super.onReceive(context, intent)
    }

    override fun onEnabled(context: Context) {
        // 小组件首次添加时调用
    }

    override fun onDisabled(context: Context) {
        // 最后一个小组件删除时调用
    }

    companion object {
        private const val TAG = "ServerWidget"
        private const val PREFS_NAME = "HomeWidgetPreferences"
        
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            Log.d(TAG, "updateAppWidget called for widgetId: $appWidgetId")
            
            // 直接使用正确的SharedPreferences名称
            val widgetData = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            
            // 读取卡片样式设置
            val cardStyle = widgetData.getString("card_style", "list") ?: "list"
            Log.d(TAG, "Card style: $cardStyle")
            
            // 根据样式选择布局
            val layoutId = if (cardStyle == "dashboard") {
                R.layout.server_widget_dashboard
            } else {
                R.layout.server_widget
            }
            val views = RemoteViews(context.packageName, layoutId)
            
            // 打印所有存储的数据用于调试
            val allPrefs = widgetData.all
            Log.d(TAG, "All prefs count: ${allPrefs.size}")
            
            // 从SharedPreferences读取，如果没有数据则显示"请选择服务器"
            val serverName = widgetData.getString("server_name", null) ?: "请选择服务器"
            val serverStatus = widgetData.getString("server_status", null) ?: "未知"
            val serverIp = widgetData.getString("server_ip", null) ?: "请在设置中选择"
            val serverRegion = widgetData.getString("server_region", null) ?: ""
            // home_widget保存int时实际存的是Int类型
            val cpuUsage = try {
                widgetData.getInt("cpu_usage", 0)
            } catch (e: Exception) {
                widgetData.getLong("cpu_usage", 0L).toInt()
            }
            val memUsage = try {
                widgetData.getInt("mem_usage", 0)
            } catch (e: Exception) {
                widgetData.getLong("mem_usage", 0L).toInt()
            }
            val serverSpecs = widgetData.getString("server_specs", null) ?: ""
            val serverExpire = widgetData.getString("server_expire", null) ?: ""
            
            Log.d(TAG, "Read data - name: $serverName, status: $serverStatus, ip: $serverIp")
            
            // 设置文本
            views.setTextViewText(R.id.server_name, serverName)
            views.setTextViewText(R.id.server_status, serverStatus)
            views.setTextViewText(R.id.server_ip, serverIp)
            views.setTextViewText(R.id.server_region, serverRegion)
            views.setTextViewText(R.id.cpu_percent, "${cpuUsage}%")
            views.setTextViewText(R.id.mem_percent, "${memUsage}%")
            views.setTextViewText(R.id.server_specs, serverSpecs)
            views.setTextViewText(R.id.server_expire, serverExpire)
            
            // 设置进度条
            views.setProgressBar(R.id.cpu_progress, 100, cpuUsage, false)
            views.setProgressBar(R.id.mem_progress, 100, memUsage, false)
            
            // 根据状态设置颜色
            val statusBgRes = when (serverStatus) {
                "运行中" -> R.drawable.status_running_bg
                "已停止" -> R.drawable.status_stopped_bg
                else -> R.drawable.status_unknown_bg
            }
            // 注意：RemoteViews不支持直接设置背景，状态颜色通过drawable处理
            
            // 点击打开APP并跳转到小组件设置页面
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("widget_id", appWidgetId)
                putExtra("navigate_to", "widget_settings")
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId, // 使用widgetId作为requestCode确保每个小组件有独立的PendingIntent
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
