import Flutter
import UIKit
import home_widget
import GoogleMaps
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    }

    if #available(iOS 17.0, *) {
      HomeWidgetPlugin.setConfigurationLookup(to: [
        "ShoppingListWidget": ShoppingListConfigurationIntent.self
      ])
      HomeWidgetBackgroundWorker.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // home_widget の updateWidget は WidgetCenter.reloadTimelines(ofKind:) しか呼ばず、
    // 正しい kind を渡してもウィジェットが再描画されないことがある (Issue #475 Root Cause 2)。
    // ウィジェット拡張内で実績のある reloadAllTimelines() をアプリ本体からも呼べるようにする。
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "HomeWidgetReload") {
      let channel = FlutterMethodChannel(
        name: "com.bannzai.shoppinglist/home_widget_reload",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "reloadAllTimelines":
          if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
          }
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }
}
