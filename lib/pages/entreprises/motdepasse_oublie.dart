import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:matabisi_admin/pages/login.dart';
import 'package:matabisi_admin/utils/requete.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;
  //
  var box = GetStorage();

  void _changePassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Les mots de passe ne correspondent pas');
      return;
    }

    if (_newPasswordController.text.length < 8) {
      _showErrorDialog('Le mot de passe doit contenir au moins 8 caractères');
      return;
    }

    setState(() => _isLoading = true);
    //
    Map user = box.read("user") ?? {};
    //
    PasswordService.updatePassword(
      newPassword: _newPasswordController.text,
      oldPassword: _oldPasswordController.text,
      token: user['token'],
    );
    // Simulation du traitement
    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Erreur'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Succès'),
              ],
            ),
            content: const Text(
              'Votre mot de passe a été modifié avec succès.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearForm();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _clearForm() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Container(
          width: 500,
          height: double.maxFinite,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SÉCURITÉ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Modifier le mot de passe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Carte de formulaire
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sécurité du compte',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pour votre sécurité, choisissez un mot de passe fort',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Ancien mot de passe
                      _buildPasswordField(
                        controller: _oldPasswordController,
                        label: 'Ancien mot de passe',
                        hintText: 'Entrez votre mot de passe actuel',
                        obscureText: _obscureOldPassword,
                        onToggle:
                            () => setState(
                              () => _obscureOldPassword = !_obscureOldPassword,
                            ),
                      ),

                      const SizedBox(height: 20),

                      // Nouveau mot de passe
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'Nouveau mot de passe',
                        hintText: 'Entrez votre nouveau mot de passe',
                        obscureText: _obscureNewPassword,
                        onToggle:
                            () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                        isNew: true,
                      ),

                      const SizedBox(height: 20),

                      // Confirmation mot de passe
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirmer le mot de passe',
                        hintText: 'Confirmez votre nouveau mot de passe',
                        obscureText: _obscureConfirmPassword,
                        onToggle:
                            () => setState(
                              () =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                            ),
                      ),

                      const SizedBox(height: 24),

                      // Indicateur de force du mot de passe
                      if (_newPasswordController.text.isNotEmpty)
                        _buildPasswordStrength(),

                      const Spacer(),

                      // Bouton de soumission
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _changePassword,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Mettre à jour le mot de passe',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    bool isNew = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.grey.shade500,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
        if (isNew) ...[
          const SizedBox(height: 8),
          Text(
            '• 8 caractères minimum\n• Lettres, chiffres et caractères spéciaux',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordStrength() {
    final password = _newPasswordController.text;
    int strength = 0;
    String message = 'Faible';
    Color color = Colors.red;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    if (strength >= 4) {
      message = 'Fort';
      color = Colors.green;
    } else if (strength >= 2) {
      message = 'Moyen';
      color = Colors.orange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Force du mot de passe: ',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength / 5,
          backgroundColor: Colors.grey.shade300,
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class PasswordService {
  static Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String
    token, // Le token JWT que vous avez reçu lors de la connexion
  }) async {
    final url = Uri.parse('${Requete.url}/auth/update-password');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Si vous utilisez Bearer token
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      // Mot de passe mis à jour avec succès
      Get.offAll(LoginScreen());
      return;
    } else if (response.statusCode == 400) {
      Get.snackbar("Erreur", 'Ancien mot de passe incorrect');
      //throw Exception('Ancien mot de passe incorrect');
    } else if (response.statusCode == 404) {
      Get.snackbar("Erreur", 'Entreprise non trouvée');
      //throw Exception('Entreprise non trouvée');
    } else {
      Get.snackbar("Erreur", 'Erreur lors de la mise à jour du mot de passe');
      //throw Exception('Erreur lors de la mise à jour du mot de passe');
    }
  }
}
