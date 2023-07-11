package zyz.flutter.plugin.flutter_google_street_view

import android.content.Context
import android.graphics.Point
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.google.android.gms.maps.StreetViewPanorama
import com.google.android.gms.maps.StreetViewPanoramaOptions
import com.google.android.gms.maps.StreetViewPanoramaView
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.StreetViewPanoramaCamera
import com.google.android.gms.maps.model.StreetViewPanoramaLocation
import com.google.android.gms.maps.model.StreetViewPanoramaOrientation
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding.OnSaveInstanceStateListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class FlutterGoogleStreetView(
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?,
    binaryMessenger: BinaryMessenger,
    lifecycleProvider: Lifecycle
) : DefaultLifecycleObserver, OnSaveInstanceStateListener, PlatformView, MethodChannel.MethodCallHandler, StreetViewListener {

    companion object {
        private val lockStreetView = HashMap<StreetViewPanoramaView, Boolean>()
        private val lockPanorama = HashMap<StreetViewPanoramaView, StreetViewPanorama>()
    }

    private val dTag = javaClass.simpleName
    private var disposed = false
    private val initOptions: StreetViewPanoramaOptions?
    private var streetView: StreetViewPanoramaView? = null
    private var streetViewPanorama: StreetViewPanorama? = null
    private val methodChannel: MethodChannel
    private var viewReadyResult: MethodChannel.Result? = null
    private var lastMoveToPos : LatLng? = null
    private var lastMoveToPanoId:String? = null
    private var creationParams: Map<String?, Any?>? = null
    private var reuseStreetView = false
    init {
        this.creationParams = creationParams
        initOptions = createInitOption(creationParams)
        for (it in lockStreetView) {
            Log.d(dTag, "try reuse streetView:${lockStreetView.size}")
            val sv:StreetViewPanoramaView = it.key
            val inUse:Boolean = it.value
            if(!inUse) {
                reuseStreetView = true
                sv.id = id
                streetView = sv
                streetViewPanorama = lockPanorama[sv]
                setupListener(streetViewPanorama!!)
                Log.d(dTag, "reuse streetView:$streetViewPanorama")
                break
            }
        }

        if (streetView == null) {
            streetView = StreetViewPanoramaView(context, initOptions).apply {
                this.id = id
                this.getStreetViewPanoramaAsync {
                    lockPanorama[this] = it
                    streetViewPanorama = it
                    setupListener(it)
                    val hasInitLocation = initOptions?.let { it1 ->
                        it1.panoramaId != null || it1.position != null
                    } ?: false
                    if (viewReadyResult != null && !hasInitLocation) {
                        viewReadyResult?.success(streetViewIsReady())
                        viewReadyResult = null
                    }
                }
            }
        }
        lockStreetView[streetView!!] = true
        methodChannel = MethodChannel(binaryMessenger, "flutter_google_street_view_$id")
        methodChannel.setMethodCallHandler(this)
        lifecycleProvider.addObserver(this)
    }

    private fun createInitOption(creationParams: Map<String?, Any?>?): StreetViewPanoramaOptions? =
        if (creationParams != null) StreetViewPanoramaOptions().apply {
            if (creationParams.containsKey("panoId")) {
                val panoId = (creationParams["panoId"] ?: error("")) as String
                lastMoveToPanoId = panoId
                panoramaId(panoId)
            } else if (creationParams.containsKey("position")) {
                val pos = if (creationParams.containsKey("position")) {
                    val posTmp = Convert.toLatLng(
                        creationParams["position"] ?: error("position data is null!")
                    )
                    lastMoveToPos = posTmp
                    posTmp
                } else null
                val radius = if (creationParams.containsKey("radius")) {
                    Convert.toInt(creationParams["radius"] ?: error("radius data is null!"))
                } else null
                val source = if (creationParams.containsKey("source")) {
                    Convert.toStreetViewSource(
                        creationParams["source"] ?: error("source data is null!")
                    )
                } else null
                if (radius != null && source != null) {
                    position(pos, radius, source)
                } else if (radius == null && source != null) position(pos, source)
                else if (radius != null && source == null) position(pos, radius)
                else position(pos)

            }
            creationParams["panningGesturesEnabled"]?.also { panningGesturesEnabled(it as Boolean) }
            creationParams["streetNamesEnabled"]?.also { streetNamesEnabled(it as Boolean) }
            creationParams["userNavigationEnabled"]?.also { userNavigationEnabled(it as Boolean) }
            creationParams["zoomGesturesEnabled"]?.also { zoomGesturesEnabled(it as Boolean) }

            val zoom = creationParams["zoom"]?.let { Convert.toFloat(it) } ?: 0f
            val tilt = creationParams["tilt"]?.let { Convert.toFloat(it) } ?: 0f
            val bearing = creationParams["bearing"]?.let { Convert.toFloat(it) } ?: 0f
            panoramaCamera(StreetViewPanoramaCamera(zoom, tilt, bearing))

        } else null

    override fun getView(): View {
        return streetView!!
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    private fun removeListener() {
        streetViewPanorama?.setOnStreetViewPanoramaCameraChangeListener(null)
        streetViewPanorama?.setOnStreetViewPanoramaChangeListener(null)
        streetViewPanorama?.setOnStreetViewPanoramaClickListener(null)
        streetViewPanorama?.setOnStreetViewPanoramaLongClickListener(null)
    }

    private fun setupListener(streetViewPanorama: StreetViewPanorama) {
        streetViewPanorama.setOnStreetViewPanoramaCameraChangeListener(this)
        streetViewPanorama.setOnStreetViewPanoramaChangeListener(this)
        streetViewPanorama.setOnStreetViewPanoramaClickListener(this)
        streetViewPanorama.setOnStreetViewPanoramaLongClickListener(this)
    }

    override fun onCreate(owner: LifecycleOwner) {
        if (disposed) {
            return
        }
        if(reuseStreetView){
            streetView?.onResume()
            return
        }
        streetView?.onCreate(null)
    }

    override fun onStart(owner: LifecycleOwner) {
        if (disposed || reuseStreetView) {
            return
        }
        streetView!!.onStart()
    }

    override fun onResume(owner: LifecycleOwner) {
        if (disposed || reuseStreetView) {
            return
        }
        streetView?.onResume()
    }

    override fun onPause(owner: LifecycleOwner) {
        if (disposed) {
            return
        }
        streetView?.onPause()
    }

    override fun onStop(owner: LifecycleOwner) {
        if (disposed) {
            return
        }
        streetView?.onStop()
    }

    override fun onDestroy(owner: LifecycleOwner) {
        owner.lifecycle.removeObserver(this)
        if (disposed) {
            return
        }
        destroyStreetViewIfNecessary()
    }

    override fun onRestoreInstanceState(bundle: Bundle?) {
        if (disposed) {
            return
        }
        streetView?.onCreate(bundle)
    }

    override fun onSaveInstanceState(bundle: Bundle) {
        if (disposed) {
            return
        }
        streetView?.onSaveInstanceState(bundle)
    }

    private fun destroyStreetViewIfNecessary() {
        if (streetView == null) {
            return
        }
        streetView?.onDestroy()
        lockPanorama.remove(streetView)
        lockStreetView.remove(streetView)
        streetView = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
/*        val info = call.let {
            "method:${it.method}, " + if (it.arguments != null) "arg:${it.arguments}" else ""
        }
        Log.d(dTag, "onMethodCall info:$info")*/
        when (call.method) {
            "streetView#waitForStreetView" -> {
                val hasInitLocation = initOptions?.let {
                    it.panoramaId != null || it.position != null
                } ?: false
                //We callback while no init location should
                //otherwise, callback while the
                if (!reuseStreetView) {
                    if (streetView != null && !hasInitLocation) {
                        result.success(streetViewIsReady())
                        return
                    }
                    viewReadyResult = result
                } else {
                    updateInitOptions(creationParams, result)
                }
            }
            "streetView#updateOptions" -> updateInitOptions(call.arguments, result)
            "streetView#animateTo" -> {
                if (streetView != null) {
                    animateTo(call.arguments)
                    result.success(null)
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "animateTo called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#getLocation" -> {
                if (streetView != null) {
                    result.success(getLocation())
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "getLocation called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#getPanoramaCamera" -> {
                if (streetView != null) {
                    result.success(getPanoramaCamera())
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "getPanoramaCamera called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#isPanningGesturesEnabled" -> {
                if (streetView != null) {
                    result.success(isPanningGesturesEnabled())
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "isPanningGesturesEnabled called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#isStreetNamesEnabled" -> {
                if (streetView != null) {
                    result.success(isStreetNamesEnabled())
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "isStreetNamesEnabled called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#isUserNavigationEnabled" -> {
                if (streetView != null) {
                    result.success(isUserNavigationEnabled())
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "isUserNavigationEnabled called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#isZoomGesturesEnabled" -> {
                if (streetView != null) {
                    result.success(isZoomGesturesEnabled())
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "isZoomGesturesEnabled called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#orientationToPoint" -> {
                if (streetView != null) {
                    result.success(orientationToPoint(call.arguments)?.let { Convert.pointToJson(it) })
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "orientationToPoint called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#pointToOrientation" -> {
                if (streetView != null) {
                    result.success(pointToOrientation(call.arguments)?.let {
                        Convert.streetViewPanoramaOrientationToJson(
                            it
                        )
                    })
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "orientationToPoint called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#movePos" -> {
                if (streetView != null) {
                    setPosition(call.arguments)
                    result.success(null)
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "movePos called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#setPanningGesturesEnabled" -> {
                if (streetView != null) {
                    setPanningGesturesEnabled(call.arguments)
                    result.success(null)
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "setPanningGesturesEnabled called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#setStreetNamesEnabled" -> {
                if (streetView != null) {
                    setStreetNamesEnabled(call.arguments)
                    result.success(null)
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "setStreetNamesEnabled called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#setUserNavigationEnabled" -> {
                if (streetView != null) {
                    setUserNavigationEnabled(call.arguments)
                    result.success(null)
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "setUserNavigationEnabled called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#setZoomGesturesEnabled" -> {
                if (streetView != null) {
                    setZoomGesturesEnabled(call.arguments)
                    result.success(null)
                } else {
                    result.error(
                        "StreetView uninitialized",
                        "setZoomGesturesEnabled called prior to streetView initialization",
                        null
                    )
                }
            }
            "streetView#deactivate" -> {
                deactivateStreetView()
                result.success(null)
            }
        }
    }

    private fun streetViewIsReady() = HashMap<String, Any>().apply {
        isPanningGesturesEnabled()?.let { put("isPanningGesturesEnabled", it) }
        isStreetNamesEnabled()?.let { put("isStreetNamesEnabled", it) }
        isUserNavigationEnabled()?.let { put("isUserNavigationEnabled", it) }
        isZoomGesturesEnabled()?.let { put("isZoomGesturesEnabled", it) }
        put("streetViewCount", lockPanorama.size)
    }

    private fun updateInitOptions(arg: Any?, result: MethodChannel.Result) {
        arg?.apply {
            if (this is Map<*, *>) {
                this as Map<String, Any?>

                Log.d(dTag, this.toString())
                setPosition(arg)

                this["panningGesturesEnabled"]?.also { setPanningGesturesEnabled(it)}
                this["streetNamesEnabled"]?.also { setStreetNamesEnabled(it) }
                this["userNavigationEnabled"]?.also { setUserNavigationEnabled(it) }
                this["zoomGesturesEnabled"]?.also { setZoomGesturesEnabled(it) }

                if(this.containsKey("bearing") || this.containsKey("tilt") || this.containsKey("zoom")) {
                    val tmp = hashMapOf<String, Any>()
                    this["bearing"]?.also { tmp["bearing"] = it }
                    this["tilt"]?.also { tmp["tilt"] = it }
                    this["zoom"]?.also { tmp["zoom"] = it }
                    tmp["duration"] = 1
                    animateTo(tmp.toMap())
                }
                result.success(streetViewIsReady())
            }
        }
    }

    private fun animateTo(arg: Any?) {
        arg?.apply {
            if (this is Map<*, *>) {
                this as Map<String, Any?>
                val streetViewPanoramaCamera = StreetViewPanoramaCamera.builder().also {
                    this["bearing"]?.let { it1 ->
                        it.bearing(Convert.toFloat(it1))
                    }
                    this["tilt"]?.let { it1 ->
                        it.tilt(Convert.toFloat(it1))
                    }
                    this["zoom"]?.let { it1 ->
                        it.zoom(Convert.toFloat(it1))
                    }
                }.build()
                if (containsKey("duration"))
                    streetViewPanorama?.animateTo(
                        streetViewPanoramaCamera,
                        Convert.toLong(this["duration"] ?: error("duration data is null!"))
                    )
            }
        }
    }

    private fun getLocation() = streetViewPanorama?.location?.let {
        Convert.streetViewPanoramaLocationToJson(
            it
        )
    }

    private fun getPanoramaCamera() = streetViewPanorama?.panoramaCamera?.let {
        Convert.streetViewPanoramaCameraToJson(
            it
        )
    }

    private fun isPanningGesturesEnabled() = streetViewPanorama?.isPanningGesturesEnabled

    private fun isStreetNamesEnabled() = streetViewPanorama?.isStreetNamesEnabled

    private fun isUserNavigationEnabled() = streetViewPanorama?.isUserNavigationEnabled

    private fun isZoomGesturesEnabled() = streetViewPanorama?.isZoomGesturesEnabled

    private fun orientationToPoint(arg: Any?): Point? {
        return arg?.let {
            return if (it is Map<*, *>) {
                it as Map<String, Any?>
                val bearing = if (it.containsKey("bearing"))
                    Convert.toFloat(it["bearing"] ?: error("")) else null
                val tilt = if (it.containsKey("tilt"))
                    Convert.toFloat(it["tilt"] ?: error("")) else null
                streetViewPanorama?.orientationToPoint(
                    StreetViewPanoramaOrientation(
                        tilt!!,
                        bearing!!
                    )
                )
            } else null
        }
    }


    private fun pointToOrientation(arg: Any?) = arg?.let {
        if (it is List<*>) {
            it as List<Double>
            val p = Point(Convert.toInt(it[0]), Convert.toInt(it[1]))
            streetViewPanorama?.pointToOrientation(p)
        } else null
    }

    private fun setPosition(arg: Any?) {
        arg?.apply {
            if (this is Map<*, *>) {
                this as Map<String, Any?>
                val target = if (containsKey("position")) {
                    Convert.toLatLng(this["position"] ?: error("position data is null!"))
                } else null
                val panoId = if (containsKey("panoId")) {
                    Convert.toString(this["panoId"] ?: error("panoId data is null!"))
                } else null
                val radius = if (containsKey("radius")) {
                    Convert.toInt(this["radius"] ?: error("radius data is null!"))
                } else null
                val source = if (containsKey("source")) {
                    Convert.toStreetViewSource(
                        this["source"] ?: error("source data is null!")
                    )
                } else null
                //Log.d(dTag, "target:$target, panoId:$panoId, radius:$radius, source:$source")
                if ((target != null || panoId != null) && (target == null || panoId == null)) {
                    if (target != null) {
                        lastMoveToPos = target
                        if (radius != null) {
                            streetViewPanorama?.setPosition(target, radius, source)
                        } else streetViewPanorama?.setPosition(target, source)
                    } else if (panoId != null) {
                        lastMoveToPanoId = panoId
                        streetViewPanorama?.setPosition(panoId)
                    }
                }
            }
        }
    }

    private fun setPanningGesturesEnabled(arg: Any?) {
        arg?.apply {
            if (this is Boolean) {
                streetViewPanorama?.isPanningGesturesEnabled = this
            }
        }
    }

    private fun setStreetNamesEnabled(arg: Any?) {
        arg?.apply {
            if (this is Boolean) {
                streetViewPanorama?.isStreetNamesEnabled = this
            }
        }
    }

    private fun setUserNavigationEnabled(arg: Any?) {
        arg?.apply {
            if (this is Boolean) {
                streetViewPanorama?.isUserNavigationEnabled = this
            }
        }
    }

    private fun setZoomGesturesEnabled(arg: Any?) {
        arg?.apply {
            if (this is Boolean) {
                streetViewPanorama?.isZoomGesturesEnabled = this
            }
        }
    }

    private fun deactivateStreetView() {
        removeListener()
        lockStreetView[streetView!!] = false
        // reset control setting
        streetViewPanorama?.isZoomGesturesEnabled = true
        streetViewPanorama?.isPanningGesturesEnabled = true
        streetViewPanorama?.isStreetNamesEnabled = true
        streetViewPanorama?.isUserNavigationEnabled = true
        // reset pitch, heading and zoom
        streetViewPanorama?.animateTo(
            StreetViewPanoramaCamera.builder().also {
                it.bearing(0f)
                it.tilt(0f)
                it.zoom(0f)
            }.build(),
            10
        )
        // set the position with panorama to make a black view
        streetViewPanorama?.setPosition(LatLng(-45.125783, 151.276417))
        streetView?.onStop()
    }

    override fun onStreetViewPanoramaCameraChange(camera: StreetViewPanoramaCamera) {
        methodChannel.invokeMethod(
            "camera#onChange",
            Convert.streetViewPanoramaCameraToJson(camera)
        )
    }

    override fun onStreetViewPanoramaChange(location: StreetViewPanoramaLocation) {
        if (viewReadyResult != null) {
            val hasInitLocation = initOptions?.let { it1 ->
                it1.panoramaId != null || it1.position != null
            }  ?: false
            if(hasInitLocation) {
                viewReadyResult?.success(streetViewIsReady())
                viewReadyResult = null
            }
        }
        val arg = location?.let {
            Convert.streetViewPanoramaLocationToJson(
                it
            )
        } ?: mutableMapOf<String, Any>().apply {
            val errorMsg = if (lastMoveToPos != null)
                "Oops..., no valid panorama found with position:${lastMoveToPos!!.latitude}, ${lastMoveToPos!!.longitude}, try to change `position`, `radius` or `source`."
            else if (lastMoveToPanoId != null)
                "Oops..., no valid panorama found with panoId:$lastMoveToPanoId, try to change `panoId`."
            else "Oops..., no valid panorama found."
            put("error", errorMsg)
        }
        methodChannel.invokeMethod(
            "pano#onChange", arg
        )
    }

    override fun onStreetViewPanoramaClick(orientation: StreetViewPanoramaOrientation) {
        methodChannel.invokeMethod(
            "pano#onClick", Convert.streetViewPanoramaOrientationToJson(
                orientation
            ).apply {
                streetViewPanorama?.orientationToPoint(orientation)?.let {
                    putAll(Convert.pointToJson(it)!!)
                }
            }
        )
    }

    override fun onStreetViewPanoramaLongClick(orientation: StreetViewPanoramaOrientation) {
        methodChannel.invokeMethod(
            "pano#onLongClick", Convert.streetViewPanoramaOrientationToJson(
                orientation
            ).apply {
                streetViewPanorama?.orientationToPoint(orientation)?.let {
                    putAll(Convert.pointToJson(it)!!)
                }
            }
        )
    }

}

interface StreetViewListener : StreetViewPanorama.OnStreetViewPanoramaCameraChangeListener,
    StreetViewPanorama.OnStreetViewPanoramaChangeListener,
    StreetViewPanorama.OnStreetViewPanoramaClickListener,
    StreetViewPanorama.OnStreetViewPanoramaLongClickListener