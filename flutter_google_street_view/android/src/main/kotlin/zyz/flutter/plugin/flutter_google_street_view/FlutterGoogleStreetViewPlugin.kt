package zyz.flutter.plugin.flutter_google_street_view

import android.app.Activity
import android.app.Application.ActivityLifecycleCallbacks
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter


/** FlutterGoogleStreetViewPlugin */
class FlutterGoogleStreetViewPlugin: ActivityLifecycleCallbacks,
  FlutterPlugin,
  ActivityAware,
  DefaultLifecycleObserver{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private var pluginBinding: FlutterPluginBinding? = null

  private var lifecycle: Lifecycle? = null
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = flutterPluginBinding
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {

  }

  override fun onActivityCreated(p0: Activity, p1: Bundle?) {

  }

  override fun onActivityStarted(p0: Activity) {

  }

  override fun onActivityResumed(p0: Activity) {

  }

  override fun onActivityPaused(p0: Activity) {

  }

  override fun onActivityStopped(p0: Activity) {

  }

  override fun onActivitySaveInstanceState(p0: Activity, p1: Bundle) {

  }

  override fun onActivityDestroyed(p0: Activity) {

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding) as Lifecycle
    lifecycle?.addObserver(this)
    pluginBinding?.apply {
      platformViewRegistry.registerViewFactory(
        "my_street_view", FlutterGoogleStreetViewFactory(binaryMessenger, lifecycle!!)
      )
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {

  }

  override fun onDetachedFromActivity() {

  }

}
