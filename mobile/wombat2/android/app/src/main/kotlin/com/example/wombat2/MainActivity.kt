package com.example.wombat2

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.wombat2/audio"
    private lateinit var audioEngine: LowLatencyAudio
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        audioEngine = LowLatencyAudio()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    audioEngine.init()
                    result.success(null)
                }
                "start" -> {
                    audioEngine.start()
                    result.success(null)
                }
                "stop" -> {
                    audioEngine.stop()
                    result.success(null)
                }
                "setFrequency" -> {
                    val frequency = call.argument<Double>("frequency") ?: 1000.0
                    audioEngine.setFrequency(frequency)
                    result.success(null)
                }
                "setVolume" -> {
                    val volume = call.argument<Double>("volume") ?: 0.5
                    audioEngine.setVolume(volume.toFloat())
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    override fun onDestroy() {
        audioEngine.release()
        super.onDestroy()
    }
}
