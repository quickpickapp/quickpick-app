import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickpick/localization/locale_text.dart';

class SignupVerifyPage extends StatefulWidget {
  final String phoneNumber;

  const SignupVerifyPage({super.key, required this.phoneNumber});

  @override
  State<SignupVerifyPage> createState() => _SignupVerifyPageState();
}

class _SignupVerifyPageState extends State<SignupVerifyPage> {
  static const int _codeLength = 6;

  final List<TextEditingController> _controllers =
  List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(_codeLength, (_) => FocusNode());

  bool _isCodeValid = false;

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

  String get _fullCode =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste: distribute digits across boxes
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _codeLength; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final nextFocus = (digits.length < _codeLength)
          ? digits.length
          : _codeLength - 1;
      FocusScope.of(context).requestFocus(_focusNodes[nextFocus]);
    } else if (value.length == 1) {
      if (index < _codeLength - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
      }
    }

    setState(() {
      _isCodeValid = _fullCode.length == _codeLength &&
          _fullCode.contains(RegExp(r'^\d{6}$'));
    });
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].clear();
      setState(() {
        _isCodeValid = false;
      });
    }
  }

  void _onContinue() {
    if (!_isCodeValid) return;

  }

  void _onResend() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.black12, height: 1.0),
        ),
      ),
      backgroundColor: Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: true,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
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
                        SizedBox(height: 50),
                        LocaleText(
                          "product.signup.verify.label",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "We sent a 6-digit code to ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              TextSpan(
                                text: widget.phoneNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_codeLength, (index) {
                            return SizedBox(
                              width: 44,
                              height: 56,
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (event) =>
                                    _onKeyEvent(index, event),
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  onChanged: (value) =>
                                      _onDigitChanged(index, value),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    border: _buildBoxBorder(index),
                                    enabledBorder: _buildBoxBorder(index),
                                    focusedBorder: _buildBoxBorder(index),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive a code? ",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            GestureDetector(
                              onTap: _onResend,
                              child: Text(
                                "Resend",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              _isCodeValid
                                  ? Colors.indigo
                                  : Colors.indigo[200],
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(vertical: 16),
                            ),
                            minimumSize: WidgetStateProperty.all(
                              Size(double.infinity, 0),
                            ),
                            alignment: Alignment.center,
                          ),
                          onPressed: _isCodeValid ? _onContinue : null,
                          icon: Container(
                            margin: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          label: LocaleText(
                            "product.signup.continue",
                            style: TextStyle(
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

  OutlineInputBorder _buildBoxBorder(int index) {
    final isFilled = _controllers[index].text.isNotEmpty;
    Color borderColor;
    if (!isFilled) {
      borderColor = Colors.grey;
    } else {
      borderColor = _isCodeValid ? Colors.green : Colors.indigo;
    }
    return OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 2.0),
      borderRadius: BorderRadius.circular(12),
    );
  }
}