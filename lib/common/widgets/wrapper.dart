import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Wrapper extends StatefulWidget {
  final Widget child;

  const Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool shouldPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: shouldPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          setState(() {
            shouldPop = true;
          });
        }
      },
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: widget.child,
        ),
      ),
    );
  }
}
