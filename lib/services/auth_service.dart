import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Только этот импорт!
import 'package:zero_waste_chef/services/app_logger.dart'; // Наш логгер
import '../services/purchase_service.dart'; // Импорт сервиса покупок

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

      // Совершаем вход в Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // 🟢 ШАГ ПРИВЯЗКИ REVENUECAT: 
      // Если вход в Firebase успешен, сразу логинимся в RevenueCat
      if (user != null) {
        await PurchaseService.login(user.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      logger.e("Ошибка при входе через Google: $e");
      return null;
    }
  }


   Future<void> signOut() async {
    try {
      // 🟢 Сначала отвязываем подписки от RevenueCat
      await PurchaseService.logout();
      
      // Затем обычный выход из Firebase и Google
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      logger.e("Ошибка при выходе из аккаунта: $e");
    }
  }

}
