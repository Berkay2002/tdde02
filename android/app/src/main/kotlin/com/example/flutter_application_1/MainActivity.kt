package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Filter out spammy ImageReader warnings
        System.setProperty("debug.camera.log", "0")
        
        // Suppress ImageReader_JNI warnings by installing a log filter
        val originalHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            if (!throwable.message.orEmpty().contains("ImageReader")) {
                originalHandler?.uncaughtException(thread, throwable)
            }
        }
    }
}
