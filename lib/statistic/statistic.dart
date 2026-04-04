import 'dart:convert';

import 'package:quickpick/config/statistic_options.dart';
import 'package:quickpick/request/request.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class QuickPickStatistic {
  QuickPickStatistic();

  Future<void> keep(context) async {
    sendAppOpen(context);
    sendUserJoin(context);
  }

  Future<void> sendAppOpen(context) async {
    var body = createStatisticBody();
    var info = await PackageInfo.fromPlatform();
    body["version"] = info.version;
    await Request.post(url: "/user/app/open/", body: body).send(context);
  }

  Future<void> sendUserJoin(context) async {
    const storage = FlutterSecureStorage();
    if (await storage.read(key: "alreadyOpened") != null) {
      return;
    }
    var body = createStatisticBody();
    var response =
        await Request.post(url: "/user/join/", body: body).send(context);
    if (response == null || response.statusCode == 409) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (!responseBody["success"]) {
      return;
    }
    await storage.write(key: "alreadyOpened", value: "true");
  }

  Map<String, Object> createStatisticBody() {
    return <String, Object>{"key": StatisticOptions.statisticKey};
  }
}
