import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickpick/alert/alert.dart';
import 'package:quickpick/alert/loader_alert.dart';
import 'package:quickpick/localization/locale_text.dart';
import 'package:quickpick/localization/locales.dart';
import 'package:quickpick/product/base/page.dart';
import 'package:quickpick/product/signup/signup_name_page.dart';
import 'package:quickpick/product/signup/signup_store.dart';
import 'package:quickpick/request/request.dart';

class SignupVerifyPage extends StatefulWidget {
  final String phoneNumber;

  const SignupVerifyPage({super.key, required this.phoneNumber});

  @override
  State<SignupVerifyPage> createState() => _SignupVerifyPageState();
}

class _SignupVerifyPageState extends State<SignupVerifyPage> {
  static const int _codeLength = 6;
  static const int _resendCooldown = 60;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());

  bool _isCodeValid = false;
  int _resendSecondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendSecondsLeft = _resendCooldown);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSecondsLeft--);
      return _resendSecondsLeft > 0;
    });
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _codeLength; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final nextFocus =
          (digits.length < _codeLength) ? digits.length : _codeLength - 1;
      FocusScope.of(context).requestFocus(_focusNodes[nextFocus]);
    } else if (value.length == 1) {
      if (index < _codeLength - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final isNowValid = _fullCode.length == _codeLength &&
        _fullCode.contains(RegExp(r'^\d{6}$'));

    setState(() {
      _isCodeValid = isNowValid;
    });

    if (isNowValid) {
      _onContinue();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].clear();
      setState(() => _isCodeValid = false);
    }
  }

  void _onContinue() async {
    if (!_isCodeValid) {
      return;
    }
    LoaderAlert().show(context);
    var body = <String, String>{
      "phone_number": widget.phoneNumber,
      "code": _fullCode
    };
    var response = await Request.post(url: "/signup/verify/code/", body: body)
        .send(context);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (response == null) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] != true) {
      Alert(
        description: "product.signup.verify.failed",
        type: AlertType.error,
      ).show(context);
      return;
    }
    if (responseBody["new_user"] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignupNamePage(
            phoneNumber: widget.phoneNumber,
            verificationToken: responseBody["verification_token"],
          ),
        ),
      );
      return;
    }
    await SignupStore().save(responseBody);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPage(),
      ),
    );
  }

  void _onResend() async {
    if (_resendSecondsLeft > 0) {
      return;
    }
    _startResendTimer();
    LoaderAlert().show(context);
    var body = <String, String>{"phone_number": widget.phoneNumber, "code": ""};
    var response = await Request.post(url: "/signup/request/code/", body: body)
        .send(context);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (response == null) {
      return;
    }
    var responseBody = jsonDecode(response.body);
    Alert(
      description:
          "product.signup.phone.${responseBody["success"] != true ? "failed" : "success"}",
      type:
          responseBody["success"] != true ? AlertType.error : AlertType.success,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _resendSecondsLeft == 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black12, height: 1.0),
        ),
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: true,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 50),
                        LocaleText(
                          "product.signup.verify.label",
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: Locales.string(context,
                                    "product.signup.verify.sent.prefix"),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                              TextSpan(
                                text: widget.phoneNumber,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_codeLength, (index) {
                            return SizedBox(
                              width: 44,
                              height: 56,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Visible box with centered digit
                                  Container(
                                    width: 44,
                                    height: 56,
                                    decoration: _buildBoxDecoration(index),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _controllers[index].text,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Invisible TextField on top to capture input
                                  KeyboardListener(
                                    focusNode: FocusNode(),
                                    onKeyEvent: (event) =>
                                        _onKeyEvent(index, event),
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(1),
                                      ],
                                      onChanged: (value) =>
                                          _onDigitChanged(index, value),
                                      style: const TextStyle(
                                          color: Colors.transparent),
                                      cursorColor: Colors.transparent,
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        filled: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Locales.string(
                                  context, "product.signup.verify.no.code"),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: canResend ? _onResend : null,
                              child: canResend
                                  ? Text(
                                      Locales.string(context,
                                          "product.signup.verify.resend"),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : Text(
                                      Locales.string(context,
                                              "product.signup.verify.resend.wait")
                                          .replaceAll("%SECONDS%",
                                              _resendSecondsLeft.toString()),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              _isCodeValid
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.5),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 16),
                            ),
                            minimumSize: WidgetStateProperty.all(
                              const Size(double.infinity, 0),
                            ),
                            alignment: Alignment.center,
                          ),
                          onPressed: _isCodeValid ? _onContinue : null,
                          icon: Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          label: LocaleText(
                            "product.signup.continue",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(int index) {
    final isFilled = _controllers[index].text.isNotEmpty;
    final borderColor =
        isFilled ? Theme.of(context).colorScheme.primary : Colors.grey;

    return BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 2.0),
    );
  }
}
