import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/view/main_screen.dart';
import 'package:green_miles_app/viewmodel/location_permission_viewmodel.dart';
import 'package:green_miles_app/view/widgets/buttons.dart';
import 'package:provider/provider.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.locationPermissionTitle)),
      body: Consumer<LocationPermissionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.granted) {
            final navigator = Navigator.of(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            });
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.location_on, size: 86, color: AppTheme.primaryColor),
                        const SizedBox(height: 18),
                        Text(AppStrings.locationPermissionTitle, style: textTheme.headlineSmall, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(AppStrings.locationPermissionDesc, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        EcoPrimaryButton(
                          label: AppStrings.allowLocation,
                          onPressed: viewModel.isRequesting ? null : viewModel.requestPermission,
                          isLoading: viewModel.isRequesting,
                          icon: Icons.location_searching,
                        ),
                        const SizedBox(height: 12),
                        EcoOutlinedButton(
                          label: AppStrings.denyLocation,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const MainScreen()),
                            );
                          },
                          icon: Icons.close,
                        ),
                        if (viewModel.error != null) ...[
                          const SizedBox(height: 12),
                          Text(viewModel.error!, style: textTheme.bodyMedium?.copyWith(color: Colors.red), textAlign: TextAlign.center),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
