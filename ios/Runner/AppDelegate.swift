import Flutter
import UIKit
import Network

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let routerGatewayChannel = "router_gateway"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(
                application,
                didFinishLaunchingWithOptions: launchOptions
            )
        }

        let channel = FlutterMethodChannel(
            name: routerGatewayChannel,
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { call, result in

            switch call.method {

            case "getNetworkInfo":

                self.getNetworkInfo { networkInfo in

                    if let networkInfo = networkInfo {

                        result(networkInfo)

                    } else {

                        result(
                            FlutterError(
                                code: "NETWORK_ERROR",
                                message: "تعذر الحصول على معلومات الشبكة",
                                details: nil
                            )
                        )
                    }
                }

            default:

                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    private func getNetworkInfo(
        completion: @escaping ([String: Any]?) -> Void
    ) {

        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)

        let queue = DispatchQueue(
            label: "RouterNetworkMonitor"
        )

        monitor.pathUpdateHandler = { path in

            defer {
                monitor.cancel()
            }

            guard path.status == .satisfied else {
                completion(nil)
                return
            }

            var gateway: String?
            var ipAddress: String?

            for interface in path.availableInterfaces {

                if interface.type == .wifi {

                    ipAddress = self.getIPAddress(
                        interface: interface
                    )

                    break
                }
            }

            /*
             * iOS لا يوفر Gateway الخاص بشبكة Wi-Fi
             * بنفس سهولة Android.
             *
             * لذلك نحتاج إلى الحصول عليه بطريقة أخرى.
             */

            gateway = self.getDefaultGateway()

            let result: [String: Any] = [
                "gateway": gateway ?? "",
                "ipAddress": ipAddress ?? "",
                "subnetMask": "",
                "dns": ""
            ]

            completion(result)
        }

        monitor.start(queue: queue)
    }

    private func getIPAddress(
        interface: NWInterface
    ) -> String? {

        var address: String?

        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0,
              let firstAddr = ifaddr else {
            return nil
        }

        defer {
            freeifaddrs(ifaddr)
        }

        var pointer: UnsafeMutablePointer<ifaddrs>? = firstAddr

        while let current = pointer {

            let interfaceName = String(
                cString: current.pointee.ifa_name
            )

            if interfaceName == "en0" {

                let flags = current.pointee.ifa_flags

                if (flags & UInt32(IFF_UP)) != 0 {

                    let addr = current.pointee.ifa_addr

                    if addr?.pointee.sa_family ==
                        UInt8(AF_INET) {

                        var hostname = [CChar](
                            repeating: 0,
                            count: Int(NI_MAXHOST)
                        )

                        getnameinfo(
                            addr,
                            socklen_t(addr!.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            0,
                            NI_NUMERICHOST
                        )

                        address = String(
                            cString: hostname
                        )

                        break
                    }
                }
            }

            pointer = current.pointee.ifa_next
        }

        return address
    }

    private func getDefaultGateway() -> String? {

        /*
         * سيتم التعامل مع Gateway هنا.
         *
         * iOS لا يوفر API عاماً مباشراً مثل Android
         * للحصول على Default Gateway.
         */

        return nil
    }
}