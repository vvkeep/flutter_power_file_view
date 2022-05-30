import 'package:flutter/material.dart';
import 'package:power_file_view/power_file_view.dart';

class PowerErrorWidget extends StatelessWidget {
  final PowerViewType viewType;
  final String errorMsg;
  final VoidCallback retryOnTap;

  const PowerErrorWidget({Key? key, required this.viewType, required this.errorMsg, required this.retryOnTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PowerLocalizations local = PowerLocalizations.of(context);
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMsg,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: retryOnTap,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              shape: MaterialStateProperty.all(const StadiumBorder()),
            ),
            child: SizedBox(
              width: 80,
              child: Center(
                child: Text(
                  local.reload,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
