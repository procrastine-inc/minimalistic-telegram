import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: Column(
              children: const [
                // Image.asset(
                //   'assets/images/app_logo.png',
                //   scale: 3.4,
                // ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'appVersion',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
