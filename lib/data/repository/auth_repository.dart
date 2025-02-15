import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final OAuthCredential authCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final UserCredential userCredential = await _auth.signInWithCredential(authCredential);
    return userCredential.user;
  }


  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
