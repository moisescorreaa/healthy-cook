import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Flexible(
          flex: 2,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    width: 100,
                    child: Image.network(
                        "https://img.freepik.com/icones-gratis/mac-os_318-10374.jpg?w=740&t=st=1688499535~exp=1688500135~hmac=18e7a8565d35d76b456c1359c83fb8834ba0a6f27d6b4364c7647d01bf57f22b"),
                  ),
                ),
                Form(
                    child: Column(
                  children: [
                    TextFormField(),
                    TextFormField(),
                  ],
                ))
              ],
            ),
          ),
        ),
        Flexible(
            flex: 1,
            child: Container(
              color: Colors.blue,
            ))
      ],
    ));
  }
}
