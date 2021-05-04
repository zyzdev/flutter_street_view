package zyz.flutter.plugin.flutter_google_street_view

import android.graphics.Point
import com.google.android.gms.maps.model.*
import java.util.*

object Convert {

    fun toLatLng(o: Any): LatLng? {
        val data: List<*> = toList(o)
        return if (data.size == 2)
            LatLng(toDouble(data[0]!!), toDouble(data[1]!!))
        else null
    }

    fun toStreetViewSource(o: Any): StreetViewSource =
        if (o == "outdoor") StreetViewSource.OUTDOOR else StreetViewSource.DEFAULT

    fun toString(o: Any): String = o.toString()

    private fun toList(o: Any): List<*> {
        return o as List<*>
    }

    fun toInt(o: Any): Int {
        return (o as Number).toInt()
    }

    fun toLong(o: Any): Long {
        return (o as Number).toLong()
    }

    fun toFloat(o: Any): Float {
        return (o as Number).toFloat()
    }

    fun toDouble(o: Any): Double {
        return (o as Number).toDouble()
    }

    private fun streetViewPanoramaLocationToJson(o: StreetViewPanoramaLink): ArrayList<Any> {
        return arrayListOf(o.panoId, o.bearing);
    }

    private fun latLngToJson(latLng: LatLng): Any {
        return listOf(latLng.latitude, latLng.longitude)
    }

    fun pointToJson(point: Point): Map<String, Int>? {
        val data: MutableMap<String, Int> = HashMap(2)
        data["x"] = point.x
        data["y"] = point.y
        return data
    }

    fun streetViewPanoramaCameraToJson(streetViewPanoramaCamera: StreetViewPanoramaCamera): MutableMap<String, Any> {
        val arguments: MutableMap<String, Any> = HashMap(3)
        arguments["bearing"] = streetViewPanoramaCamera.bearing
        arguments["tilt"] = streetViewPanoramaCamera.tilt
        arguments["zoom"] = streetViewPanoramaCamera.zoom
        return arguments
    }

    fun streetViewPanoramaLocationToJson(streetViewPanoramaLocation: StreetViewPanoramaLocation): MutableMap<String, Any> {
        val arguments: MutableMap<String, Any> = HashMap(3)
        arguments["links"] = ArrayList<Any>().apply {
            streetViewPanoramaLocation.links.forEach {
                add(streetViewPanoramaLocationToJson(it))
            }
        }
        arguments["panoId"] = streetViewPanoramaLocation.panoId
        arguments["position"] = latLngToJson(streetViewPanoramaLocation.position)
        return arguments
    }

    fun streetViewPanoramaOrientationToJson(streetViewPanoramaOrientation: StreetViewPanoramaOrientation): MutableMap<String, Any> {
        val arguments: MutableMap<String, Any> = HashMap(2)
        arguments["bearing"] = streetViewPanoramaOrientation.bearing
        arguments["tilt"] = streetViewPanoramaOrientation.tilt
        return arguments
    }
}