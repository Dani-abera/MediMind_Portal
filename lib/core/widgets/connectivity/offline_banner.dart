import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/connectivity_cubit.dart';

class OfflineBanner extends StatelessWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        return Column(
          children: [
            if (status == ConnectivityStatus.offline)
              Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'No internet connection — changes may not be saved',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
