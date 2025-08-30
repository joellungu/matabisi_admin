import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:matabisi_admin/pages/entreprises/accueil_entreprise.dart';
import 'package:matabisi_admin/pages/super_admin/super_admin_accueil.dart';
import 'package:matabisi_admin/utils/requete.dart';
import 'package:http/http.dart' as http;

class EntrepriseController extends GetxController with StateMixin<List> {
  //
  Requete requete = Requete();
  //
  RxList produitCategories = [].obs;
  //
  var box = GetStorage();
  //
  enregistrerEntreprise(Map ent) async {
    http.Response response = await requete.postE("produit-categories", ent);
    //
    if (response.statusCode == 200 || response.statusCode == 201) {
      //
      //final data = jsonDecode(response.body);
      //
      //box.write("user", data);
      //
      print("SUCCES: ${response.statusCode}");
      print("SUCCES: ${response.body}");
      getAllEntreprises();
      Get.back();
      Get.snackbar("Succès", "L'enregistrement a bien été éffectué.");
    } else {
      //
      print("ERREUR: ${response.statusCode}");
      print("ERREUR: ${response.body}");
      Get.back();
      Get.snackbar("Erreur", "L'enregistrement n'a pas était éffectué.");
    }
  }

  //
  getAllEntreprises() async {
    //
    Map user = box.read("user") ?? {};
    //
    http.Response response = await requete.getE(
      "produit-categories/all/${user['id']}",
      //user['token'],
    );
    //
    if (response.statusCode == 200 || response.statusCode == 201) {
      //
      print("SUCCES: ${response.statusCode}");
      print("SUCCES: ${response.body}");
      produitCategories.value = jsonDecode(response.body);
    } else {
      print("ERREUR: ${response.statusCode}");
      print("ERREUR: ${response.body}");
      produitCategories.value = [];
    }
  }
}
