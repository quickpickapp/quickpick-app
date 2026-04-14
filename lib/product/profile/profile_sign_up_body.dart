import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileSignUpBody {
  Future<Map<String, Object>> generate(legalAccepted, newsletter) async {
    const storage = FlutterSecureStorage();
    var language = ui.PlatformDispatcher.instance.locale.languageCode;
    final cardCache = await storage.read(key: "cards");
    var cards = (cardCache == null ? [] : jsonDecode(cardCache))
        .map((card) => card["itemId"])
        .toList();
    final couponCache = await storage.read(key: "coupons");
    var coupons = (couponCache == null ? [] : jsonDecode(couponCache))
        .map((coupon) => coupon["redeemableId"])
        .toList();
    var body = <String, Object>{
      "language": language,
      "legalAccepted": legalAccepted,
      "newsletter": newsletter,
      "cards": cards,
      "coupons": coupons
    };
    body.addAll(await _findDeviceInfo());
    return body;
  }

  Future<Map<String, String>> _findDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "id": await const AndroidId().getId() ?? "",
        "operatingSystem": "Android",
        "operatingSystemVersion": androidInfo.version.release ?? "",
        "brand": androidInfo.brand ?? "",
        "model": androidInfo.model ?? "",
        "name": androidInfo.device ?? "",
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "id": iosInfo.identifierForVendor ?? "",
        "operatingSystem": "IOS",
        "operatingSystemVersion": iosInfo.systemVersion ?? "",
        "brand": "Apple",
        "model": iosInfo.utsname.machine ?? "",
        "name": iosInfo.name ?? "",
      };
    }
    return {};
  }
}
