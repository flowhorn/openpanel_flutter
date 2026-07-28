import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/widgets.dart'
    show WidgetsBinding, WidgetsFlutterBinding;

/// Builds user agents that OpenPanel recognizes as client traffic.
///
/// OpenPanel only creates sessions for client events, so every platform must
/// include a conventional OS token that `ua-parser-js` can recognize.
class DeviceUserAgent {
  final DeviceInfoPlugin _deviceInfo;

  DeviceUserAgent({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  Future<String> getUserAgent() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final appVersion = packageInfo.version;
      final appBuild = packageInfo.buildNumber;

      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return _buildWebUserAgent(webInfo, appName, appVersion, appBuild);
      }

      return switch (defaultTargetPlatform) {
        TargetPlatform.android => _buildAndroidUserAgent(
            await _deviceInfo.androidInfo, appName, appVersion, appBuild),
        TargetPlatform.iOS => _buildIosUserAgent(
            await _deviceInfo.iosInfo, appName, appVersion, appBuild),
        TargetPlatform.macOS => _buildMacOsUserAgent(
            await _deviceInfo.macOsInfo, appName, appVersion, appBuild),
        TargetPlatform.windows => _buildWindowsUserAgent(
            await _deviceInfo.windowsInfo, appName, appVersion, appBuild),
        TargetPlatform.linux => _buildLinuxUserAgent(
            await _deviceInfo.linuxInfo, appName, appVersion, appBuild),
        _ => _defaultUserAgent(appName, appVersion, appBuild),
      };
    } catch (e) {
      return _defaultUserAgent("UnknownApp", "1.0", "0", error: e.toString());
    }
  }

  String _defaultUserAgent(String appName, String appVersion, String appBuild,
      {String? error}) {
    return '$appName/$appVersion (Unknown Device; build:$appBuild${error != null ? "; Error: $error" : ""})';
  }

  String _buildWebUserAgent(
      WebBrowserInfo info, String appName, String appVersion, String appBuild) {
    return '$appName/$appVersion (${info.browserName.name}/${info.appVersion ?? "Unknown"}; ${info.platform ?? "Web"}; build:$appBuild)';
  }

  String _buildAndroidUserAgent(AndroidDeviceInfo info, String appName,
      String appVersion, String appBuild) {
    final resolution = _getScreenResolution();
    final pixelRatio = _getDevicePixelRatio();

    return '$appName/$appVersion '
        '(Linux; Android ${info.version.release}; '
        'Model=${info.model}; Manufacturer=${info.manufacturer}; '
        'build:$appBuild) '
        'screen/$resolution/$pixelRatio';
  }

  String _buildIosUserAgent(
      IosDeviceInfo info, String appName, String appVersion, String appBuild) {
    final resolution = _getScreenResolution();
    final pixelRatio = _getDevicePixelRatio();
    final osVersion = info.systemVersion.replaceAll('.', '_');
    final isIpad = info.model.toLowerCase().contains('ipad');
    final device = isIpad ? 'iPad' : 'iPhone';
    final cpuOs = isIpad ? 'CPU OS' : 'CPU iPhone OS';

    return '$appName/$appVersion '
        '($device; $cpuOs $osVersion like Mac OS X; '
        'Model=${info.model}; Manufacturer=Apple; build:$appBuild) '
        'screen/$resolution/$pixelRatio';
  }

  String _buildMacOsUserAgent(MacOsDeviceInfo info, String appName,
      String appVersion, String appBuild) {
    final osVersion =
        '${info.majorVersion}_${info.minorVersion}_${info.patchVersion}';
    return '$appName/$appVersion '
        '(Macintosh; ${info.arch}; Mac OS X $osVersion; '
        'Model=${info.model}; Manufacturer=Apple; build:$appBuild)';
  }

  String _buildWindowsUserAgent(WindowsDeviceInfo info, String appName,
      String appVersion, String appBuild) {
    final windowsVersion = info.buildNumber >= 22000 ? '11' : '10';
    return '$appName/$appVersion '
        '(Windows $windowsVersion; ${info.displayVersion}; '
        'build:${info.buildNumber}; app-build:$appBuild)';
  }

  String _buildLinuxUserAgent(LinuxDeviceInfo info, String appName,
      String appVersion, String appBuild) {
    return '$appName/$appVersion '
        '(X11; Linux ${info.id}; ${info.prettyName}; build:$appBuild)';
  }

  /// Gets the screen resolution
  String _getScreenResolution() {
    WidgetsFlutterBinding.ensureInitialized();
    final size =
        WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    return '${size.width.toInt()}x${size.height.toInt()}';
  }

  /// Gets the screen pixel ratio
  double _getDevicePixelRatio() {
    WidgetsFlutterBinding.ensureInitialized();
    return WidgetsBinding
        .instance.platformDispatcher.views.first.devicePixelRatio;
  }
}
