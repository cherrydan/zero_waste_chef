import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Только этот импорт!
import 'package:zero_waste_chef/services/app_logger.dart'; // Наш логгер
    


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // ИСПОЛЬЗУЕМ .standard() - он нужен для google_sign_in ^6.2.1
      final GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: ['email']);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      logger.e("Ошибка при входе через Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    // Здесь тоже используем .standard() для google_sign_in ^6.2.1
    final GoogleSignIn googleSignIn = GoogleSignIn.standard();
    await googleSignIn.signOut();
    await _auth.signOut();
  }
}
