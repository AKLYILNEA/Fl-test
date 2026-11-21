package com.follow.clash

import com.follow.clash.common.RunIntentArbiter
import com.follow.clash.models.SharedState
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import com.google.gson.Gson
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlin.coroutines.resume

enum class RunState {
    STARTED,
    STARTING,
    STOPPING,
    STOPPED,
}

internal typealias RunRequest = RunIntentArbiter.Token

internal const val MISSING_CONFIG_MESSAGE = "No configuration found."
internal const val INVALID_CONFIG_MESSAGE = "Invalid configuration."
internal const val VPN_PERMISSION_MESSAGE = "VPN permission required."
internal const val START_FAILED_MESSAGE = "Failed to start service."

private enum class StartOutcome {
    STARTED,
    FAILED,
    SUPERSEDED,
}

internal enum class StartFailure(val code: String) {
    VPN_PERMISSION("vpn_permission"),
    SERVICE("service"),
}

/**
 * Callers request a transition; the newest request always wins. No step assigns [runState]:
 * [publish] derives it from the latest intent, the transition in flight and what the host really
 * runs, so no path can leave it claiming a service that is not there.
 */
internal class ServiceStateMachine(private val host: ServiceStateHost) {
    private val transitionLock = Mutex()
    private val startPreparationLock = Mutex()
    private val mutableRunState = MutableStateFlow(RunState.STOPPED)
    private val arbiter = RunIntentArbiter()

    @Volatile
    private var sharedState = SharedState()

    @Volatile
    private var pendingVpnPreparation: (() -> Unit)? = null

    @Volatile
    private var transition: RunState? = null

    val runState = mutableRunState.asStateFlow()

    val isRunRequested: Boolean
        get() = arbiter.isRunningRequested

    suspend fun handleToggleAction() {
        host.log("[VPN-TRACE] handleToggleAction runRequested=$isRunRequested runState=${runState.value}")
        if (isRunRequested) {
            handleStopAction()
        } else {
            handleStartAction()
        }
    }

    suspend fun awaitRunningService(): ServiceRuntime? = transitionLock.withLock {
        host.runtime?.takeIf { isRunRequested }
    }

    fun captureRequestToken(): RunRequest = arbiter.current()

    /**
     * Settles the state after the bound service was lost. [token] is the request that was current
     * when the loss was observed, so a start that raced ahead of this callback keeps its intent.
     */
    suspend fun handleServiceLost(token: RunRequest) {
        host.log("[VPN-TRACE] handleServiceLost enter token=$token runtime=${host.runtime != null} runRequested=$isRunRequested runState=${runState.value}")
        val dropped = transitionLock.withLock {
            if (host.runtime != null) {
                return@withLock false
            }
            arbiter.resetToStopped(token).also { publish() }
        }
        host.log("[VPN-TRACE] handleServiceLost done dropped=$dropped runState=${runState.value}")
        if (dropped) {
            host.notifyStopped()
        }
    }

    suspend fun handleStartAction() {
        host.log("[VPN-TRACE] handleStartAction runRequested=$isRunRequested hasTile=${host.tile() != null} runState=${runState.value}")
        if (isRunRequested) {
            return
        }
        val tile = host.tile()
        if (tile != null) {
            tile.handleStart()
            return
        }
        startFromPreferences()
    }

    suspend fun handleStopAction() {
        host.log("[VPN-TRACE] handleStopAction runRequested=$isRunRequested runState=${runState.value}")
        if (!isRunRequested) {
            return
        }
        host.showToast(sharedState.stopTip)
        requestStop().await()
        host.notifyStopped()
    }

    suspend fun handleVpnRevokeAction() {
        host.log("[VPN-TRACE] handleVpnRevokeAction runtimeVpn=${host.runtime?.vpn} runRequested=$isRunRequested")
        if (host.runtime?.vpn != true) {
            return
        }
        handleStopAction()
    }

    fun requestStart(): Deferred<Boolean> {
        val alreadyStarted = isStartedAs(sharedState.vpnOptions)
        host.log("[VPN-TRACE] requestStart alreadyStarted=$alreadyStarted runState=${runState.value} vpn=${sharedState.vpnOptions?.enable} runtimeVpn=${host.runtime?.vpn}")
        if (alreadyStarted) {
            return CompletableDeferred(true)
        }
        val outcome = launchStart(createRequest(running = true))
        return host.scope.async { outcome.await() == StartOutcome.STARTED }
    }

    fun requestStop(): Deferred<Boolean> {
        host.log("[VPN-TRACE] requestStop runState=${runState.value} runtime=${host.runtime != null} runRequested=$isRunRequested")
        val request = createRequest(running = false)
        return host.scope.async { stop(request) }
    }

    fun syncSharedState(state: SharedState) {
        sharedState = state
        applySharedState()
    }

    // No new request for a settled run: one refused at a prompt would take the service down.
    private fun isStartedAs(options: VpnOptions?): Boolean =
        runState.value == RunState.STARTED && host.runtime?.vpn == options?.enable

    // The intent is claimed before the Core is set up, so a second action that lands meanwhile
    // toggles this start off instead of racing a second setup against it.
    private suspend fun startFromPreferences() {
        val request = createRequest(running = true)
        sharedState = host.loadSharedState()
        if (sharedState.setupParams == null || sharedState.vpnOptions == null) {
            host.showToast(MISSING_CONFIG_MESSAGE)
            abandon(request)
            return
        }
        if (!setupCore()) {
            abandon(request)
        } else if (launchStart(request).await() == StartOutcome.FAILED) {
            host.showToast(START_FAILED_MESSAGE)
        }
    }

    private fun launchStart(request: RunRequest): Deferred<StartOutcome> {
        val result = CompletableDeferred<StartOutcome>()
        val launch: (Boolean) -> Unit = { permitted ->
            host.log("[VPN-TRACE] launchStart permitted=$permitted runState=${runState.value} isCurrent=${isCurrent(request)}")
            host.scope.launch {
                result.complete(if (permitted) start(request) else abandon(request))
            }
        }
        val app = host.app()
        if (app != null) {
            app.requestNotificationPermission { permitted ->
                if (permitted) {
                    app.requestLocalNetworkPermission { launch(true) }
                } else {
                    launch(false)
                }
            }
        } else {
            launch(true)
        }
        return result
    }

    private fun applySharedState() {
        host.updateNotificationParams(notificationParams(sharedState))
    }

    private suspend fun setupCore(): Boolean {
        applySharedState()
        host.showToast(sharedState.startTip)
        return host.quickSetup(
            initParams(host.homeDirPath, host.sdkInt),
            Gson().toJson(sharedState.setupParams),
        ).fold(
            onSuccess = { message ->
                if (message.isEmpty()) {
                    true
                } else {
                    host.log("Unable to set up core: $message")
                    showConfigError(message)
                    false
                }
            },
            onFailure = { error ->
                host.log("Unable to set up core: $error")
                showConfigError(error.message)
                false
            },
        )
    }

    private fun showConfigError(message: String?) {
        host.showToast(message?.takeIf { it.isNotBlank() } ?: INVALID_CONFIG_MESSAGE)
    }

    private suspend fun start(request: RunRequest): StartOutcome {
        val failure = try {
            startPreparationLock.withLock { runStart(request) }
        } catch (error: CancellationException) {
            throw error
        } catch (error: Exception) {
            host.log("Unable to process service start request: $error")
            StartFailure.SERVICE
        }
        return if (failure == null) StartOutcome.STARTED else abandon(request, failure)
    }

    private suspend fun abandon(request: RunRequest, failure: StartFailure? = null): StartOutcome {
        val dropped = arbiter.resetToStopped(request)
        host.log("[VPN-TRACE] abandon failure=${failure?.code} dropped=$dropped runState=${runState.value} runtime=${host.runtime != null}")
        reconcileStopped()
        if (!dropped) {
            return StartOutcome.SUPERSEDED
        }
        host.notifyStopped(failure)
        return StartOutcome.FAILED
    }

    /** Null once the service runs as asked; a request no longer current is never reported. */
    private suspend fun runStart(request: RunRequest): StartFailure? {
        if (!isCurrent(request)) {
            host.log("[VPN-TRACE] runStart skipped: not current before prepare")
            return StartFailure.SERVICE
        }
        val options = sharedState.vpnOptions ?: run {
            host.log("[VPN-TRACE] runStart failed: vpnOptions null")
            return StartFailure.SERVICE
        }
        if (!prepareVpn(options)) {
            host.log("[VPN-TRACE] runStart failed: prepareVpn denied hasApp=${host.app() != null} isCurrent=${isCurrent(request)}")
            if (host.app() == null && isCurrent(request)) {
                host.showToast(VPN_PERMISSION_MESSAGE)
            }
            return StartFailure.VPN_PERMISSION
        }
        return transitionLock.withLock {
            when {
                !isCurrent(request) -> {
                    host.log("[VPN-TRACE] runStart skipped: not current in transitionLock")
                    StartFailure.SERVICE
                }
                host.runtime?.vpn == options.enable -> {
                    host.log("[VPN-TRACE] runStart already running vpn=${options.enable}")
                    null
                }
                else -> transitioning(RunState.STARTING) {
                    val started = host.startService(withLocalNetworkFallback(options))
                    val stillCurrent = isCurrent(request)
                    host.log("[VPN-TRACE] runStart startService=$started stillCurrent=$stillCurrent")
                    StartFailure.SERVICE.takeUnless { started && stillCurrent }
                }
            }
        }
    }

    // system/mixed hand TCP to the kernel via the tun subnet, which Android 17 gates as local network.
    private fun withLocalNetworkFallback(options: VpnOptions): VpnOptions {
        if (!options.enable || options.stack !in KERNEL_TCP_STACKS ||
            host.isLocalNetworkPermissionGranted()
        ) {
            return options
        }
        host.showToast(sharedState.localNetworkTip)
        return options.copy(stack = FALLBACK_STACK)
    }

    // Flutter's startListener and the native quickSetup both open the Core's listeners before any
    // service exists to answer for them, and Flutter may be gone before it hears of the failure.
    private suspend fun reconcileStopped() = transitionLock.withLock {
        host.log("[VPN-TRACE] reconcileStopped runRequested=$isRunRequested runtime=${host.runtime != null}")
        when {
            isRunRequested -> publish()
            host.runtime != null -> stopLocked()
            else -> {
                stopService()
                publish()
            }
        }
    }

    private suspend fun stop(request: RunRequest): Boolean = transitionLock.withLock {
        val current = isCurrent(request)
        host.log("[VPN-TRACE] stop isCurrent=$current runtime=${host.runtime != null}")
        if (!current) {
            return@withLock false
        }
        abandonVpnPreparation()
        if (host.runtime != null) {
            stopLocked()
        }
        isCurrent(request)
    }

    private suspend fun stopLocked() = transitioning(RunState.STOPPING) { stopService() }

    private suspend fun stopService() {
        try {
            host.stopService()
        } catch (error: CancellationException) {
            throw error
        } catch (error: Exception) {
            host.log("Unable to stop service: $error")
        }
    }

    private inline fun <T> transitioning(state: RunState, block: () -> T): T {
        transition = state
        publish()
        try {
            return block()
        } finally {
            transition = null
            publish()
        }
    }

    @Synchronized
    private fun publish() {
        mutableRunState.value = transition ?: when {
            host.runtime == null -> RunState.STOPPED
            isRunRequested -> RunState.STARTED
            else -> RunState.STOPPING
        }
    }

    private suspend fun prepareVpn(options: VpnOptions): Boolean {
        val app = host.app()
            ?: return !options.enable || host.isVpnPermissionGranted()
        return suspendCancellableCoroutine { continuation ->
            val callback: (Boolean) -> Unit = { granted ->
                pendingVpnPreparation = null
                if (continuation.isActive) {
                    continuation.resume(granted)
                }
            }
            pendingVpnPreparation = {
                app.cancelVpnPreparation(callback)
                callback(false)
            }
            continuation.invokeOnCancellation {
                pendingVpnPreparation = null
                app.cancelVpnPreparation(callback)
            }
            app.prepareVpn(options.enable, callback)
        }
    }

    private fun abandonVpnPreparation() {
        val abandon = pendingVpnPreparation ?: return
        pendingVpnPreparation = null
        abandon()
    }

    private fun createRequest(running: Boolean): RunRequest =
        arbiter.request(running).also { publish() }

    private fun isCurrent(request: RunRequest): Boolean = arbiter.isCurrent(request)

    internal companion object {
        val KERNEL_TCP_STACKS = setOf("system", "mixed")
        const val FALLBACK_STACK = "gvisor"

        /**
         * The Core init payload. The key spelling is a cross-language contract with the Go wrapper,
         * not an implementation detail.
         */
        fun initParams(homeDirPath: String, sdkInt: Int): String = Gson().toJson(
            mapOf(
                "home-dir" to homeDirPath,
                "version" to sdkInt,
            ),
        )

        fun notificationParams(state: SharedState): NotificationParams = NotificationParams(
            title = state.currentProfileName,
            stopText = state.stopText,
            onlyStatisticsProxy = state.onlyStatisticsProxy,
            showStopAction = state.showStopAction,
        )
    }
}
