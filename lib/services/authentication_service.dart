import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:letshang/services/message_service.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class AuthenticationService {
  static Future<FirebaseApp> initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  static Future<User?> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        CalendarApi.calendarEventsScope,
      ],
    );

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
    }

    return user;
  }

  static Future<GoogleSignInAuthentication?> enableGoogleCalendarSync() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[CalendarApi.calendarScope],
    );

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      return googleSignInAuthentication;
    }

    return null;
  }

  static Future<void> signInEmailPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception("The password provided is too weak");
      } else if (e.code == 'email-already-in-use') {
        throw Exception("Email already in use");
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An error occured signing in");
    }
  }

  static Future<void> createEmailPasswordAccount(
      String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception("The password provided is too weak");
      } else if (e.code == 'email-already-in-use') {
        throw Exception("Email already in use");
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An error occured creating the account");
    }
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      MessageService.showErrorMessage(
          content: 'Error signing out of Google', context: context);
    }
  }
}
