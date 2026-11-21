package com.follow.clash

import android.app.Application
import android.content.Context
import com.follow.clash.common.GlobalState
import com.follow.clash.common.VpnTrace

class FlClashApplication : Application() {
    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }

    override fun onCreate() {
        super.onCreate()
        VpnTrace.record("app.create", "lastExit=${GlobalState.lastExitInfo()}")
    }
}
