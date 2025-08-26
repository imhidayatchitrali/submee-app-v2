package com.submee

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.*

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "packageInfo")

        channel.setMethodCallHandler { call, result ->
            if (call.method == "getVersionNumber") {
                result.success(BuildConfig.VERSION_NAME)
            }else if(call.method == "getBuildNumber"){
                result.success(BuildConfig.VERSION_CODE)
            }else if (call.method == "getTimeZoneName") {
                result.success(TimeZone.getDefault().id)
            }else{
                result.notImplemented()
            }
        }
    }
}
