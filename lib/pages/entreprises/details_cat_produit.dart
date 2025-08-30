import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:matabisi_admin/pages/entreprises/entreprise_controller.dart';
import 'package:matabisi_admin/pages/super_admin/liste_entreprise.dart';
import 'package:matabisi_admin/pages/super_admin/super_admin_controller.dart';

import '../../utils/requete.dart';

class DetailsCatProduit extends StatefulWidget {
  //
  Map? produitCat;
  //
  DetailsCatProduit(this.produitCat, {super.key});

  @override
  State<DetailsCatProduit> createState() => _EntrepriseFormPageState();
}

class _EntrepriseFormPageState extends State<DetailsCatProduit> {
  final _formKey = GlobalKey<FormState>();

  String nom = "";
  String secteur = "";
  String email = "";
  String routeCode = "";
  String point = "";
  Uint8List? logo;
  RxBool nouveau = false.obs;
  RxInt n1 = 1.obs;
  //

  TextEditingController _nomController = TextEditingController();
  TextEditingController _quantiteController = TextEditingController();
  TextEditingController _statusController = TextEditingController();
  TextEditingController _pointController = TextEditingController();
  TextEditingController _routeCodeController = TextEditingController();
  TextEditingController _idEntrepriseController = TextEditingController();
  bool _utilise = false;
  //
  EntrepriseController entrepriseController = Get.find();
  //
  var box = GetStorage();
  Map entreprise = {};
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
        "routeCode": routeCode,
        "quantite": 0,
        "status": 1,
        "point": point,
        "idEntreprise": entreprise['id'],
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
      entrepriseController.enregistrerEntreprise(e);

      setState(() {
        nom = "";
        secteur = "";
        email = "";
        routeCode = "";
        logo = null;
      });
    }
  }

  @override
  void initState() {
    //
    entreprise = box.read("user") ?? {};
    //
    entrepriseController.getAllEntreprises();
    //
    super.initState();
    /**
     * final TextEditingController _nomController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();
  final TextEditingController _routeCodeController = TextEditingController();
  final TextEditingController _idEntrepriseController = TextEditingController();
     */
    _nomController = TextEditingController(
      text: widget.produitCat!["nom"] ?? "",
    );
    _quantiteController = TextEditingController(
      text: widget.produitCat!["quantite"]?.toString() ?? "",
    );
    _statusController = TextEditingController(
      text: widget.produitCat!["status"]?.toString() ?? "0",
    );
    _routeCodeController = TextEditingController(
      text: widget.produitCat!["routeCode"]?.toString() ?? "",
    );
    _pointController = TextEditingController(
      text: widget.produitCat!["point"]?.toString() ?? "",
    );
    _utilise = widget.produitCat!["utilise"] ?? false;
    //
  }

  void _updateProduit() {
    if (_formKey.currentState!.validate()) {
      final updatedProduit = {
        // "nomCategorie": _nomCategorieController.text,
        // "codeUnique": _codeUniqueController.text,
        // "valeurPoints": int.tryParse(_valeurPointsController.text) ?? 0,
        "utilise": _utilise,
        "idEntreprise": int.tryParse(_idEntrepriseController.text),
      };

      // TODO : Envoyer updatedProduit à ton backend (via http PUT/POST)
      debugPrint("Produit mis à jour: $updatedProduit");
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _quantiteController.dispose();
    _statusController.dispose();
    _routeCodeController.dispose();
    _statusController.dispose();
    _pointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          //
          Container(
            width: 260,
            color: const Color(0xFF111B21),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          "${Requete.url}/produit-categories/logo/${widget.produitCat!['id']}",
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 20),
                TextFormField(
                  controller: _nomController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Nom",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantiteController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Quantité",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _statusController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pointController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Point",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _routeCodeController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Route Code",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _updateProduit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    maximumSize: Size(250, 40),
                    minimumSize: Size(250, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Mettre à jour",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _updateProduit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 168, 10, 10),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    maximumSize: Size(250, 40),
                    minimumSize: Size(250, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Supprimer",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Contenu principal
          Expanded(
            child: Column(
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
                      bottom: BorderSide(color: Colors.black12, width: 1),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Liste de produits",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                // Formulaire
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Container(),
                  ),
                ),
              ],
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
