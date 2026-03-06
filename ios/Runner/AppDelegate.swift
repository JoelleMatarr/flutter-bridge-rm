import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let messenger = controller.binaryMessenger
    
    // Register Card Factory
    let cardFactory = CheckoutCardViewFactory1(messenger: messenger)
    registrar(forPlugin: "checkout_card_plugin")?.register(cardFactory, withId: "flow_view_card")
    
    // Register Apple Pay Factory
    let applePayFactory = CheckoutApplePayViewFactory1(messenger: messenger)
    registrar(forPlugin: "checkout_applepay_plugin")?.register(applePayFactory, withId: "flow_view_applepay")
    
    // Register Flow Factory
    let flowFactory = CheckoutFlowViewFactory1(messenger: messenger)
    registrar(forPlugin: "checkout_flow_plugin")?.register(flowFactory, withId: "flow_view_flow")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
