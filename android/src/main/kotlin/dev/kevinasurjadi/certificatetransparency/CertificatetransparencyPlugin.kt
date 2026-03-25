package dev.kevinasurjadi.certificatetransparency

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.appmattus.certificatetransparency.CTLogger
import com.appmattus.certificatetransparency.VerificationResult
import com.appmattus.certificatetransparency.certificateTransparencyHostnameVerifier
import com.appmattus.certificatetransparency.loglist.LogListDataSourceFactory

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import javax.net.ssl.HttpsURLConnection

/** CertificatetransparencyPlugin */
class CertificatetransparencyPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private var threadExecutorService: ExecutorService? = null
  private var handler: Handler? = null
  private var message: String? = null

  private val defaultLogger = object : CTLogger {
    override fun log(host: String, result: VerificationResult) {
      message = result.toString()
    }
  }

  init {
    threadExecutorService = Executors.newSingleThreadExecutor()
    handler = Handler(Looper.getMainLooper())
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "certificatetransparency")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    try {
      when (call.method) {
        "check" -> threadExecutorService?.execute {
          handleCheckEvent(call, result)
        }
        else -> result.notImplemented()
      }  
    } catch (e: Exception) {
      handler?.post {
        result.error(e.toString(), "", "")
      }
    }
  }

  private fun HttpURLConnection.enableCertificateTransparencyChecks(includeHosts: Set<String>, excludeHosts: Set<String>, logListBaseUrl: String) {
    if (this is HttpsURLConnection) {
      hostnameVerifier = certificateTransparencyHostnameVerifier(hostnameVerifier) {
        excludeHosts.forEach {
          -it
        }
        includeHosts.forEach {
          +it
        }
        logger = defaultLogger
        logListService {
          LogListDataSourceFactory.createLogListService(
                  baseUrl = logListBaseUrl
          )
        }
      }
    }
  }

  private fun handleCheckEvent(call: MethodCall, result: Result) {
    val arguments: HashMap<String, Any> = call.arguments as HashMap<String, Any>
    val hostname: String = arguments.get("hostname") as String
    val includeHosts = arguments.get("includeHosts") as List<String>
    val excludeHosts = arguments.get("excludeHosts") as List<String>
    val logListBaseUrl: String = arguments.get("logListBaseUrl") as String

    val response = hashMapOf<String, Any>("success" to false, "message" to "")
    try {
      val connection = URL(hostname).openConnection() as HttpURLConnection
      connection.enableCertificateTransparencyChecks(includeHosts.toSet(), excludeHosts.toSet(), logListBaseUrl)
      connection.connect()

      response["success"] = true;
      response["message"] = "Connection secure, $message"
      handler?.post {
        result.success(response)
      }
    } catch (e: IOException) {
      response["success"] = false;
      response["message"] = "Connection insecure, $message"
      handler?.post {
        result.success(response)
      }
    }
  }  

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
