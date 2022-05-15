import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_app/firebase_cloudstore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const CloudDB(title: 'Flutter CloudFare Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String email = "aze.318a@gmail.com";
  String pass = "654321";
  late FirebaseAuth auth;
  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User cixis etdi');
      } else {
        debugPrint('User daxil oldu ${user.email}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  createUserEmailPassword();
                },
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: const Text("Email/Password create")),
            ElevatedButton(
                onPressed: () {
                  loginUserEmailPassword();
                },
                style: ElevatedButton.styleFrom(primary: Colors.blue),
                child: const Text("Email/Password login")),
            ElevatedButton(
                onPressed: () {
                  signOut();
                },
                style: ElevatedButton.styleFrom(primary: Colors.yellow),
                child: const Text("Cixis et")),
            ElevatedButton(
                onPressed: () {
                  deleteUser();
                },
                style: ElevatedButton.styleFrom(primary: Colors.grey),
                child: const Text("Sil")),
            ElevatedButton(
                onPressed: () {
                  changepassword();
                },
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: const Text("Sifre deyis")),
            ElevatedButton(
                onPressed: () {
                  changeEmail();
                },
                style: ElevatedButton.styleFrom(primary: Colors.purple),
                child: const Text("Email deyis")),
            ElevatedButton(
                onPressed: () {
                  googleSignin();
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue.shade400),
                child: const Text("Google ile giris")),
            ElevatedButton(
                onPressed: () {
                  phoneSignin();
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent.shade700),
                child: const Text("Telefon nomre ile giris")),
          ],
        ),
      ),
    );
  }

  void createUserEmailPassword() async {
    var _usercred =
        await auth.createUserWithEmailAndPassword(email: email, password: pass);
    var user = _usercred.user;

    if (!user!.emailVerified) {
      await user.sendEmailVerification();
      debugPrint("mail getdi");
    } else {
      debugPrint("okdi get bala");
    }
  }

  void loginUserEmailPassword() async {
    var _user =
        await auth.signInWithEmailAndPassword(email: email, password: pass);
    debugPrint("login oldu ${_user.user!.emailVerified.toString()}");
  }

  void signOut() async {
    if (GoogleSignIn().currentUser != null) {
      GoogleSignIn().signOut();
    }
    await auth.signOut();
  }

  void deleteUser() async {
    var _user = auth.currentUser;
    if (_user != null) {
      await auth.currentUser!.delete();
    }
  }

  void changepassword() async {
    try {
      await auth.currentUser!.updatePassword('123456');
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        var credential =
            EmailAuthProvider.credential(email: email, password: pass);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updatePassword('123456');
        await auth.signOut();
        debugPrint("password change");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void changeEmail() async {
    try {
      await auth.currentUser!.updateEmail('kamran@kamran.me');
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        var credential =
            EmailAuthProvider.credential(email: email, password: pass);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updateEmail('kamran@kamran.me');
        await auth.signOut();
        debugPrint("email change");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void googleSignin() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
    debugPrint(auth.currentUser!.email.toString());
  }

  void phoneSignin() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+994 55 562 5886',
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint(credential.toString());
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        String _smscode = '123456';
        var _credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _smscode);
        await auth.signInWithCredential(_credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint(verificationId);
      },
    );
  }
}
