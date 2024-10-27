package expo.modules.tdlibrn

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import expo.modules.kotlin.Promise
import org.json.JSONObject
import com.sun.jna.Library
import com.sun.jna.Native
import com.sun.jna.Pointer
import com.sun.jna.Callback
import kotlinx.coroutines.*



interface TdJsonLibrary : Library {
    fun td_create_client_id(): Int
    fun td_receive(timeout: Double): Pointer
    fun td_send(clientId: Int, request: String)
    fun td_execute(request: String): Pointer
    // TODO: I don't care about this right now, but we'll have to fix it. Latest attempt to enable this crashed the app.
    // fun td_set_log_message_callback(verbosityLevel: Int, callback: LogMessageCallback)

    // interface LogMessageCallback : Callback {
    //     fun invoke(verbosityLevel: Int, message: Pointer)
    // }
}

val tdjson: TdJsonLibrary = Native.load("tdjson", TdJsonLibrary::class.java)


class TdClient(private val callback: (String) -> Unit) {
    private val scope = CoroutineScope(Dispatchers.Default + Job())
    private val clientId: Int = tdjson.td_create_client_id()
    private var isClosing = false
    private var isStarted = false

    fun start() {
        isStarted = true
        scope.launch {
            while (isActive) {
                receive()
            }
        }
    }

    fun send(query: String) {
        if (isClosing) return
        tdjson.td_send(clientId, query)
    }

    private fun receive() {
        if (isClosing) return

        while (true) {
            val pointer = tdjson.td_receive(0.0)
            if (pointer == null) break
            
            val msg = pointer.getString(0)
            if (msg.isEmpty()) break

            if (msg.contains("\"@type\":\"updateAuthorizationState\"") && 
                msg.contains("\"@type\":\"authorizationStateClosed\"")) {
                close()
                break
            }
            callback(msg)
        }
    }

    private fun close() {
        isClosing = true
        if (isStarted) {
            scope.cancel()
        }
    }

    fun destroy() {
        close()
        scope.cancel()
    }
}


class TdlibRnModule : Module() {
    private var client: TdClient? = null
    private var queryId = 0
    private val queryCallbacks = mutableMapOf<Int, Promise>()

    override fun definition() = ModuleDefinition {
        Name("TdlibRn")

        Events("tdLibUpdate")

        Function("init") {
            client = TdClient { response ->
                handleResponse(response)
            }
            client?.start()
            return@Function 1
        }

        AsyncFunction("send") { query: String, promise: Promise ->
            queryId++
            queryCallbacks[queryId] = promise
            
            val jsonQuery = JSONObject(query)
            jsonQuery.put("@extra", queryId)
            
            client?.send(jsonQuery.toString())
        }

        Function("destroy") {
            client?.destroy()
            queryCallbacks.clear()
            client = null
            return@Function 1
        }
    }

    private fun handleResponse(response: String) {
        val jsonResponse = JSONObject(response)
        val extra = jsonResponse.optJSONObject("@extra")
        
        if (extra != null) {
            val queryId = extra.getInt("query_id")
            val promise = queryCallbacks.remove(queryId)
            
            if (jsonResponse.optString("@type") == "error") {
                promise?.reject("ERROR", response, null)
            } else {
                promise?.resolve(response)
            }
        } else {
            sendEvent("tdLibUpdate", mapOf("data" to response))
        }
    }
}