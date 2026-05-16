import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/auth_input_validator.dart';
import 'package:green_miles_app/viewmodel/auth_viewmodel.dart';
import 'package:green_miles_app/viewmodel/profile_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  /// The email as it was when the screen opened — used to detect changes.
  String _originalEmail = '';

  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarFileName;
  String? _selectedAvatarContentType;

  bool _isDirectImageUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    if (uri.host.contains('google.com') && uri.path.contains('imgres')) {
      return false;
    }
    return true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      setState(() {
        _selectedAvatarBytes = bytes;
        _selectedAvatarFileName = xFile.name;
        _selectedAvatarContentType = xFile.mimeType;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<ProfileViewModel>().user;
    if (user != null && _nameController.text.isEmpty) {
      _nameController.text = user.name;
      _avatarUrlController.text = user.profileImageUrl;
      _originalEmail = user.email;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileViewModel = context.read<ProfileViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final newEmail = _emailController.text.trim();
    final emailChanged =
        newEmail.toLowerCase() != _originalEmail.toLowerCase();

    // 1. Save name + avatar (regardless of email change)
    final profileSuccess = await profileViewModel.updateProfile(
      name: _nameController.text,
      currentAvatarUrl: _avatarUrlController.text,
      newAvatarBytes: _selectedAvatarBytes,
      newAvatarFileName: _selectedAvatarFileName,
      newAvatarContentType: _selectedAvatarContentType,
    );

    if (!mounted) return;

    // 2. If email changed, initiate the verification flow
    if (emailChanged) {
      final emailSuccess = await authViewModel.updateEmail(newEmail);

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      if (profileSuccess && emailSuccess) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              '${AppStrings.profileSaved}\n${AppStrings.emailUpdateSent}',
            ),
            duration: Duration(seconds: 7),
          ),
        );
        Navigator.of(context).pop();
      } else if (!profileSuccess) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              profileViewModel.profileSaveError ?? AppStrings.profileSaveFailed,
            ),
          ),
        );
      } else {
        // Profile saved but email change failed
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.profileSaved} — ${authViewModel.error ?? AppStrings.emailUpdateFailed}',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    // 3. No email change — normal profile save feedback
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          profileSuccess
              ? AppStrings.profileSaved
              : (profileViewModel.profileSaveError ?? AppStrings.profileSaveFailed),
        ),
      ),
    );
    if (profileSuccess) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileViewModel>().user;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editProfile)),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (user == null) {
            return const Center(child: Text('No profile data available.'));
          }

          final isBusy = viewModel.isSavingProfile ||
              context.watch<AuthViewModel>().isLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.nameLabel,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.requiredField;
                      }
                      if (!AuthInputValidator.isValidName(value)) {
                        return AppStrings.nameTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email (editable — triggers verification on change)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: AppStrings.emailLabel,
                      helperText: 'Changing email sends a verification link',
                      helperMaxLines: 2,
                      suffixIcon: _emailController.text.trim().toLowerCase() !=
                              _originalEmail.toLowerCase()
                          ? const Tooltip(
                              message:
                                  'A verification email will be sent on save',
                              child: Icon(Icons.mark_email_unread_outlined,
                                  size: 20),
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.requiredField;
                      }
                      if (!AuthInputValidator.isValidEmail(value.trim())) {
                        return AppStrings.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Avatar picker
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        if (viewModel.isSavingProfile) return;
                        await _pickImage();
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _selectedAvatarBytes != null
                                ? (MemoryImage(_selectedAvatarBytes!)
                                    as ImageProvider)
                                : null,
                            child: _selectedAvatarBytes == null
                                ? (_isDirectImageUrl(_avatarUrlController.text)
                                    ? ClipOval(
                                        child: Image.network(
                                          _avatarUrlController.text,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, e, s) =>
                                              const Icon(Icons.person,
                                                  size: 50),
                                        ),
                                      )
                                    : const Icon(Icons.person, size: 50))
                                : null,
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child:
                                  Icon(Icons.camera_alt, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isBusy ? null : _save,
                    child: isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(AppStrings.saveProfile),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
