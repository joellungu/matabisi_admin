import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matabisi_admin/pages/entreprises/entreprise_controller.dart';
import 'package:matabisi_admin/pages/login.dart';
import 'package:matabisi_admin/pages/super_admin/nouvelle_entreprise2.dart';
import 'package:matabisi_admin/pages/super_admin/super_admin_accueil.dart';
import 'package:matabisi_admin/pages/super_admin/super_admin_controller.dart';

void mains() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  //
  Get.put(SuperAdminController());
  //
  Get.put(EntrepriseController());
  //
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Matabisi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      home:
          //EntrepriseFormPage(),
          //EntrepriseRegistrationPage(),
          //AdminDashboard(),
          LoginScreen(),
    );
  }
}
