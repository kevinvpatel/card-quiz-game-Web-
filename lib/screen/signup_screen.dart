import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:swipecard_app/constants/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();


  textField({required double width, required String title, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15),),
        const SizedBox(height: 4),
        SizedBox(
          height: 45,
          width: width,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(18),
                hintStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide()),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(255, 66, 0, 1)))
            ),
          ),
        )
      ],
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> createUser() async {
    User? user;
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: txtEmail.text.toLowerCase().trim(), password: txtPassword.text.trim());
      user = credential.user!;
    } on FirebaseException catch(err) {
      print('Email Sign up err -> $err');
      alert(err.message ?? 'Something Wrong', context);
    }
    return user!;
  }


  @override
  Widget build(BuildContext context) {
    double width = 390;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: height,
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            // color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.1),
                const Text('Let\'s get to know each other', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                SizedBox(height: height * 0.045),
                const Text('We\'ll only use your info for genetic    assessment purposes.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),

                const Spacer(),
                textField(width: width, title: 'First Name', controller: txtFirstName),
                SizedBox(height: height * 0.03),
                textField(width: width, title: 'Last Name', controller: txtLastName),
                SizedBox(height: height * 0.03),
                textField(width: width, title: 'Email', controller: txtEmail),
                SizedBox(height: height * 0.03),
                textField(width: width, title: 'Password', controller: txtPassword),
                SizedBox(height: height * 0.045),
                Wrap(
                  children: const [
                    Text('By selecting next, you\'ve read and agree to'),
                    Text(' Terms of Use', style: TextStyle(color: blueThemeColor),),
                    Text('  and'),
                    Text('  Privacy Policy.', style: TextStyle(color: blueThemeColor),),
                  ],
                ),

                const Spacer(flex: 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48,
                        width: width * 0.35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: orangeThemeColor, width: 1.8)
                        ),
                        child: const Text('Back' , style: TextStyle(color: orangeThemeColor, fontWeight: FontWeight.w600),),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if(txtPassword.text.length < 6) {
                          alert('Password should be at least 6 characters', context);
                        } else {
                          createUser().then((value) {
                            _auth.signOut();
                            Get.back();
                          });
                        }
                      },
                      child: Container(
                        height: 48,
                        width: width * 0.35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: orangeThemeColor,
                            border: Border.all(color: orangeThemeColor, width: 1.5)
                        ),
                        child: const Text('Submit' , style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.1),
              ],
            ),
          )
        ],
      ),
    );
  }

}