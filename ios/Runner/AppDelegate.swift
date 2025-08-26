import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let CHANNEL = FlutterMethodChannel(
      name: "packageInfo",
      binaryMessenger:
        controller as! FlutterBinaryMessenger)

    CHANNEL.setMethodCallHandler { [unowned self] (methodCall, result) in
      if (methodCall.method == "getVersionNumber") {
        result(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
      }
      if (methodCall.method == "getTimeZoneName") {
        result(TimeZone.current.identifier)
      }
      if (methodCall.method == "getBuildNumber") {
        result(Bundle.main.infoDictionary?["CFBundleVersion"] as? String)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
