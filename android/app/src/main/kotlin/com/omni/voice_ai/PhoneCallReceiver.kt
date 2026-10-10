package com.omni.voice_ai

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager

class PhoneCallReceiver : BroadcastReceiver() {

    companion object {
        var lastState = TelephonyManager.CALL_STATE_IDLE
        var onCallStateChangedListener: ((state: String, incomingNumber: String?) -> Unit)? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

            when (stateStr) {
                TelephonyManager.EXTRA_STATE_RINGING -> {
                    onCallStateChangedListener?.invoke("RINGING", number)
                }
                TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                    onCallStateChangedListener?.invoke("OFFHOOK", number)
                }
                TelephonyManager.EXTRA_STATE_IDLE -> {
                    onCallStateChangedListener?.invoke("IDLE", number)
                }
            }
        }
    }
}
