import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matabisi_admin/pages/super_admin/compte_controller.dart';

class DetailsCompte extends GetView<CompteController> {
  //
  late TextEditingController soldePoints;
  //
  Map entreprise;

  DetailsCompte(this.entreprise) {
    controller.getCompte(entreprise["id"]);

    //soldePoints = TextEditingController(text: entreprise["soldePoints"] ?? "");
    // si le backend renvoie déjà un logo en base64, tu peux le décoder ici
    // logoBytes = base64Decode(widget.entreprise["logo"]);
  }

  void _mettreAJour() {
    // final updated = {
    //   "idEntreprise": entreprise["id"],
    //   "soldePoints": soldePoints.text,
    // };
    //
    controller.majCompte(entreprise["id"], soldePoints.text);
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
        child: controller.obx(
          (state) {
            //
            Map compte = state as Map;
            //
            soldePoints = TextEditingController(
              text: "${compte["soldePoints"]}" ?? "",
            );
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${compte["soldePoints"]}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: soldePoints,
                    decoration: const InputDecoration(
                      labelText: "solde Points",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
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
            );
          },
          onEmpty: Container(),
          onLoading: Center(
            child: Container(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
