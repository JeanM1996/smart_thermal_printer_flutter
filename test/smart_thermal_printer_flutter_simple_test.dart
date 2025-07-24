import 'package:flutter_test/flutter_test.dart';
import 'package:smart_thermal_printer_flutter/smart_thermal_printer_flutter.dart';

void main() {
  test('SmartThermalPrinterFlutter instance creation', () {
    final smartThermalPrinter = SmartThermalPrinterFlutter.instance;
    expect(smartThermalPrinter, isNotNull);
  });
}
