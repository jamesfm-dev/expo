require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name           = 'expo-dev-menu'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platform       = :ios, '13.0'
  s.swift_version  = '5.2'
  s.source         = { git: 'https://github.com/expo/expo.git' }
  s.static_framework = true
  s.requires_arc   = true
  s.header_dir     = 'EXDevMenu'

  s.resource_bundles = { 'EXDevMenu' => [
    'ios/assets',
    'assets/*.ios.js',
    'assets/dev-menu-packager-host',
    'assets/*.ttf',
    'assets/*.otf'
  ]}

  s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'EX_DEV_MENU_ENABLED=1', 'OTHER_SWIFT_FLAGS' => '-DEX_DEV_MENU_ENABLED' }

  s.user_target_xcconfig = {
    "HEADER_SEARCH_PATHS" => "\"${PODS_CONFIGURATION_BUILD_DIR}/expo-dev-menu/Swift Compatibility Header\"",
  }

  header_search_paths = [
    '"$(PODS_ROOT)/boost"',
    '"${PODS_ROOT}/Headers/Private/React-Core"',
    '"$(PODS_CONFIGURATION_BUILD_DIR)/ExpoModulesCore/Swift Compatibility Header"',
    '"$(PODS_CONFIGURATION_BUILD_DIR)/expo-dev-menu-interface/Swift Compatibility Header"',
  ]
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'HEADER_SEARCH_PATHS' => header_search_paths.join(' '),
  }

  s.subspec 'SafeAreaView' do |safearea|
    if File.exist?("vendored/react-native-safe-area-context/dev-menu-react-native-safe-area-context.xcframework") && Gem::Version.new(Pod::VERSION) >= Gem::Version.new('1.10.0')
      safearea.source_files = "vendored/react-native-safe-area-context/**/*.{h}"
      safearea.vendored_frameworks = "vendored/react-native-safe-area-context/dev-menu-react-native-safe-area-context.xcframework"
      safearea.private_header_files = 'vendored/react-native-safe-area-context/**/*.h'
    else
      safearea.source_files = 'vendored/react-native-safe-area-context/**/*.{h,m}'
      safearea.private_header_files = 'vendored/react-native-safe-area-context/**/*.h'

      safearea.compiler_flags = '-w -Xanalyzer -analyzer-disable-all-checks'
    end
  end

  s.subspec 'Vendored' do |vendored|
    vendored.dependency "expo-dev-menu/SafeAreaView"
  end

  s.subspec 'Main' do |main|
    s.source_files   = 'ios/**/*.{h,m,mm,swift}'
    s.preserve_paths = 'ios/**/*.{h,m,mm,swift}'
    s.exclude_files  = 'ios/*Tests/**/*', 'vendored/**/*'
    s.compiler_flags = folly_compiler_flags

    main.dependency 'React-Core'
    main.dependency "EXManifests"
    main.dependency 'ExpoModulesCore'
    main.dependency 'expo-dev-menu-interface'
    main.dependency "expo-dev-menu/Vendored"
  end

  s.test_spec 'Tests' do |test_spec|
    test_spec.requires_app_host = false
    test_spec.source_files = 'ios/Tests/**/*'
    test_spec.dependency 'Quick'
    test_spec.dependency 'Nimble'
    test_spec.dependency 'React-CoreModules'
    # ExpoModulesCore requires React-hermes or React-jsc in tests, add ExpoModulesTestCore for the underlying dependencies
    test_spec.dependency 'ExpoModulesTestCore'
    test_spec.platform = :ios, '13.0'
  end

  s.test_spec 'UITests' do |test_spec|
    test_spec.requires_app_host = true
    test_spec.source_files = 'ios/UITests/**/*'
    test_spec.dependency 'React-CoreModules'
    test_spec.dependency 'React'
    test_spec.platform = :ios, '13.0'
  end

  s.default_subspec = 'Main'
end
