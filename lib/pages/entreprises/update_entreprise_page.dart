import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:matabisi_admin/utils/requete.dart';

class UpdateEntreprisePage extends StatefulWidget {
  Map entreprise; // Id de l'entreprise à modifier
  UpdateEntreprisePage({super.key, required this.entreprise});

  @override
  State<UpdateEntreprisePage> createState() => _UpdateEntreprisePageState();
}

class _UpdateEntreprisePageState extends State<UpdateEntreprisePage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _imageBytes = await picked.readAsBytes();
      setState(() {});
    }
  }

  Future<void> _updateEntreprise() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une image")),
      );
      return;
    }

    // encoder en base64
    String logoBase64 = base64Encode(_imageBytes!);

    // map représentant ton entité Entreprise
    Map<String, dynamic> entrepriseMap = {
      "nom": widget.entreprise['nom'],
      "secteur": widget.entreprise['secteur'],
      "email": widget.entreprise['email'],
      "motDePasse": widget.entreprise['motDePasse'],
      "status": widget.entreprise['status'],
      "logo": logoBase64, // ton logo en base64
    };

    final url = Uri.parse(
      "${Requete.url}/api/Entreprise/${widget.entreprise['id']}",
    );

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(entrepriseMap),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entreprise mise à jour avec succès ✅")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: ${response.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier Entreprise")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _imageBytes != null
                  ? Image.memory(_imageBytes!, height: 120)
                  : const Text(
                    "Aucune image sélectionnée",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // couleur de fond
                  foregroundColor: Colors.white, // couleur du texte
                  maximumSize: Size(250, 45),
                  minimumSize: Size(250, 45),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // bouton arrondi
                  ),
                  elevation: 6,
                ),
                child: const Text("Choisir Logo"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateEntreprise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  maximumSize: Size(250, 45),
                  minimumSize: Size(250, 45),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Mettre à jour"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
