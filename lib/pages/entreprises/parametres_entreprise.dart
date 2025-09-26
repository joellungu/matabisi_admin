import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:matabisi_admin/pages/entreprises/frais_retrait.dart';
import 'package:matabisi_admin/pages/entreprises/motdepasse_oublie.dart';
import 'package:matabisi_admin/pages/entreprises/points_dash.dart';
import 'package:matabisi_admin/pages/entreprises/transaction_entreprise.dart';
import 'package:matabisi_admin/pages/entreprises/update_entreprise_page.dart';
import 'package:matabisi_admin/utils/requete.dart';

class ParametresEntreprise extends StatefulWidget {
  const ParametresEntreprise({super.key});

  @override
  State<ParametresEntreprise> createState() => _ParametresEntreprise();
}

class _ParametresEntreprise extends State<ParametresEntreprise> {
  String? _type;
  String? _dateDebut;
  String? _dateFin;
  final TextEditingController _phoneCtrl = TextEditingController();

  List<dynamic> transactions = [];
  bool loading = false;
  int point = 0;
  int totalPoints = 0;
  int montant = 0;
  double valeurParPoint = 0.01;
  RxInt index = 0.obs;
  //
  Rx<Widget> vue = Rx(Container());
  //
  var box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          /// Partie gauche : filtres
          Container(
            width: 360,
            color: const Color(0xFF111B21),
            padding: const EdgeInsets.all(16),
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Parametres",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  option(
                    1,
                    {"nom": "Logo", "description": "Changer de logo"},
                    () {
                      Map entreprise = box.read("user") ?? {};
                      //
                      index.value = 1;
                      vue.value = UpdateEntreprisePage(entreprise: entreprise);
                      //
                      //vue.value = DetailsCatProduit(e, key: UniqueKey());
                    },
                  ),
                  const SizedBox(height: 5),
                  option(
                    2,
                    {
                      "nom": "Frais de retrait",
                      "description": "Montant minimal pour le retrait",
                    },
                    () {
                      Map entreprise = box.read("user") ?? {};
                      //
                      index.value = 2;
                      vue.value = FraisRetrait(entreprise: entreprise);
                      //
                      //vue.value = DetailsCatProduit(e, key: UniqueKey());
                    },
                  ),
                  const SizedBox(height: 5),
                  option(
                    3,
                    {
                      "nom": "Achat points",
                      "description": "Acheter des points pour vos produits",
                    },
                    () {
                      //
                      index.value = 3;
                      vue.value = PointsDashboard();
                      //
                      //vue.value = DetailsCatProduit(e, key: UniqueKey());
                    },
                  ),
                  const SizedBox(height: 5),
                  option(
                    4,
                    {
                      "nom": "Mot de passe",
                      "description": "Changement du mot de passe",
                    },
                    () {
                      //
                      index.value = 4;
                      vue.value = PasswordChangeScreen();
                      //
                      //vue.value = DetailsCatProduit(e, key: UniqueKey());
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Partie droite : résultats
          Expanded(flex: 9, child: Obx(() => vue.value)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Icon(icon, color: const Color(0xFF128C7E)),
                ],
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF128C7E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget option(int pc, Map e, VoidCallback onTap) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color:
              (pc == index.value)
                  ? const Color(0xFF202C33)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.all(0),
          // leading: CircleAvatar(
          //   backgroundColor: Colors.grey.shade300,
          //   // backgroundImage: NetworkImage(
          //   //   "${Requete.url}/produit-categories/logo/${e['id']}",
          //   // ),
          // ),
          title: Text(
            e['nom'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            "${e['description']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: Colors.green,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          // trailing: PopupMenuButton(
          //   onSelected: (s) {
          //     //
          //
          //   },
          //   itemBuilder: (context) {
          //     return [
          //       PopupMenuItem(value: 1, child: Text("Supprimer")),
          //       PopupMenuItem(
          //         value: 2,
          //         child: e['status'] == 1 ? Text("Suspendre") : Text("Activer"),
          //       ),
          //     ];
          //   },
          // ),
        ),
      ),
    );
  }
}
