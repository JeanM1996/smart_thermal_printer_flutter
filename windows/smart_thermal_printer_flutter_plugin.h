#ifndef FLUTTER_PLUGIN_SMART_THERMAL_PRINTER_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_SMART_THERMAL_PRINTER_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace smart_thermal_printer_flutter {

class SmartThermalPrinterFlutterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SmartThermalPrinterFlutterPlugin();

  virtual ~SmartThermalPrinterFlutterPlugin();

  // Disallow copy and assign.
  SmartThermalPrinterFlutterPlugin(const SmartThermalPrinterFlutterPlugin&) = delete;
  SmartThermalPrinterFlutterPlugin& operator=(const SmartThermalPrinterFlutterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace smart_thermal_printer_flutter

#endif  // FLUTTER_PLUGIN_SMART_THERMAL_PRINTER_FLUTTER_PLUGIN_H_
