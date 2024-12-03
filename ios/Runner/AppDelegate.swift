import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let dockChannel = FlutterMethodChannel(name: "com.example.mac_os_dock",
                                               binaryMessenger: controller.binaryMessenger)
        dockChannel.setMethodCallHandler { (call, result) in
            if call.method == "showDock" {
                self.showDock()
                result("Dock displayed!")
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func showDock() {
        let dockViewController = DockViewController()
        dockViewController.modalPresentationStyle = .overCurrentContext
        window?.rootViewController?.present(dockViewController, animated: true, completion: nil)
    }
}
