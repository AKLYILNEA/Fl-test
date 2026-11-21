package com.follow.clash.common

import android.os.Process
import android.util.Log
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object VpnTrace {
    private const val TAG = "FlClashVpnTrace"
    private const val MAX_ENTRIES = 200
    private const val MAX_FILE_BYTES = 256 * 1024L

    private val lock = Any()
    private val buffer = ArrayDeque<String>(MAX_ENTRIES)
    private val timeFormat = ThreadLocal.withInitial {
        SimpleDateFormat("HH:mm:ss.SSS", Locale.US)
    }

    @Volatile
    private var sink: ((String) -> Unit)? = null

    fun record(event: String, detail: String = "") {
        val ts = timeFormat.get()?.format(Date()).orEmpty()
        val pid = runCatching { Process.myPid() }.getOrDefault(-1)
        val tid = runCatching { Process.myTid() }.getOrDefault(-1)
        val line = buildString {
            append("[VPN-TRACE][ANDROID] ")
            append(ts)
            append(" | pid=")
            append(pid)
            append(" tid=")
            append(tid)
            append(" | ")
            append(event)
            if (detail.isNotEmpty()) {
                append(" | ")
                append(detail)
            }
        }
        runCatching { Log.w(TAG, line) }
        val activeSink: ((String) -> Unit)?
        synchronized(lock) {
            if (buffer.size >= MAX_ENTRIES) {
                buffer.removeFirst()
            }
            buffer.addLast(line)
            appendToFileLocked(line)
            activeSink = sink
        }
        activeSink?.let { target ->
            runCatching { target(line) }
        }
    }

    fun attachSink(nextSink: (String) -> Unit) {
        val snapshot: List<String>
        synchronized(lock) {
            sink = nextSink
            snapshot = buffer.toList()
        }
        snapshot.forEach { line ->
            runCatching { nextSink(line) }
        }
    }

    fun detachSink(target: (String) -> Unit) {
        synchronized(lock) {
            if (sink === target) {
                sink = null
            }
        }
    }

    private fun appendToFileLocked(line: String) {
        runCatching {
            val file = File(GlobalState.application.filesDir, "vpn_trace.log")
            if (file.exists() && file.length() > MAX_FILE_BYTES) {
                val tail = file.readLines().takeLast(MAX_ENTRIES / 2)
                file.writeText(tail.joinToString("\n", postfix = "\n"))
            }
            file.appendText("$line\n")
        }
    }
}
