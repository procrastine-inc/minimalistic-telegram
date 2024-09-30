package expo.modules.tdlibrn

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import com.sun.jna.Library
import com.sun.jna.Native
import com.sun.jna.Pointer
import com.sun.jna.Callback

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

class TdlibRnModule : Module() {
//   private var logMessageCallback: TdJsonLibrary.LogMessageCallback? = null

  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  override fun definition() = ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('TdlibRn')` in JavaScript.
    Name("TdlibRn")

    Function("createClientId") {
        tdjson.td_create_client_id()
    }

    Function("receive") { timeout: Double ->
        tdjson.td_receive(timeout).getString(0)
    }

    Function("send") { clientId: Int, request: String ->
        tdjson.td_send(clientId, request)
    }

    Function("execute") { request: String ->
        tdjson.td_execute(request).getString(0)
    }

    // Function("setLogMessageCallback") { verbosityLevel: Int, callback: (Int, String) -> Unit ->
    //   logMessageCallback = object : TdJsonLibrary.LogMessageCallback {
    //       override fun invoke(verbosityLevel: Int, message: Pointer) {
    //           callback(verbosityLevel, message.getString(0))
    //       }
    //   }
    //   tdjson.td_set_log_message_callback(verbosityLevel, logMessageCallback)
    // }
  }
}
