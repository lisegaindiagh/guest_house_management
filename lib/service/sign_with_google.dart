import 'package:google_sign_in/google_sign_in.dart';

class SignInWithGoogleService {
  SignInWithGoogleService._internal();

  static final SignInWithGoogleService instance =
  SignInWithGoogleService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
      'https://www.googleapis.com/auth/gmail.send',
    ],
  );

  GoogleSignInAccount? _user;
  String? _accessToken;

  GoogleSignInAccount? get currentUser => _user;
  String? get accessToken => _accessToken;

  Future<GoogleSignInAccount?> signIn() async {
    final user = await _googleSignIn.signIn();
    if (user == null) return null;

    final auth = await user.authentication;

    _user = user;
    _accessToken = auth.accessToken;

    return user;
  }

  Future<void> signOut() async {
    _user = null;
    _accessToken = null;
    await _googleSignIn.disconnect();
  }
}
