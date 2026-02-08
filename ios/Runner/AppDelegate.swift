import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var methodChannel: FlutterMethodChannel?
    private var initialLink: String?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Set up method channel for deep link communication
        if let controller = window?.rootViewController as? FlutterViewController {
            methodChannel = FlutterMethodChannel(
                name: "com.fractalforge/deeplink",
                binaryMessenger: controller.binaryMessenger
            )
            
            methodChannel?.setMethodCallHandler { [weak self] call, result in
                if call.method == "getInitialLink" {
                    result(self?.initialLink)
                    self?.initialLink = nil
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }
        
        // Check if app was launched via URL
        if let url = launchOptions?[.url] as? URL {
            initialLink = url.absoluteString
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Handle deep links when app is already running
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        methodChannel?.invokeMethod("onDeepLink", arguments: url.absoluteString)
        return true
    }
    
    // Handle universal links
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            methodChannel?.invokeMethod("onDeepLink", arguments: url.absoluteString)
            return true
        }
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}
