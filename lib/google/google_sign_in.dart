import 'package:google_sign_in/google_sign_in.dart';

class QuickPickGoogleSignIn {
  static const String clientId =
      "862018629934-j8dtsmu1vqcu4tuh09lkk8agoaop1cho.apps.googleusercontent.com";
  static const String serverClientId =
      "862018629934-72a04nvjcku5unlfcp3v429f7i9o8008.apps.googleusercontent.com";

  Future<void> setup() async {
    GoogleSignIn signIn = GoogleSignIn.instance;
    return signIn.initialize(
        clientId: clientId, serverClientId: serverClientId);
  }
}
