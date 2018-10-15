library custom_splash_screen;

import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';


class CustomSplashScreen extends StatefulWidget {
  final int seconds;
  final dynamic navigateAfterSeconds;
  final Widget errorSplash;
  final Widget loadingSplash;
  final Color backgroundColor;


  CustomSplashScreen(
      {
        @required this.backgroundColor,
        @required this.seconds,
        @required this.loadingSplash,
        @required this.navigateAfterSeconds,
        @required this.errorSplash
      });

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}



class _CustomSplashScreenState extends State<CustomSplashScreen> {

  bool _connection = true;

  String _connectionStatus;
  final Connectivity _connectivity = new Connectivity();

  //For subscription to the ConnectivityResult stream
  StreamSubscription<ConnectivityResult> _connectionSubscription;
  @override
  void initState(){
    super.initState();

    initConnectivity();

    _connectionSubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {

          setState(() {
            _connectionStatus = result.toString();
          });
        });
    //print("Initstate : $_connectionStatus");

  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }

  Future<Null> initConnectivity() async {
    String connectionStatus;

    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    }catch (e) {
      print(e.toString());
      //connectionStatus = "Internet connectivity failed";
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
    //print("InitConnectivity : $_connectionStatus");
    if(_connectionStatus == "ConnectivityResult.mobile" || _connectionStatus == "ConnectivityResult.wifi") {

      Timer(Duration(seconds: widget.seconds), () {
        if (widget.navigateAfterSeconds is String) {

          return Navigator.of(context)
              .pushReplacementNamed(widget.navigateAfterSeconds);
        } else if (widget.navigateAfterSeconds is Widget) {
          return Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) =>
              widget.navigateAfterSeconds));
        }
      });
    } else {
      setState(() {
        _connection = false;
      });
      //print("You are not connected to internet");
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: widget.backgroundColor,
          body: _connection
              ? widget.loadingSplash
              : widget.errorSplash
      ),
    );
  }

}
