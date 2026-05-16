import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/auth_input_validator.dart';
import 'package:green_miles_app/viewmodel/auth_viewmodel.dart';
import 'package:green_miles_app/viewmodel/settings_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadSettings,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (viewModel.error != null) ...[
                  Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                ],
                const ListTile(
                  title: Text(AppStrings.notificationPreferences),
                ),
                SwitchListTile.adaptive(
                  value: viewModel.settings.pushEnabled,
                  title: const Text(AppStrings.pushNotifications),
                  onChanged: viewModel.updatePushEnabled,
                ),
                SwitchListTile.adaptive(
                  value: viewModel.settings.emailEnabled,
                  title: const Text(AppStrings.emailNotifications),
                  onChanged: viewModel.updateEmailEnabled,
                ),
                SwitchListTile.adaptive(
                  value: viewModel.settings.weeklySummaryEnabled,
                  title: const Text(AppStrings.weeklySummary),
                  onChanged: viewModel.updateWeeklySummaryEnabled,
                ),
                const Divider(height: 28),
                SwitchListTile.adaptive(
                  value: viewModel.settings.profileVisible,
                  title: const Text(AppStrings.profileVisibility),
                  subtitle: const Text(AppStrings.profileVisibilityHint),
                  onChanged: viewModel.updateProfileVisible,
                ),
                const Divider(height: 28),
                ListTile(
                  leading: const Icon(Icons.lock_rounded),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  onTap: () {
                    final formKey = GlobalKey<FormState>();
                    final passwordController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Change Password'),
                          content: Form(
                            key: formKey,
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'New Password'),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Password cannot be empty';
                                if (!AuthInputValidator.isComplexPassword(val)) {
                                  return 'Password must contain uppercase, lowercase, number, symbol & 8+ chars';
                                }
                                return null;
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final vm = context.read<AuthViewModel>();
                                  final nav = Navigator.of(context);
                                  final messenger = ScaffoldMessenger.of(context);
                                  final success = await vm.updatePassword(passwordController.text);
                                  nav.pop();
                                  messenger.showSnackBar(SnackBar(
                                    content: Text(success ? 'Password updated successfully' : (vm.error ?? 'Failed to update password')),
                                  ));
                                }
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email_rounded),
                  title: const Text(AppStrings.changeEmail),
                  subtitle: const Text(AppStrings.changeEmailSubtitle),
                  onTap: () {
                    final formKey = GlobalKey<FormState>();
                    final emailController = TextEditingController();
                    final currentEmail =
                        context.read<AuthViewModel>().isAuthenticated
                            ? (Supabase.instance.client.auth.currentUser?.email ?? '')
                            : '';
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text(AppStrings.changeEmail),
                          content: Form(
                            key: formKey,
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: AppStrings.newEmailLabel,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return AppStrings.requiredField;
                                }
                                if (!AuthInputValidator.isValidEmail(val.trim())) {
                                  return AppStrings.invalidEmail;
                                }
                                if (val.trim().toLowerCase() ==
                                    currentEmail.toLowerCase()) {
                                  return AppStrings.emailNotChanged;
                                }
                                return null;
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final vm = context.read<AuthViewModel>();
                                  final nav = Navigator.of(dialogContext);
                                  final messenger = ScaffoldMessenger.of(context);
                                  final success = await vm.updateEmail(
                                    emailController.text.trim(),
                                  );
                                  nav.pop();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? AppStrings.emailUpdateSent
                                            : (vm.error ??
                                                AppStrings.emailUpdateFailed),
                                      ),
                                      duration: const Duration(seconds: 6),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Send Verification'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: viewModel.isSaving
                      ? null
                      : () async {
                          final success = await context
                              .read<SettingsViewModel>()
                              .saveSettings();
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? AppStrings.settingsSaved
                                    : (viewModel.error ??
                                        AppStrings.settingsSaveFailed),
                              ),
                            ),
                          );
                        },
                  child: viewModel.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.saveSettings),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    await context.read<AuthViewModel>().logout();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(AppStrings.logout),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

