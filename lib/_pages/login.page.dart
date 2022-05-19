import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(text: "nafish.ahmed.dev@gmail.com");
  final TextEditingController _passwordController = TextEditingController(text: "@#Password123@#");


  bool _isLoading = false;



  Future<void> _signInWithEmailAndPassword(_context) async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog(context);
      try {
        var x = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text
        );
      } catch(e){
        _showError(context, "Invalid email or password");
      }
      Navigator.pop(context);
    }
  }

  Future<void> _signInWithGoogle(context) async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog(context);
      try {
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        var x = await FirebaseAuth.instance.signInWithCredential(credential);
        debugPrint('Got credential ===> $x');
      } catch(e){
        debugPrint('Got error => $e');
        _showError(context, e);
      }
      Navigator.pop(context);
    }
  }

  Future<void> _signInWithFacebook(context) async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog(context);
      try {
        final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile
        // or FacebookAuth.i.login()
        if (result.status == LoginStatus.success) {
          // you are logged
          final AccessToken accessToken = result.accessToken!;
          // Create a credential from the access token
          final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);
          var x = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
          debugPrint('Got credential ===> $x');
        } else{
          throw Exception("Something went wrong");
        }
      } catch(e){
        debugPrint('Got Error ==> $e');
        _showError(context, e);
      }
      Navigator.pop(context);
    }
  }


  void _showError(context, message){
    final snackBar = SnackBar(
      content: Text('$message', style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.red[900],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showLoadingDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20,),
          Container(margin: const EdgeInsets.only(left: 7),child:const Text("Logging in" )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child:SingleChildScrollView(
                child: Column(
                    children:[
                      SizedBox(height: 50,),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 25),
                        child: Image.network("https://www.clip.bike/wp-content/uploads/2020/09/Clip-Favicon.png", height: 100, width: 100,),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                        child: Text("Hello Again!", style: TextStyle(fontSize: 25),),
                      ),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(25,4,25,25),
                          child: SizedBox(
                            width: 200,
                            child: Text("Welcome back you have been missed",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [

                            Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                                child:TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    label: Text("Email"),
                                    hintText: 'Enter your email',
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email cannot be blank';
                                    }
                                    if(!RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(value)){
                                      return "Please enter valid email";
                                    }
                                    return null;
                                  },
                                )
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                                child:TextFormField(
                                  controller: _passwordController,
                                  decoration: const InputDecoration(
                                    label: Text("Password"),
                                    hintText: 'Enter your password',
                                  ),
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter valid password';
                                    }
                                    return null;
                                  },
                                )
                            ),

                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child:
                          _isLoading ? const CircularProgressIndicator() : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                  child:  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: const Size.fromHeight(45),
                                    ),
                                    onPressed: (){_signInWithEmailAndPassword(context);},
                                    child: const Text('Sign In'),
                                  ),
                                ),
                                const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: SizedBox(
                                      width: 200,
                                      child: Text("or sign in with",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: MaterialButton(
                                          color: Colors.white,
                                          onPressed: (){_signInWithGoogle(context);},
                                          padding: EdgeInsets.zero,
                                          shape: const CircleBorder(),
                                          child: Image.asset("assets/images/google.png", height: 40,),
                                        ),
                                      ),
                                      Flexible(
                                        child: MaterialButton(
                                          color: Colors.white,
                                          onPressed: (){_signInWithFacebook(context);},
                                          padding: EdgeInsets.zero,
                                          shape: const CircleBorder(),
                                          child: Image.asset("assets/images/facebook.png", height: 40,),
                                        ),
                                      ),
                                    ],
                                  ),
                                )

                              ]
                          )
                      )
                    ]
                )
            )
        )
    );
  }
}
