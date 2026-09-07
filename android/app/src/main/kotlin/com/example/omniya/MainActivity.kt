package com.example.omniya

import android.content.Context
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address

class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL = "router_gateway"
    }

    // ============================================================
    // FLUTTER ENGINE
    // ============================================================

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        println("========================================")
        println("[Omniya] Flutter Engine configured")
        println("[Omniya] Activity: FlutterFragmentActivity")
        println("========================================")

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            println("========================================")
            println("[RouterGateway] Method received")
            println("[RouterGateway] Method: ${call.method}")
            println("========================================")

            when (call.method) {

                "getNetworkInfo" -> {

                    try {

                        println(
                            "[RouterGateway] Getting network information..."
                        )

                        getNetworkInfo(result)

                    } catch (e: Exception) {

                        e.printStackTrace()

                        println(
                            "[RouterGateway] ERROR: ${e.message}"
                        )

                        result.error(
                            "NETWORK_ERROR",
                            e.message
                                ?: "حدث خطأ أثناء قراءة معلومات الشبكة",
                            null
                        )
                    }
                }

                else -> {

                    println(
                        "[RouterGateway] Unknown method: ${call.method}"
                    )

                    result.notImplemented()
                }
            }
        }
    }

    // ============================================================
    // GET NETWORK INFO
    // ============================================================

    private fun getNetworkInfo(
        result: MethodChannel.Result
    ) {

        try {

            println("")
            println("========================================")
            println("[RouterGateway] START")
            println("========================================")

            // ====================================================
            // CONNECTIVITY MANAGER
            // ====================================================

            val connectivityManager =
                getSystemService(
                    Context.CONNECTIVITY_SERVICE
                ) as ConnectivityManager

            // ====================================================
            // ACTIVE NETWORK
            // ====================================================

            val network: Network =
                connectivityManager.activeNetwork
                    ?: run {

                        println(
                            "[RouterGateway] ERROR: No active network"
                        )

                        result.error(
                            "NO_NETWORK",
                            "لا يوجد اتصال بالشبكة",
                            null
                        )

                        return
                    }

            println(
                "[RouterGateway] Active network found"
            )

            // ====================================================
            // NETWORK CAPABILITIES
            // ====================================================

            val capabilities =
                connectivityManager.getNetworkCapabilities(
                    network
                )

            if (
                capabilities == null ||
                !capabilities.hasTransport(
                    NetworkCapabilities.TRANSPORT_WIFI
                )
            ) {

                println(
                    "[RouterGateway] ERROR: Network is not Wi-Fi"
                )

                result.error(
                    "NOT_WIFI",
                    "يجب أن يكون الهاتف متصلاً بشبكة Wi-Fi",
                    null
                )

                return
            }

            println(
                "[RouterGateway] Wi-Fi connection confirmed"
            )

            // ====================================================
            // LINK PROPERTIES
            // ====================================================

            val linkProperties: LinkProperties =
                connectivityManager.getLinkProperties(network)
                    ?: run {

                        println(
                            "[RouterGateway] ERROR: No LinkProperties"
                        )

                        result.error(
                            "NO_LINK_PROPERTIES",
                            "تعذر الحصول على معلومات الشبكة",
                            null
                        )

                        return
                    }

            println(
                "[RouterGateway] LinkProperties obtained"
            )

            // ====================================================
            // DEBUG ROUTES
            // ====================================================

            println("")
            println(
                "[RouterGateway] Routes:"
            )

            linkProperties.routes.forEach { route ->

                println(
                    "[RouterGateway] Route: $route"
                )
            }

            // ====================================================
            // GATEWAY
            // ====================================================
            //
            // هذا الجزء مأخوذ من الكود الذي يعمل عندك.
            //
            // ====================================================

            var gateway: String? = null

            println("")
            println(
                "[RouterGateway] Searching IPv4 Gateway..."
            )

            for (route in linkProperties.routes) {

                val routeGateway =
                    route.gateway

                if (routeGateway is Inet4Address) {

                    val address =
                        routeGateway.hostAddress

                    println(
                        "[RouterGateway] Checking Gateway: $address"
                    )

                    // عدم قبول 0.0.0.0
                    if (
                        !address.isNullOrEmpty() &&
                        address != "0.0.0.0"
                    ) {

                        gateway = address

                        println(
                            "[RouterGateway] IPv4 Gateway FOUND: $gateway"
                        )

                        break
                    }
                }
            }

            // ====================================================
            // GATEWAY FALLBACK
            // ====================================================
            //
            // بعض أجهزة Android / MIUI قد تعيد 0.0.0.0
            // في route.gateway.
            //
            // لذلك نستخدم DNS كحل احتياطي.
            //
            // ====================================================

            if (
                gateway.isNullOrEmpty() ||
                gateway == "0.0.0.0"
            ) {

                println(
                    "[RouterGateway] Route Gateway unavailable"
                )

                val dnsFallback =
                    linkProperties.dnsServers
                        .firstOrNull {
                            it is Inet4Address
                        }
                        ?.hostAddress

                if (
                    !dnsFallback.isNullOrEmpty() &&
                    dnsFallback != "0.0.0.0"
                ) {

                    gateway = dnsFallback

                    println(
                        "[RouterGateway] Gateway from DNS fallback: $gateway"
                    )
                }
            }

            // ====================================================
            // VALIDATE GATEWAY
            // ====================================================

            if (
                gateway.isNullOrEmpty() ||
                gateway == "0.0.0.0"
            ) {

                println(
                    "[RouterGateway] ERROR: No valid IPv4 Gateway"
                )

                result.error(
                    "NO_GATEWAY",
                    "لم يتم العثور على عنوان الراوتر",
                    null
                )

                return
            }

            // ====================================================
            // DEVICE IPv4 ADDRESS
            // ====================================================

            var ipAddress: String? = null
            var prefixLength: Int? = null

            println("")
            println(
                "[RouterGateway] Searching device IPv4 address..."
            )

            for (
                linkAddress
                in linkProperties.linkAddresses
            ) {

                val address =
                    linkAddress.address

                println(
                    "[RouterGateway] Address: $address"
                )

                if (
                    address is Inet4Address &&
                    !address.isLoopbackAddress
                ) {

                    ipAddress =
                        address.hostAddress

                    prefixLength =
                        linkAddress.prefixLength

                    println(
                        "[RouterGateway] IPv4 found: $ipAddress"
                    )

                    println(
                        "[RouterGateway] Prefix: $prefixLength"
                    )

                    break
                }
            }

            // ====================================================
            // SUBNET MASK
            // ====================================================

            val subnetMask =
                prefixLength?.let {
                    prefixLengthToSubnetMask(it)
                }

            // ====================================================
            // DNS
            // ====================================================

            val dns =
                if (
                    linkProperties.dnsServers.isNotEmpty()
                ) {

                    linkProperties.dnsServers
                        .joinToString(",") {
                            it.hostAddress ?: ""
                        }

                } else {
                    null
                }

            // ====================================================
            // FINAL DEBUG
            // ====================================================

            println("")
            println("========================================")
            println("[RouterGateway] FINAL RESULT")
            println("Gateway    : $gateway")
            println("IP Address : $ipAddress")
            println("Subnet     : $subnetMask")
            println("DNS        : $dns")
            println("========================================")

            // ====================================================
            // SEND RESULT TO FLUTTER
            // ====================================================

            result.success(
                mapOf(
                    "gateway" to gateway,
                    "ipAddress" to (ipAddress ?: ""),
                    "subnetMask" to (subnetMask ?: ""),
                    "dns" to (dns ?: "")
                )
            )

            println(
                "[RouterGateway] Result sent to Flutter successfully"
            )

        } catch (e: Exception) {

            e.printStackTrace()

            println(
                "[RouterGateway] Exception: ${e.message}"
            )

            result.error(
                "NETWORK_ERROR",
                e.message
                    ?: "حدث خطأ أثناء قراءة معلومات الشبكة",
                null
            )
        }
    }

    // ============================================================
    // PREFIX LENGTH -> SUBNET MASK
    // ============================================================

    private fun prefixLengthToSubnetMask(
        prefixLength: Int
    ): String {

        if (prefixLength <= 0) {
            return "0.0.0.0"
        }

        if (prefixLength >= 32) {
            return "255.255.255.255"
        }

        val mask =
            (-1 shl (32 - prefixLength))

        val octet1 =
            (mask ushr 24) and 0xff

        val octet2 =
            (mask ushr 16) and 0xff

        val octet3 =
            (mask ushr 8) and 0xff

        val octet4 =
            mask and 0xff

        return "$octet1.$octet2.$octet3.$octet4"
    }
}