import Flutter
import UIKit

class ScreenMirrorHandler: NSObject {
  static let shared = ScreenMirrorHandler()

  private var externalWindows = [UIScreen: UIWindow]()
  private var screens = [UIScreen]()
  private var methodChannel: FlutterMethodChannel?

  private override init() {
    super.init()
    setupScreenObservers()
  }

  func setup(binaryMessenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(
      name: "external_display_channel", binaryMessenger: binaryMessenger)
    methodChannel?.setMethodCallHandler { [weak self] (call, result) in
      self?.handleMethodCall(call, result: result)
    }
  }

  private func setupScreenObservers() {
    NotificationCenter.default.addObserver(
      forName: UIScreen.didConnectNotification,
      object: nil,
      queue: nil
    ) { [weak self] notification in
      self?.handleScreenConnection(notification)
    }

    NotificationCenter.default.addObserver(
      forName: UIScreen.didDisconnectNotification,
      object: nil,
      queue: nil
    ) { [weak self] notification in
      self?.handleScreenDisconnection(notification)
    }
  }

  private func handleScreenConnection(_ notification: Notification) {
    guard let newScreen = notification.object as? UIScreen else { return }
    let screenDimensions = newScreen.bounds
    let newWindow = UIWindow(frame: screenDimensions)
    newWindow.screen = newScreen
    newWindow.isHidden = true  // Initially hidden

    screens.append(newScreen)
    externalWindows[newScreen] = newWindow
  }

  private func handleScreenDisconnection(_ notification: Notification) {
    guard let screen = notification.object as? UIScreen else { return }
    if let index = screens.firstIndex(of: screen) {
      screens.remove(at: index)
      externalWindows.removeValue(forKey: screen)
    }
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isScreenMirrored":
      result(UIScreen.screens.count > 1)
    case "showFlutterWidget":
      if let route = call.arguments as? String {
        showFlutterWidget(route: route)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Route is required", details: nil))
      }
    case "hideFlutterWidget":
      hideFlutterWidget()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func showFlutterWidget(route: String) {
    if let externalScreen = UIScreen.screens.last, let window = externalWindows[externalScreen] {
      window.isHidden = false

      if window.rootViewController == nil || !(window.rootViewController is FlutterViewController) {
        let flutterVC = FlutterViewController(
          project: nil,
          initialRoute: route,
          nibName: nil,
          bundle: nil)
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
