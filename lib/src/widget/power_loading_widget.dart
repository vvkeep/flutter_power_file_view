import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PowerLoadingWidget extends StatefulWidget {
  final String msg;

  const PowerLoadingWidget({Key? key, required this.msg}) : super(key: key);

  @override
  State<PowerLoadingWidget> createState() => _PowerLoadingWidgetState();
}

class _PowerLoadingWidgetState extends State<PowerLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(
                radius: 14.0,
                color: Colors.white,
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                child: Text(
                  widget.msg,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
