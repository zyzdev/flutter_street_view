#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_google_street_view.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_google_street_view'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter google street view plugin.'
  s.description      = <<-DESC
A Flutter google street view plugin.
                       DESC
  s.homepage         = 'https://github.com/zyzdev/flutter_street_view/tree/master/flutter_google_street_view'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'ZYZ' => 'pk279700197@gmail.com' }
  s.source           = { :path => 'https://github.com/zyzdev/flutter_street_view/tree/master/flutter_google_street_view' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'GoogleMaps'
  s.static_framework = true
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
