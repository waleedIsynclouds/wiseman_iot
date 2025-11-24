package com.example.wiseman_iot

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity with MethodChannel and EventChannel for BLE operations
 * 
 * This activity bridges Flutter and native Android BLE SDK (HxjBlinkLibrary)
 * It provides:
 * - MethodChannel for BLE operations (connect, disconnect, sync, open, etc.)
 * - EventChannel for BLE scan results streaming
 */
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.hxjblesdk/ble"
    private val SCAN_CHANNEL = "com.example.hxjblesdk/ble_scan"

    private var methodChannel: MethodChannel? = null
    private var scanEventChannel: EventChannel? = null
    private var bleMethodHandler: BleMethodHandler? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize BLE method handler
        bleMethodHandler = BleMethodHandler(this)

        // Set up MethodChannel for BLE commands
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).apply {
            setMethodCallHandler(bleMethodHandler)
        }

        // Set up EventChannel for scan results
        scanEventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCAN_CHANNEL
        ).apply {
            setStreamHandler(bleMethodHandler?.getScanStreamHandler())
        }
    }

    override fun onDestroy() {
        methodChannel?.setMethodCallHandler(null)
        scanEventChannel?.setStreamHandler(null)
        bleMethodHandler?.cleanup()
        super.onDestroy()
    }
}
