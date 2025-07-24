#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint smart_thermal_printer_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'smart_thermal_printer_flutter'
  s.version          = '2.0.0'
  s.summary          = 'Advanced Flutter plugin for thermal printing with smart connection management.'
  s.description      = <<-DESC
Advanced Flutter plugin for thermal printing with smart connection management and UI widgets.
                       DESC
  s.homepage         = 'https://github.com/jeanpaulmosqueraarevalo/smart_thermal_printer_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jean Paul Mosquera' => 'jeanpaulmosqueraarevalo@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
