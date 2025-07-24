import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'smart_thermal_printer_flutter_platform_interface.dart';
import 'utils/printer.dart';

/// An implementation of [SmartThermalPrinterFlutterPlatform] that uses method channels.
class MethodChannelSmartThermalPrinterFlutter
    extends SmartThermalPrinterFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('smart_thermal_printer_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<dynamic> startUsbScan() async {
    return await methodChannel.invokeMethod('getUsbDevicesList');
  }

  @override
  Future<bool> connect(Printer device) async {
    return await methodChannel.invokeMethod('connect', {
      "vendorId": device.vendorId.toString(),
      "productId": device.productId.toString(),
    });
  }

  @override
  Future<bool> printText(Printer device, Uint8List data, {String? path}) async {
    return await methodChannel.invokeMethod('printText', {
      "vendorId": device.vendorId.toString(),
      "productId": device.productId.toString(),
      "data": List<int>.from(data),
      "path": path ?? "",
    });
  }

  @override
  Future<bool> isConnected(Printer device) async {
    return await methodChannel.invokeMethod('isConnected', {
      "vendorId": device.vendorId.toString(),
      "productId": device.productId.toString(),
    });
  }

  @override
  Future<dynamic> convertImageToGrayscale(Uint8List? value) async {
    return await methodChannel.invokeMethod('convertimage', {
      "path": List<int>.from(value!),
    });
  }

  @override
  Future<bool> disconnect(Printer device) async {
    return await methodChannel.invokeMethod('disconnect', {
      "vendorId": device.vendorId.toString(),
      "productId": device.productId.toString(),
    });
  }
}
