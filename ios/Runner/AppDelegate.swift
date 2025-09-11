import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    var methodChannel: FlutterResult?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
      
    GMSServices.provideAPIKey("AIzaSyDI6intm1g6h9OlCrhrg8dGmIemQkaEemM")
    GeneratedPluginRegistrant.register(with: self)
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
}


