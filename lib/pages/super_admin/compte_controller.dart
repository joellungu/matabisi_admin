import 'dart:convert';

import 'package:get/get.dart';
import 'package:matabisi_admin/utils/requete.dart';
import 'package:http/http.dart' as http;

class CompteController extends GetxController with StateMixin<Map> {
  //
  Requete requete = Requete();
  //

  getCompte(int idEntreprise) async {
    //
    change({}, status: RxStatus.loading());
    //
    http.Response response = await requete.getE(
      "api/Compte/entreprise/$idEntreprise",
    );
    //
    if (response.statusCode == 200 || response.statusCode == 201) {
      //
      change(jsonDecode(response.body), status: RxStatus.success());
    } else {
      //
      change(jsonDecode(response.body), status: RxStatus.empty());
    }
  }

  //
  majCompte(int idEntreprise, String data) async {
    //
    //change({}, status: RxStatus.loading());
    //
    http.Response response = await requete.putEs(
      "api/Compte/entreprise/$idEntreprise",
      int.parse(data),
    );
    //
    if (response.statusCode == 200 || response.statusCode == 201) {
      //
      getCompte(idEntreprise);
    } else {
      //
      Get.snackbar(
        "Erreur",
        "Nous n'avons pas pu mettre à jour le compte de l'entreprise. ${response.statusCode}",
      );
    }
  }
}
