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
      setState((){
        _isLoading = true;
      });
      try {
        var x = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text
        );
      } catch(e){
        _showError(context, e);
      }
      setState((){
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle(context) async {
    if (_formKey.currentState!.validate()) {
      setState((){
        _isLoading = true;
      });
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
      setState((){
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithFacebook(context) async {
    if (_formKey.currentState!.validate()) {
      setState((){
        _isLoading = true;
      });
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
      setState((){
        _isLoading = false;
      });
    }
  }


  void _showError(context, message){
    final snackBar = SnackBar(
      content: Text('$message'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child:Text("Login", style: TextStyle(fontSize: 25),)
                  ),
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
                  Container(
                      child:
                      _isLoading ? const CircularProgressIndicator() : Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child:  ElevatedButton(
                            onPressed: (){_signInWithEmailAndPassword(context);},
                            child: const Text('Sign in with email'),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 50),
                          child:  MaterialButton(
                            color: Colors.blue[500],
                            elevation: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 30.0,
                                  width: 30.0,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage('assets/images/google.png'),
                                        fit: BoxFit.cover),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text("Sign In with Google")
                              ],
                            ),

                            // by onpressed we call the function signup function
                            onPressed: (){_signInWithGoogle(context);},
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child:  ElevatedButton(
                            onPressed: (){_signInWithFacebook(context);},
                            child: const Text('Sign in with Facebook'),
                          ),
                        ),
                      ],)
                  )
                ],
              ),
            )
        )
    );
  }
}
