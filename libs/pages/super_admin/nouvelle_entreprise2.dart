import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matabisi_admin/pages/super_admin/liste_entreprise.dart';
import 'package:matabisi_admin/pages/super_admin/super_admin_controller.dart';

class EntrepriseFormPage extends StatefulWidget {
  const EntrepriseFormPage({super.key});

  @override
  State<EntrepriseFormPage> createState() => _EntrepriseFormPageState();
}

class _EntrepriseFormPageState extends State<EntrepriseFormPage> {
  final _formKey = GlobalKey<FormState>();

  String nom = "";
  String secteur = "";
  String email = "";
  String motDePasse = "";
  Uint8List? logo;
  RxBool nouveau = false.obs;
  RxInt n1 = 1.obs;
  //
  SuperAdminController superAdminController = Get.find();
  //
  final List<String> entreprises = [
    "Supermarché",
    "Boulangerie",
    "Pharmacie",
    "Cosmetique",
    "Télécom",
    "Salon de beauté",
    "Restaurant",
    "Station-service",
    "Boutique",
    "Magasin de vêtements",
    "Librairie",
    "Clinique Médicale",
  ];
  //
  String? selectedEntreprise;
  //

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        logo = result.files.first.bytes;
      });
    }
  }

  void _enregistrer() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ici tu envoies les données à ton API
      print("Nom: $nom, Secteur: $secteur, Email: $email");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Entreprise enregistrée ✅")));
      /**
       * */
      Map e = {
        "logo": logo,
        "nom": nom,
        "secteur": selectedEntreprise!, // ex: cosmétique, télécom, boulangerie
        "email": email,
        "status": 1,
        "motDePasse": "1234567",
      };
      //
      Get.dialog(
        Center(
          child: Container(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(),
          ),
        ),
      );
      //
      superAdminController.enregistrerEntreprise(e);

      setState(() {
        nom = "";
        secteur = "";
        email = "";
        motDePasse = "";
        logo = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar style WhatsApp
          Container(
            width: 260,
            color: const Color(0xFF111B21),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Entreprises",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _menuItem("Nouvelle entreprise", 1),
                const SizedBox(height: 10),
                _menuItem("Liste", 2),
              ],
            ),
          ),

          // Contenu principal
          Expanded(
            child: Obx(
              () =>
                  n1.value == 2
                      ? EntrepriseListPage()
                      : Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F7F7),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black12,
                                  width: 1,
                                ),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Ajouter une entreprise",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Formulaire
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _logoPicker(),
                                    const SizedBox(height: 20),
                                    _textField(
                                      "Nom de l'entreprise",
                                      (val) => nom = val!,
                                      initial: nom,
                                    ),
                                    // const SizedBox(height: 15),
                                    // _textField(
                                    //   "Secteur",
                                    //   (val) => secteur = val!,
                                    //   initial: secteur,
                                    // ),
                                    const SizedBox(height: 15),
                                    _textField(
                                      "Email",
                                      (val) => email = val!,
                                      initial: email,
                                      keyboard: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      padding: EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[100],
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: "Secteur",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        value: selectedEntreprise,
                                        items:
                                            entreprises.map((e) {
                                              return DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedEntreprise = value;
                                          });
                                        },
                                      ),
                                    ),
                                    // _textField(
                                    //   "Mot de passe",
                                    //   (val) => motDePasse = val!,
                                    //   initial: motDePasse,
                                    //   obscure: true,
                                    // ),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF25D366,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: _enregistrer,
                                        child: const Text(
                                          "Enregistrer",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
    );
  }

  // Widget menu item
  Widget _menuItem(String title, int active) {
    return InkWell(
      onTap: () {
        //
        n1.value = active;
        // if (active == n1.value) {
        //   nouveau.value = active == n1.value;
        // }
      },
      child: Obx(
        () => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color:
                (active == n1.value)
                    ? const Color(0xFF202C33)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight:
                  (active == n1.value) ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Widget champ texte
  Widget _textField(
    String label,
    Function(String?) onSaved, {
    String initial = "",
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initial,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF25D366)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator:
          (val) => val == null || val.isEmpty ? "Champ obligatoire" : null,
      onSaved: onSaved,
    );
  }

  // Widget pour upload du logo
  Widget _logoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Logo",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickLogo,
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade400),
            ),
            child:
                logo == null
                    ? const Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey,
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(logo!, fit: BoxFit.cover),
                    ),
          ),
        ),
      ],
    );
  }
}
