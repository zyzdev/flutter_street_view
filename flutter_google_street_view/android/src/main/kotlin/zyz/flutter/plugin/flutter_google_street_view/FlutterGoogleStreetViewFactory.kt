package zyz.flutter.plugin.flutter_google_street_view

import android.content.Context
import androidx.lifecycle.Lifecycle
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterGoogleStreetViewFactory(private val binaryMessenger: BinaryMessenger,
                                     private val lifecycleProvider: Lifecycle
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return FlutterGoogleStreetView(context!!, id, creationParams, binaryMessenger, lifecycleProvider)
    }
}