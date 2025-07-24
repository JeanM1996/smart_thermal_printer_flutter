import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:smart_thermal_printer_flutter/smart_thermal_printer_flutter.dart';
import 'package:smart_thermal_printer_flutter/smart_thermal_printer_flutter_method_channel.dart';
import 'package:smart_thermal_printer_flutter/smart_thermal_printer_flutter_platform_interface.dart';

class MockSmartThermalPrinterFlutterPlatform
    with MockPlatformInterfaceMixin
    implements SmartThermalPrinterFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SmartThermalPrinterFlutterPlatform initialPlatform =
      SmartThermalPrinterFlutterPlatform.instance;

  test('$MethodChannelSmartThermalPrinterFlutter is the default instance', () {
    expect(initialPlatform,
        isInstanceOf<MethodChannelSmartThermalPrinterFlutter>());
  });

  test('getPlatformVersion', () async {
    SmartThermalPrinterFlutter smartThermalPrinterFlutterPlugin =
        SmartThermalPrinterFlutter.instance;
    MockSmartThermalPrinterFlutterPlatform fakePlatform =
        MockSmartThermalPrinterFlutterPlatform();
    SmartThermalPrinterFlutterPlatform.instance = fakePlatform;

    expect(await smartThermalPrinterFlutterPlugin.getPlatformVersion(), '42');
  });
}
