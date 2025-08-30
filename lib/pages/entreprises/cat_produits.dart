import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matabisi_admin/pages/entreprises/details_cat_produit.dart';
import 'package:matabisi_admin/pages/entreprises/entreprise_controller.dart';
import 'package:matabisi_admin/pages/entreprises/nouveau_cat_produit.dart';
import 'package:matabisi_admin/pages/super_admin/liste_entreprise.dart';
import 'package:matabisi_admin/pages/super_admin/super_admin_controller.dart';
import 'package:matabisi_admin/utils/requete.dart';

class CatProduits extends StatefulWidget {
  const CatProduits({super.key});

  @override
  State<CatProduits> createState() => _EntrepriseFormPageState();
}

class _EntrepriseFormPageState extends State<CatProduits> {
  final _formKey = GlobalKey<FormState>();

  String nom = "";
  String secteur = "";
  String email = "";
  String motDePasse = "";
  Uint8List? logo;
  RxBool nouveau = false.obs;
  RxInt n1 = 1.obs;
  //
  EntrepriseController entrepriseController = Get.find();
  //
  Rx<Widget> vue = Rx(Container());
  //
  final List<String> entreprises = [
    "Supermarché",
    "Boulangerie",
    "Pharmacie",
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
  RxInt index = RxInt(-1);

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
      //superAdminController.enregistrerEntreprise(e);

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
  void initState() {
    //
    entrepriseController.getAllEntreprises();
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar style WhatsApp
          Container(
            width: 280,
            color: const Color(0xFF111B21),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Produits",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _menuItem("Nouveau produit", 1),
                const SizedBox(height: 10),
                Expanded(
                  flex: 9,
                  child: Obx(
                    () => ListView(
                      children: List.generate(
                        entrepriseController.produitCategories.length,
                        (pc) {
                          Map e = entrepriseController.produitCategories[pc];
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (pc == index.value)
                                      ? const Color(0xFF202C33)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              onTap: () {
                                //
                                n1.value = 2;
                                index.value = pc;
                                vue.value = Container();
                                //
                                vue.value = DetailsCatProduit(
                                  e,
                                  key: UniqueKey(),
                                );
                              },
                              contentPadding: EdgeInsets.all(0),
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: NetworkImage(
                                  "${Requete.url}/produit-categories/logo/${e['id']}",
                                ),
                              ),
                              title: Text(
                                e['nom'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                "${e['point']} Pts  ${e['status'] == 1 ? 'Activé' : 'desactivé'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.green,
                                ),
                              ),
                              trailing: PopupMenuButton(
                                onSelected: (s) {
                                  //
                                  if (s == 1) {
                                    //
                                    entrepriseController.supprimerProduit(
                                      e['id'],
                                    );
                                  } else {
                                    //
                                    entrepriseController.changerStatusProduit(
                                      e['id'],
                                      e['status'] == 1 ? 0 : 1,
                                    );
                                  }
                                },
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      value: 1,
                                      child: Text("Supprimer"),
                                    ),
                                    PopupMenuItem(
                                      value: 2,
                                      child:
                                          e['status'] == 1
                                              ? Text("Suspendre")
                                              : Text("Activer"),
                                    ),
                                  ];
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenu principal
          Expanded(
            child: Obx(
              () => n1.value == 2 ? Obx(() => vue.value) : NouveauCatProduit(),
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
