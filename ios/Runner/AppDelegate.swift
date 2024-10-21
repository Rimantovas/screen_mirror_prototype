import Flutter
import UIKit

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

  var externalWindows = [UIScreen: UIWindow]()
  var screens = [UIScreen]()
  var flutterEngineChannel: FlutterMethodChannel? = nil

  override init() {
    super.init()

    // Listen for external display connection/disconnection
    NotificationCenter.default.addObserver(
      forName: UIScreen.didConnectNotification, object: nil, queue: nil
    ) { notification in
      guard let newScreen = notification.object as? UIScreen else {
        return
      }
      let screenDimensions = newScreen.bounds
      let newWindow = UIWindow(frame: screenDimensions)
      newWindow.screen = newScreen
      newWindow.isHidden = true  // Initially hidden

      self.screens.append(newScreen)
      self.externalWindows[newScreen] = newWindow
    }

    NotificationCenter.default.addObserver(
      forName: UIScreen.didDisconnectNotification, object: nil, queue: nil
    ) { notification in
      guard let screen = notification.object as? UIScreen else {
        return
      }
      // Remove disconnected external screen
      if let index = self.screens.firstIndex(of: screen) {
        self.screens.remove(at: index)
        self.externalWindows.removeValue(forKey: screen)
      }
    }
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      ScreenMirrorHandler.shared.setup(binaryMessenger: controller.binaryMessenger)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func showFlutterWidget(route: String) {
    if let externalScreen = UIScreen.screens.last, let window = externalWindows[externalScreen] {
      window.isHidden = false

      if window.rootViewController == nil || !(window.rootViewController is FlutterViewController) {
        let flutterVC = FlutterViewController(
          project: nil, initialRoute: route, nibName: nil, bundle: nil)
        window.rootViewController = flutterVC
        flutterVC.setInitialRoute(route)
        window.makeKeyAndVisible()
      }
    } else {
      print("No external screen connected.")
    }
  }

  private func hideFlutterWidget() {
    if let externalScreen = UIScreen.screens.last, let window = externalWindows[externalScreen] {
      window.isHidden = true
    }
  }
}
