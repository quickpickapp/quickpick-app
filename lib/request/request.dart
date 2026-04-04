import 'dart:convert';

import 'package:quickpick/config/environment_options.dart';
import 'package:quickpick/request/request_refresh.dart';
import 'package:quickpick/request/request_reset.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

class Request {
  final String url;
  final String method;
  final Map<String, String> headers;
  final Map<String, Object> body;
  static final RequestRefresh _refresh = RequestRefresh();
  static const int _timeout = 5;
  static const int _maxRetries = 3;
  int _retries = 0;

  Request.get(
      {required String url, this.headers = const {}, this.body = const {}})
      : url = "https://${EnvironmentOptions.environment.endpoint}/v1$url",
        method = "GET";

  Request.post(
      {required String url, this.headers = const {}, this.body = const {}})
      : url = "https://${EnvironmentOptions.environment.endpoint}/v1$url",
        method = "POST";

  Future<Response?> send(context) async {
    Map<String, String> headers = Map.from(this.headers);
    headers["Content-Type"] = "application/json; charset=UTF-8";
    const storage = FlutterSecureStorage();
    String authenticationToken =
        await storage.read(key: "authenticationToken") ?? "";
    if (authenticationToken != "") {
      headers["Authorization"] = "Bearer $authenticationToken";
    }
    var response = await generateResponse(headers);
    return processResponse(context, response, headers);
  }

  Future<Response?> processResponse(context, response, headers) async {
    if (response == null && _retries < _maxRetries) {
      _retries += 1;
      await Future.delayed(Duration(milliseconds: 500 * _retries));
      var response = await generateResponse(headers);
      return processResponse(context, response, headers);
    }
    if (response?.statusCode == 403) {
      await RequestReset().reset(context);
      return response;
    }
    if (response?.statusCode == 417) {
      var refreshResult = await _refresh.refresh(context);
      if (refreshResult == true) {
        return await send(context);
      }
      return response;
    }
    return response;
  }

  Future<Response?> generateResponse(headers) async {
    if (method == "GET") {
      try {
        return await get(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: _timeout));
      } catch (exception) {
        return null;
      }
    } else if (method == "POST") {
      try {
        Map<String, Object> body = Map.from(this.body);
        return await post(Uri.parse(url),
                headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: _timeout));
      } catch (exception) {
        return null;
      }
    } else {
      throw UnsupportedError("Unsupported HTTP method: $method");
    }
  }
}
