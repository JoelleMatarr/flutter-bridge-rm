import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedPaymentMethod;
  static const MethodChannel _bridge = MethodChannel('checkout_bridge');

  @override
  void initState() {
    super.initState();
    _initMethodChannel();
  }

  void _initMethodChannel() {
    _bridge.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "paymentSuccess":
          _onPaymentSuccess(call.arguments.toString());
          break;
        case "paymentError":
          _onPaymentError(call.arguments.toString());
          break;
        default:
          debugPrint("Unknown method: ${call.method}");
      }
    });
  }

  void _onPaymentSuccess(String paymentId) {
    // If the payment wasn't Apple Pay, it means a bottom sheet is open. Close it.
    if (selectedPaymentMethod == "card" || selectedPaymentMethod == "flow") {
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Success! ID: $paymentId"), backgroundColor: Colors.green),
    );
  }

  void _onPaymentError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
    );
  }

  void _showDynamicBottomSheet(Widget platformView) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Drag Handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 5, width: 45,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                    
                    // ---> THE FIX: Add a 10px margin top here <---
                    const SizedBox(height: 20), 

                    // 2. Component Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 450,
                          maxHeight: MediaQuery.of(context).size.height * 0.85,
                        ),
                        child: ClipRRect(child: platformView),
                      ),
                    ),
                    
                    // Large spacer to keep content top-aligned while allowing expansion
                    const SizedBox(height: 600),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void onSelect(String method) {
    setState(() => selectedPaymentMethod = method);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (method == "card") _showDynamicBottomSheet(const PlatformCardView());
      if (method == "flow") _showDynamicBottomSheet(const PlatformFlowView());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Platform.isIOS;
    final showApplePay = selectedPaymentMethod == "applepay";

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true, backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildPayButton(isIOS ? "Apple Pay" : "Google Pay", Colors.black, Colors.white, () => onSelect("applepay")),
                const SizedBox(width: 10),
                _buildPayButton("Card", Colors.blueAccent, Colors.white, () => onSelect("card")),
                const SizedBox(width: 10),
                _buildPayButton("Flow", const Color(0xFFFFD044), Colors.black, () => onSelect("flow")),
              ],
            ),
          ),
          const Spacer(),
          // Apple Pay Inline
          if (showApplePay)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const PlatformApplePayView(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPayButton(String label, Color bg, Color fg, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg, foregroundColor: fg, padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

// --- Platform Views Definitions ---
const Map<String, String> _sessionParams = {
  'paymentSessionID': "ps_3AZbqTppknOaJoj90Hj1hesj897",
  'paymentSessionSecret': "pss_09fb6466-a8d3-42fb-ba75-bb7e90f1cc1a",
  'publicKey': "pk_sbox_zxmkbjyj4ec7liyyup23gjfsga#",
};

class PlatformCardView extends StatelessWidget {
  const PlatformCardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS 
      ? const UiKitView(viewType: 'flow_view_card', creationParams: _sessionParams, creationParamsCodec: StandardMessageCodec())
      : const AndroidView(viewType: 'flow_card_view', creationParams: _sessionParams, creationParamsCodec: StandardMessageCodec());
  }
}

class PlatformFlowView extends StatelessWidget {
  const PlatformFlowView({super.key});
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS 
      ? const UiKitView(viewType: 'flow_view_flow', creationParams: _sessionParams, creationParamsCodec: StandardMessageCodec())
      : const AndroidView(viewType: 'flow_flow_view', creationParams: _sessionParams, creationParamsCodec: StandardMessageCodec());
  }
}

class PlatformApplePayView extends StatelessWidget {
  const PlatformApplePayView({super.key});
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS 
      ? const UiKitView(viewType: 'flow_view_applepay', creationParams: _sessionParams, creationParamsCodec: StandardMessageCodec())
      : const AndroidView(viewType: 'flow_googlepay_view', creationParams: _sessionParams, creationParamsCodec: StandardMessageCodec());
  }
}