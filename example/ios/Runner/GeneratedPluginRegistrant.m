//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_blue_plus_darwin/FlutterBluePlusPlugin.h>)
#import <flutter_blue_plus_darwin/FlutterBluePlusPlugin.h>
#else
@import flutter_blue_plus_darwin;
#endif

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

#if __has_include(<path_provider_foundation/PathProviderPlugin.h>)
#import <path_provider_foundation/PathProviderPlugin.h>
#else
@import path_provider_foundation;
#endif

#if __has_include(<smart_thermal_printer_flutter/SmartThermalPrinterFlutterPlugin.h>)
#import <smart_thermal_printer_flutter/SmartThermalPrinterFlutterPlugin.h>
#else
@import smart_thermal_printer_flutter;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterBluePlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterBluePlusPlugin"]];
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
  [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];
  [SmartThermalPrinterFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"SmartThermalPrinterFlutterPlugin"]];
}

@end
