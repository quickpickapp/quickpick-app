import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quickpick/config/statistic_options.dart';
import 'package:quickpick/request/request.dart';

class QuickPickStatistic {
  QuickPickStatistic();

  Future<void> keep() async {
    sendAppOpening();
    sendAppInstallation();
  }

  Future<void> sendAppOpening() async {
    var body = createStatisticBody();
    var info = await PackageInfo.fromPlatform();
    body["version"] = info.version;
    await Request.post(url: "/statistic/app/opening/", body: body)
        .send();
  }

  Future<void> sendAppInstallation() async {
    const storage = FlutterSecureStorage();
    if (await storage.read(key: "installed") != null) {
      return;
    }
    var body = createStatisticBody();
    var response =
        await Request.post(url: "/statistic/app/installation/", body: body)
            .send();
    if (response == null || response.statusCode == 409) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return;
    }
    await storage.write(key: "installed", value: "true");
  }

  Map<String, Object> createStatisticBody() {
    return <String, Object>{"key": StatisticOptions.statisticKey};
  }
}
