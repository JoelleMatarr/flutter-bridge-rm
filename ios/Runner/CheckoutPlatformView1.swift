import Foundation
import Flutter
import UIKit
import SwiftUI
import CheckoutComponentsSDK

// MARK: - Card View
@available(iOS 13.0, *)
class CheckoutCardPlatformView1: NSObject, FlutterPlatformView {
    private var _view: UIView
    private let channel: FlutterMethodChannel // Persistent Channel

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
        let containerView = UIView(frame: frame)
        _view = containerView
        self.channel = FlutterMethodChannel(name: "checkout_bridge", binaryMessenger: messenger)
        super.init()

        guard let params = args as? [String: String], let pID = params["paymentSessionID"], let pSec = params["paymentSessionSecret"], let pKey = params["publicKey"] else { return }

        Task {
            do {
                let config = try await CheckoutComponents.Configuration(
                    paymentSession: .init(id: pID, paymentSessionSecret: pSec), publicKey: pKey, environment: .sandbox,
                    callbacks: .init(
                        onSuccess: { [weak self] _, id in
                                // Log to Xcode / Swift terminal
                                print("✅ PAYMENT SUCCESSFUL [Swift Log] - ID: \(id)")
                                
                                DispatchQueue.main.async {
                                    self?.channel.invokeMethod("paymentSuccess", arguments: id)
                                }
                            },
                            onError: { [weak self] err in
                                // Log to Xcode / Swift terminal
                                print("❌ PAYMENT FAILED [Swift Log] - Error: \(err.localizedDescription)")
                                
                                DispatchQueue.main.async {
                                    self?.channel.invokeMethod("paymentError", arguments: err.localizedDescription)
                                }
                            }
                    )
                )
                let component = try await CheckoutComponents(configuration: config).create(.card(rememberMeConfiguration: .init(data: .init(email: "test@test.com", phone: .init(countryCode: "971", number: "500000000")), showPayButton: true)))
                if component.isAvailable {
                    await MainActor.run {
                        let controller = UIHostingController(rootView: component.render().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top))
                        controller.view.backgroundColor = .clear
                        containerView.addSubview(controller.view)
                        controller.view.frame = containerView.bounds
                        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    }
                }
            } catch { print(error) }
        }
    }
    func view() -> UIView { return _view }
}

// MARK: - Flow View
@available(iOS 13.0, *)
class CheckoutFlowPlatformView1: NSObject, FlutterPlatformView {
    private var _view: UIView
    private let channel: FlutterMethodChannel

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
        let containerView = UIView(frame: frame)
        _view = containerView
        self.channel = FlutterMethodChannel(name: "checkout_bridge", binaryMessenger: messenger)
        super.init()

        guard let params = args as? [String: String], let pID = params["paymentSessionID"], let pSec = params["paymentSessionSecret"], let pKey = params["publicKey"] else { return }

        Task {
            do {
                let config = try await CheckoutComponents.Configuration(
                    paymentSession: .init(id: pID, paymentSessionSecret: pSec), publicKey: pKey, environment: .sandbox,
                    callbacks: .init(
                        onSuccess: { [weak self] _, id in
                                // Log to Xcode / Swift terminal
                                print("✅ PAYMENT SUCCESSFUL [Swift Log] - ID: \(id)")
                                
                                DispatchQueue.main.async {
                                    self?.channel.invokeMethod("paymentSuccess", arguments: id)
                                }
                            },
                            onError: { [weak self] err in
                                // Log to Xcode / Swift terminal
                                print("❌ PAYMENT FAILED [Swift Log] - Error: \(err.localizedDescription)")
                                
                                DispatchQueue.main.async {
                                    self?.channel.invokeMethod("paymentError", arguments: err.localizedDescription)
                                }
                            }
                    )
                )
                let component = try await CheckoutComponents(configuration: config).create(.flow(options: [.applePay(merchantIdentifier: "merchant.com.example"), .card()]))
                if component.isAvailable {
                    await MainActor.run {
                        let controller = UIHostingController(rootView: component.render().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top))
                        controller.view.backgroundColor = .clear
                        containerView.addSubview(controller.view)
                        controller.view.frame = containerView.bounds
                        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    }
                }
            } catch { print(error) }
        }
    }
    func view() -> UIView { return _view }
}

// MARK: - Apple Pay View
@available(iOS 13.0, *)
class CheckoutApplePayPlatformView1: NSObject, FlutterPlatformView {
    private var _view: UIView
    private let channel: FlutterMethodChannel

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
        let containerView = UIView(frame: frame)
        _view = containerView
        self.channel = FlutterMethodChannel(name: "checkout_bridge", binaryMessenger: messenger)
        super.init()

        guard let params = args as? [String: String], let pID = params["paymentSessionID"], let pSec = params["paymentSessionSecret"], let pKey = params["publicKey"] else { return }

        Task {
            do {
                let config = try await CheckoutComponents.Configuration(
                    paymentSession: .init(id: pID, paymentSessionSecret: pSec), publicKey: pKey, environment: .sandbox,
                    callbacks: .init(
                        onSuccess: { [weak self] _, id in
                                // Log to Xcode / Swift terminal
                                print("✅ PAYMENT SUCCESSFUL [Swift Log] - ID: \(id)")
                                
                                DispatchQueue.main.async {
                                    self?.channel.invokeMethod("paymentSuccess", arguments: id)
                                }
                            },
                            onError: { [weak self] err in
                                // Log to Xcode / Swift terminal
                                print("❌ PAYMENT FAILED [Swift Log] - Error: \(err.localizedDescription)")
                                
                                DispatchQueue.main.async {
                                    self?.channel.invokeMethod("paymentError", arguments: err.localizedDescription)
                                }
                            }
                    )
                )
                let component = try await CheckoutComponents(configuration: config).create(.applePay(merchantIdentifier: "merchant.com.example"))
                if component.isAvailable {
                    await MainActor.run {
                        let controller = UIHostingController(rootView: component.render().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center))
                        controller.view.backgroundColor = .clear
                        containerView.addSubview(controller.view)
                        controller.view.frame = containerView.bounds
                        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    }
                }
            } catch { print(error) }
        }
    }
    func view() -> UIView { return _view }
}

// MARK: - Factories
class CheckoutCardViewFactory1: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    init(messenger: FlutterBinaryMessenger) { self.messenger = messenger }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        // Correctly formatted if #available block
        if #available(iOS 16.0, *) {
            return CheckoutCardPlatformView1(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
        } else {
            return DummyPlatformView1()
        }
    }
}

class CheckoutFlowViewFactory1: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    init(messenger: FlutterBinaryMessenger) { self.messenger = messenger }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        if #available(iOS 16.0, *) {
            return CheckoutFlowPlatformView1(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
        } else {
            return DummyPlatformView1()
        }
    }
}

class CheckoutApplePayViewFactory1: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    init(messenger: FlutterBinaryMessenger) { self.messenger = messenger }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        if #available(iOS 16.0, *) {
            return CheckoutApplePayPlatformView1(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
        } else {
            return DummyPlatformView1()
        }
    }
}

class DummyPlatformView1: NSObject, FlutterPlatformView {
    func view() -> UIView {
        let label = UILabel()
        label.text = "Unsupported iOS Version"
        label.textAlignment = .center
        return label
    }
}
