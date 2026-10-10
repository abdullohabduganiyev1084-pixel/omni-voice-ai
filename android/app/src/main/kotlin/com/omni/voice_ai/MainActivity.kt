package com.omni.voice_ai

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.telecom.TelecomManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.omni.voice_ai/system_control"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Listen for phone call state changes and pass to Flutter
        PhoneCallReceiver.onCallStateChangedListener = { state, number ->
            runOnUiThread {
                channel.invokeMethod("onCallStateChanged", mapOf("state" to state, "number" to (number ?: "Noma'lum")))
            }
        }

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "answerCall" -> {
                    val answered = answerIncomingCall()
                    result.success(answered)
                }
                "endCall" -> {
                    val ended = endCurrentCall()
                    result.success(ended)
                }
                "openYouTubeAtTime" -> {
                    val query = call.argument<String>("query")
                    val videoId = call.argument<String>("videoId")
                    val timeSeconds = call.argument<Int>("timeSeconds") ?: 0
                    val success = openYouTubeWithTimestamp(query, videoId, timeSeconds)
                    result.success(success)
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    val success = launchApplication(packageName)
                    result.success(success)
                }
                "performGlobalAction" -> {
                    val action = call.argument<String>("action") ?: ""
                    val success = performGlobalAction(action)
                    result.success(success)
                }
                "clickScreenText" -> {
                    val text = call.argument<String>("text") ?: ""
                    val success = VoiceAccessibilityService.instance?.clickByText(text) ?: false
                    result.success(success)
                }
                "setVolume" -> {
                    val level = call.argument<Int>("level") ?: 50
                    setSystemVolume(level)
                    result.success(true)
                }
                "isAccessibilityEnabled" -> {
                    val isEnabled = VoiceAccessibilityService.instance != null
                    result.success(isEnabled)
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun answerIncomingCall(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val telecomManager = getSystemService(Context.TELECOM_SERVICE) as? TelecomManager
                telecomManager?.acceptRingingCall()
                true
            } else {
                // Fallback via accessibility clicking "Answer"
                VoiceAccessibilityService.instance?.clickByText("Answer") 
                    ?: VoiceAccessibilityService.instance?.clickByText("Javob berish") ?: false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback via Accessibility
            VoiceAccessibilityService.instance?.clickByText("Answer") 
                ?: VoiceAccessibilityService.instance?.clickByText("Javob berish") ?: false
        }
    }

    private fun endCurrentCall(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val telecomManager = getSystemService(Context.TELECOM_SERVICE) as? TelecomManager
                telecomManager?.endCall()
                true
            } else {
                VoiceAccessibilityService.instance?.clickByText("Decline")
                    ?: VoiceAccessibilityService.instance?.clickByText("Rad etish") ?: false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun openYouTubeWithTimestamp(query: String?, videoId: String?, seconds: Int): Boolean {
        return try {
            val uri = when {
                !videoId.isNullOrEmpty() -> {
                    Uri.parse("https://www.youtube.com/watch?v=$videoId&t=${seconds}s")
                }
                !query.isNullOrEmpty() -> {
                    Uri.parse("https://www.youtube.com/results?search_query=" + Uri.encode(query))
                }
                else -> {
                    Uri.parse("https://www.youtube.com")
                }
            }

            val appIntent = Intent(Intent.ACTION_VIEW, uri).apply {
                setPackage("com.google.android.youtube")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }

            try {
                startActivity(appIntent)
            } catch (e: Exception) {
                // Fallback to browser
                val webIntent = Intent(Intent.ACTION_VIEW, uri).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(webIntent)
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun launchApplication(packageNameOrName: String): Boolean {
        return try {
            val pm = packageManager
            val launchIntent = when (packageNameOrName.lowercase()) {
                "youtube" -> pm.getLaunchIntentForPackage("com.google.android.youtube")
                "telegram" -> pm.getLaunchIntentForPackage("org.telegram.messenger")
                "chrome", "google" -> pm.getLaunchIntentForPackage("com.android.chrome")
                "settings", "sozlamalar" -> Intent(Settings.ACTION_SETTINGS)
                "camera", "kamera" -> Intent("android.media.action.IMAGE_CAPTURE")
                "phone", "telefon" -> Intent(Intent.ACTION_DIAL)
                else -> pm.getLaunchIntentForPackage(packageNameOrName)
            }

            if (launchIntent != null) {
                launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(launchIntent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun performGlobalAction(action: String): Boolean {
        val service = VoiceAccessibilityService.instance ?: return false
        return when (action.lowercase()) {
            "home" -> service.performHome()
            "back" -> service.performBack()
            "recents" -> service.performRecents()
            "notifications" -> service.performNotifications()
            "scroll_down" -> service.scrollForward()
            "scroll_up" -> service.scrollBackward()
            else -> false
        }
    }

    private fun setSystemVolume(levelPercent: Int) {
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            val target = (maxVolume * (levelPercent / 100.0)).toInt()
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, target, AudioManager.FLAG_SHOW_UI)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
