package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import com.follow.clash.common.VpnTrace
import com.follow.clash.service.modules.ServiceModules

class ProxyService : Service(), ManagedService {
    private val modules = ServiceModules(this)
    private val binder = LocalBinder()

    @Volatile
    private var running = false

    override fun onDestroy() {
        VpnTrace.record("proxy_service.onDestroy", "running=$running")
        try {
            cleanup()
        } finally {
            super.onDestroy()
        }
    }

    override fun onLowMemory() {
        VpnTrace.record("proxy_service.onLowMemory", "running=$running")
        lowCoreMemory()
        super.onLowMemory()
    }

    override fun onTrimMemory(level: Int) {
        VpnTrace.record("proxy_service.onTrimMemory", "level=$level running=$running")
        trimCoreMemory(level)
        super.onTrimMemory(level)
    }

    inner class LocalBinder : Binder() {
        val service: ProxyService
            get() = this@ProxyService
    }

    override fun onBind(intent: Intent): IBinder = binder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        VpnTrace.record(
            "proxy_service.onStartCommand",
            "running=$running flags=$flags startId=$startId action=${intent?.action}",
        )
        if (!running) {
            notifyVpnStartRequested()
        }
        return START_STICKY
    }

    override fun start() {
        VpnTrace.record("proxy_service.start", "running=$running")
        try {
            modules.start()
            running = true
            VpnTrace.record("proxy_service.start.ok", "running=$running")
        } catch (error: Exception) {
            VpnTrace.record("proxy_service.start.fail", "error=$error")
            stop()
            throw error
        }
    }

    override fun stop() {
        VpnTrace.record("proxy_service.stop", "running=$running")
        try {
            cleanup()
        } finally {
            stopSelf()
        }
    }

    private fun cleanup() {
        running = false
        modules.stop()
    }
}
