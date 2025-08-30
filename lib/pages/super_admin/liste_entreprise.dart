import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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
  EntrepriseListPage({super.key});
  //
  Requete requete = Requete();
  var box = GetStorage();
  //

  // ⚠️ Exemple de données factices (en vrai tu vas les charger depuis ton API)
  // final List<Entreprise> entreprises = [
  //   Entreprise(
  //     nom: "Cosmo Beauty",
  //     secteur: "Cosmétique",
  //     email: "contact@cosmobeauty.com",
  //   ),
  //   Entreprise(nom: "Africell", secteur: "Télécom", email: "info@africell.cd"),
  //   Entreprise(
  //     nom: "Boulangerie du Coin",
  //     secteur: "Alimentation",
  //     email: "boulangerie@mail.com",
  //   ),
  // ];

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
            child: FutureBuilder(
              future: getAllEntreprises(),
              builder: (c, t) {
                if (t.hasData) {
                  List entreprises = t.data as List;
                  //
                  return ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: entreprises.length,
                    itemBuilder: (context, index) {
                      Map e = entreprises[index];
                      return ListTile(
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
                        // trailing: IconButton(
                        //   icon: const Icon(Icons.more_vert),
                        //   onPressed: () {
                        //     // menu d’actions : voir / modifier / supprimer
                        //   },
                        // ),
                      );
                    },
                  );
                } else if (t.hasError) {
                  return Container();
                }
                return Center();
              },
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
                    "Infors supp",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                // Liste
                Expanded(child: Container()),
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

  Future<List> getAllEntreprises() async {
    //
    Map user = box.read("user") ?? {};
    //
    http.Response response = await requete.getEe(
      "api/Entreprise/all",
      user['token'],
    );
    //
    if (response.statusCode == 200 || response.statusCode == 201) {
      //
      print("SUCCES: ${response.statusCode}");
      print("SUCCES: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("ERREUR: ${response.statusCode}");
      print("ERREUR: ${response.body}");
      return [];
    }
  }
}
