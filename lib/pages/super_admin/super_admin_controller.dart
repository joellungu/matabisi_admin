import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:matabisi_admin/pages/entreprises/accueil_entreprise.dart';
import 'package:matabisi_admin/pages/super_admin/super_admin_accueil.dart';
import 'package:matabisi_admin/utils/requete.dart';
import 'package:http/http.dart' as http;

class SuperAdminController extends GetxController {
  //
  Requete requete = Requete();
  //
  var box = GetStorage();
  //
  enregistrerEntreprise(Map ent) async {
    http.Response response = await requete.postE("api/Entreprise", ent);
    //
    if (response.statusCode == 200 || response.statusCode == 201) {
      //
      //final data = jsonDecode(response.body);
      //
      //box.write("user", data);
      //
      print("SUCCES: ${response.statusCode}");
      print("SUCCES: ${response.body}");
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

  login(Map ent) async {
    http.Response response = await requete.postE("auth/login", ent);
    //
    if (response.statusCode == 200 || response.statusCode == 201) {
      //
      Map data = jsonDecode(response.body);
      //
      Get.back();
      //box.write("user", data);
      if (data['token'] != null) {
        //
        box.write("user", data);
        //
        Map<String, dynamic> decoded = JwtDecoder.decode(data['token']);

        if (decoded["groups"].contains("admin")) {
          print("SUCCES: ${response.statusCode}");
          print("SUCCES: ${response.body}");
          //Get.back();
          Get.snackbar("Succès", "Authentification reussi.");
          Get.offAll(AdminDashboard());
        } else {
          //
          print("SUCCES: ${response.statusCode}");
          print("SUCCES: ${response.body}");
          //Get.back();
          Get.snackbar("Succès", "Authentification reussi.");
          Get.offAll(AccueilEntreprise());
        }
      } else {
        print("ERREUR: ${response.statusCode}");
        print("ERREUR: ${response.body}");
        //Get.back();
        Get.snackbar("Erreur", "Un problème est survenu veuillez recommencer.");
      }
      //
    } else {
      //
      print("ERREUR: ${response.statusCode}");
      print("ERREUR: ${response.body}");
      Get.back();
      Get.snackbar("Erreur", "L'enregistrement n'a pas était éffectué.");
    }
  }
}
