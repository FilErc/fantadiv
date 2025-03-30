import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Metodo per il login con email e password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      throw Exception("Errore di accesso: ${e.toString()}");
    }
  }
  // Metodo per il logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
