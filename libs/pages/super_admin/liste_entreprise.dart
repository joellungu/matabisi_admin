import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:matabisi_admin/pages/super_admin/details_compte.dart';
import 'package:matabisi_admin/pages/super_admin/details_entreprise.dart';
import 'package:matabisi_admin/pages/super_admin/super_admin_controller.dart';
import 'package:matabisi_admin/utils/requete.dart';
import 'package:http/http.dart' as http;

class Entreprise {
  final Uint8List? logo;
  final String nom;
  final String secteur;
  final String email;

  Entreprise({
    this.logo,
    required this.nom,
    required this.secteur,
    required this.email,
  });
}

class EntrepriseListPage extends StatelessWidget {
  EntrepriseListPage({super.key}) {
    //
    superAdminController.getAllEntreprises();
  }
  //
  Requete requete = Requete();
  var box = GetStorage();
  //
  RxString titre = "Infors supplementaire".obs;
  //
  Rx<Widget> vue = Rx(Container());
  //
  Map<String, dynamic> entreprise = {};
  //
  SuperAdminController superAdminController = Get.find();
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar style WhatsApp
          Container(
            width: 360,
            color: const Color(0xFF111B21),
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: superAdminController.entreprises.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> e =
                      superAdminController.entreprises[index];
                  print("Entreprise: $e");
                  return ListTile(
                    onTap: () {
                      //
                      vue.value = EntrepriseUpdateForm(
                        entreprise: e,
                        key: UniqueKey(),
                      );
                      titre.value = "Infors supplementaire";
                      //
                      entreprise = e;
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: NetworkImage(
                        "${Requete.url}/api/Entreprise/logo/${e['id']}",
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
                      "${e['secteur']} • ${e['email']}",
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
                          superAdminController..supprimerProduit(e['id']);
                        } else {
                          //
                          superAdminController..changerStatusProduit(
                            e['id'],
                            e['status'] == 1 ? 0 : 1,
                          );
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(value: 1, child: Text("Supprimer")),
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
                  );
                },
              );
            }),
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
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(
                          titre.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuButton(
                        onSelected: (s) {
                          //
                          if (s == 1) {
                            titre.value = "Infors supplementaire";
                            //
                            vue.value = EntrepriseUpdateForm(
                              entreprise: entreprise,
                              key: UniqueKey(),
                            );
                          }
                          if (s == 2) {
                            titre.value = "Compte";
                            //
                            //vue.value = DetailsCompte(entreprise: entreprise);
                          }
                          if (s == 3) {
                            titre.value = "Statistique";
                            //
                            vue.value = Container();
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              value: 1,
                              child: Text("Infors supplementaire"),
                            ),
                            PopupMenuItem(value: 2, child: Text("Compte")),
                            PopupMenuItem(value: 3, child: Text("Statistique")),
                          ];
                        },
                      ),
                    ],
                  ),
                ),

                // Liste
                Expanded(child: Obx(() => vue.value)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget menu item
  Widget _menuItem(String title, bool active) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF202C33) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
