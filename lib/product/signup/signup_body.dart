import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:quickpick/crypto/crypto.dart';

class SignupBody {
  Future<Map<String, Object>> generate(verificationToken, name) async {
    var publicKey = await Crypto().getPublicKey();
    var body = <String, Object>{
      "verification_token": verificationToken,
      "name": name,
      "public_key": publicKey,
      "legal_accepted": true
    };
    body.addAll(await _findDeviceInfo());
    return body;
  }

  Future<Map<String, String>> _findDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "device_id": await const AndroidId().getId() ?? "",
        "operating_system": "Android",
        "operating_system_version": androidInfo.version.release ?? "",
        "device_brand": androidInfo.brand ?? "",
        "device_model": androidInfo.model ?? "",
        "device_name": androidInfo.device ?? "",
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "device_id": iosInfo.identifierForVendor ?? "",
        "operating_system": "IOS",
        "operating_system_version": iosInfo.systemVersion ?? "",
        "device_brand": "Apple",
        "device_model": iosInfo.utsname.machine ?? "",
        "device_name": iosInfo.name ?? "",
      };
    }
    return {};
  }
}
