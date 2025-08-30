import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EntrepriseUpdateForm extends StatefulWidget {
  final Map<String, dynamic> entreprise; // JSON reçu du backend

  const EntrepriseUpdateForm({super.key, required this.entreprise});

  @override
  State<EntrepriseUpdateForm> createState() => _EntrepriseUpdateFormState();
}

class _EntrepriseUpdateFormState extends State<EntrepriseUpdateForm> {
  late TextEditingController nomController;
  late TextEditingController secteurController;
  late TextEditingController emailController;
  late TextEditingController motDePasseController;
  int status = 1;

  Uint8List? logoBytes; // Pour stocker le fichier image sélectionné

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.entreprise["nom"] ?? "");
    secteurController = TextEditingController(
      text: widget.entreprise["secteur"] ?? "",
    );
    emailController = TextEditingController(
      text: widget.entreprise["email"] ?? "",
    );
    motDePasseController = TextEditingController(
      text: widget.entreprise["motDePasse"] ?? "",
    );
    status = widget.entreprise["status"] ?? 1;

    // si le backend renvoie déjà un logo en base64, tu peux le décoder ici
    // logoBytes = base64Decode(widget.entreprise["logo"]);
  }

  @override
  void dispose() {
    nomController.dispose();
    secteurController.dispose();
    emailController.dispose();
    motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // permet d'avoir le Uint8List directement
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        logoBytes = result.files.first.bytes;
      });
    }
  }

  void _mettreAJour() {
    final updated = {
      "id": widget.entreprise["id"],
      "nom": nomController.text,
      "secteur": secteurController.text,
      "email": emailController.text,
      "motDePasse": motDePasseController.text,
      "status": status,
      "logo": logoBytes, // envoyée comme byte[]
    };

    // TODO: Envoyer updated au backend via Dio ou http
    print("Mise à jour : $updated");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Entreprise mise à jour avec succès ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Mettre à jour l'entreprise",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Aperçu du logo
              InkWell(
                onTap: _pickLogo,
                child:
                    logoBytes != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            logoBytes!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.upload,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: secteurController,
                decoration: const InputDecoration(
                  labelText: "Secteur",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: motDePasseController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                value: status,
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Actif")),
                  DropdownMenuItem(value: 0, child: Text("Inactif")),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => status = val);
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _mettreAJour,
                child: const Text(
                  "Mettre à jour",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
