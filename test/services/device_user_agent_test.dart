import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openpanel_flutter/src/services/device_user_agent.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'TestApp',
      packageName: 'dev.openpanel.test',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: '',
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('uses a client-recognizable Android user agent', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final deviceInfo = DeviceInfoPlugin.setMockInitialValues(
      androidDeviceInfo: AndroidDeviceInfo.setMockInitialValues(
        version: AndroidBuildVersion.setMockInitialValues(
          codename: 'REL',
          incremental: '1',
          previewSdkInt: 0,
          release: '15',
          sdkInt: 35,
        ),
        board: 'board',
        bootloader: 'bootloader',
        brand: 'Google',
        device: 'device',
        display: 'display',
        fingerprint: 'fingerprint',
        hardware: 'hardware',
        host: 'host',
        id: 'build-id',
        manufacturer: 'Google',
        model: 'Pixel 9',
        product: 'product',
        name: 'Pixel 9',
        supported32BitAbis: const [],
        supported64BitAbis: const ['arm64-v8a'],
        supportedAbis: const ['arm64-v8a'],
        tags: 'release-keys',
        type: 'user',
        isPhysicalDevice: true,
        freeDiskSize: 0,
        totalDiskSize: 0,
        systemFeatures: const [],
        isLowRamDevice: false,
        physicalRamSize: 8192,
        availableRamSize: 4096,
      ),
    );

    final userAgent =
        await DeviceUserAgent(deviceInfo: deviceInfo).getUserAgent();

    expect(
      userAgent,
      contains(
        'TestApp/1.2.3 '
        '(Linux; Android 15; Model=Pixel 9; '
        'Manufacturer=Google; build:42)',
      ),
    );
  });

  test('uses a client-recognizable iOS user agent', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final deviceInfo = DeviceInfoPlugin.setMockInitialValues(
      iosDeviceInfo: IosDeviceInfo.setMockInitialValues(
        name: 'iPhone',
        systemName: 'iOS',
        systemVersion: '18.5',
        model: 'iPhone',
        modelName: 'iPhone 16 Pro',
        localizedModel: 'iPhone',
        freeDiskSize: 0,
        totalDiskSize: 0,
        identifierForVendor: 'test-vendor-id',
        isPhysicalDevice: true,
        isiOSAppOnMac: false,
        isiOSAppOnVision: false,
        physicalRamSize: 8192,
        availableRamSize: 4096,
        utsname: IosUtsname.setMockInitialValues(
          sysname: 'Darwin',
          nodename: 'iPhone',
          release: '24.5.0',
          version: 'Darwin Kernel Version 24.5.0',
          machine: 'iPhone17,1',
        ),
      ),
    );

    final userAgent =
        await DeviceUserAgent(deviceInfo: deviceInfo).getUserAgent();

    expect(
      userAgent,
      contains(
        'TestApp/1.2.3 '
        '(iPhone; CPU iPhone OS 18_5 like Mac OS X; '
        'Model=iPhone; Manufacturer=Apple; build:42)',
      ),
    );
  });

  test('uses a client-recognizable macOS user agent', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final deviceInfo = DeviceInfoPlugin.setMockInitialValues(
      macOsDeviceInfo: MacOsDeviceInfo.setMockInitialValues(
        computerName: 'Test Mac',
        hostName: 'test-mac.local',
        arch: 'arm64',
        model: 'MacBookPro18,3',
        modelName: 'MacBook Pro',
        kernelVersion: 'Darwin Kernel Version 24.5.0',
        osRelease: '24.5.0',
        majorVersion: 15,
        minorVersion: 5,
        patchVersion: 0,
        activeCPUs: 10,
        memorySize: 16 * 1024 * 1024 * 1024,
        cpuFrequency: 0,
        systemGUID: 'test-guid',
      ),
    );

    final userAgent =
        await DeviceUserAgent(deviceInfo: deviceInfo).getUserAgent();

    expect(
      userAgent,
      contains(
        'TestApp/1.2.3 '
        '(Macintosh; arm64; Mac OS X 15_5_0; '
        'Model=MacBookPro18,3; Manufacturer=Apple; build:42)',
      ),
    );
  });

  test('uses a client-recognizable Windows user agent', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final deviceInfo = DeviceInfoPlugin.setMockInitialValues(
      windowsDeviceInfo: WindowsDeviceInfo(
        computerName: 'TEST-PC',
        numberOfCores: 8,
        systemMemoryInMegabytes: 16384,
        userName: 'tester',
        majorVersion: 10,
        minorVersion: 0,
        buildNumber: 26100,
        platformId: 2,
        csdVersion: '',
        servicePackMajor: 0,
        servicePackMinor: 0,
        suitMask: 0,
        productType: 1,
        reserved: 0,
        buildLab: '',
        buildLabEx: '',
        digitalProductId: Uint8List(0),
        displayVersion: '24H2',
        editionId: 'Professional',
        installDate: DateTime.utc(2026),
        productId: 'test-product',
        productName: 'Windows 11 Pro',
        registeredOwner: 'tester',
        releaseId: '2009',
        deviceId: 'test-device',
      ),
    );

    final userAgent =
        await DeviceUserAgent(deviceInfo: deviceInfo).getUserAgent();

    expect(
      userAgent,
      'TestApp/1.2.3 '
      '(Windows 11; 24H2; build:26100; app-build:42)',
    );
  });

  test('uses a client-recognizable Linux user agent', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final deviceInfo = DeviceInfoPlugin.setMockInitialValues(
      linuxDeviceInfo: LinuxDeviceInfo(
        name: 'Ubuntu',
        version: '24.04.2 LTS',
        id: 'ubuntu',
        versionId: '24.04',
        prettyName: 'Ubuntu 24.04.2 LTS',
        machineId: 'test-machine',
      ),
    );

    final userAgent =
        await DeviceUserAgent(deviceInfo: deviceInfo).getUserAgent();

    expect(
      userAgent,
      'TestApp/1.2.3 '
      '(X11; Linux ubuntu; Ubuntu 24.04.2 LTS; build:42)',
    );
  });
}
