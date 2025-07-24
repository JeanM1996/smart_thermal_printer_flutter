#include "include/smart_thermal_printer_flutter/smart_thermal_printer_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "smart_thermal_printer_flutter_plugin.h"

void SmartThermalPrinterFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  smart_thermal_printer_flutter::SmartThermalPrinterFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
