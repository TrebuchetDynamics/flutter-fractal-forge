import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var methodChannel: FlutterMethodChannel?
    private var initialLink: String?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if let controller = window?.rootViewController as? FlutterViewController {
            // Deep link communication
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

            // Wallpaper channel (iOS: save to Photos)
            let wallpaperChannel = FlutterMethodChannel(
                name: "com.fractalforge/wallpaper",
                binaryMessenger: controller.binaryMessenger
            )

            wallpaperChannel.setMethodCallHandler { [weak self] call, result in
                switch call.method {
                case "saveToPhotos":
                    guard let args = call.arguments as? [String: Any],
                          let bytes = args["bytes"] as? FlutterStandardTypedData,
                          let image = UIImage(data: bytes.data) else {
                        result(false)
                        return
                    }

                    self?.saveImageToPhotos(image: image) { ok, err in
                        if let err = err {
                            result(FlutterError(code: "PHOTO_SAVE_ERROR", message: err.localizedDescription, details: nil))
                        } else {
                            result(ok)
                        }
                    }

                case "setWallpaper":
                    // Not possible on iOS.
                    result(false)

                default:
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

    private func saveImageToPhotos(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .authorized || status == .limited {
            performSave(image: image, completion: completion)
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
            DispatchQueue.main.async {
                if newStatus == .authorized || newStatus == .limited {
                    self.performSave(image: image, completion: completion)
                } else {
                    completion(false, NSError(domain: "Photos", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photos permission denied"]))
                }
            }
        }
    }

    private func performSave(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
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
