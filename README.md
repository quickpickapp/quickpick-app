<img src="assets/images/icon.png" width="72" align="right">

# QuickPick

Scribble something or type a line, pick a few friends, send. Only they can open it. The server just carries it along and can't read it.

This is the Flutter app. The backend lives in [quickpick-core](https://github.com/quickpickapp/quickpick-core).

![build](https://github.com/quickpickapp/quickpick-app/actions/workflows/flutter.yml/badge.svg)

## How a pick stays private

Each phone generates an RSA key pair on sign-up. The private half never leaves the device's secure storage.
When you send a pick, the app encrypts it with a fresh AES-256-GCM key and then wraps that key once per recipient with their public key (RSA-OAEP).
The server stores the ciphertext and the wrapped keys. It has nothing to unwrap them with.

The code is all in [`lib/crypto/crypto.dart`](lib/crypto/crypto.dart), about 150 lines. Worth a look if you don't believe me.

## Running it

```sh
flutter pub get
flutter run
```

Out of the box the app talks to the live server. To use your own core instance, change the endpoint in [`lib/config/environment_options.dart`](lib/config/environment_options.dart).

Sign-up works via SMS code, so you need a real phone number (or a test number configured in core).

## Languages

English and German, in [`assets/locales`](assets/locales). A new language is a JSON file plus a flag in the language picker (`lib/product/profile/profile_language_selection.dart`). PRs welcome.

## License

[AGPL-3.0](LICENSE.md)
