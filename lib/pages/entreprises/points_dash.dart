import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:matabisi_admin/utils/paiement_controller.dart';
import 'package:matabisi_admin/utils/requete.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class PointsDashboard extends StatefulWidget {
  const PointsDashboard({super.key});

  @override
  State<PointsDashboard> createState() => _PointsDashboardState();
}

class _PointsDashboardState extends State<PointsDashboard> {
  double balance = 2450.00;
  int points = 245000;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController numero = TextEditingController();
  //
  PaiementController paiementController = Get.find();
  //
  var box = GetStorage();

  String getReference() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  void _buyPoints() async {
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
    Map user = box.read("user");
    //
    String ref = getReference();
    //
    print('La ref : $ref');
    //
    Map e = {
      "idEntreprise": user['id'],
      "phone": "243${numero.text}",
      "valider": 0,
      "reference": ref,
      "amount": _amountController.text, // widget.prix,
      "currency": "USD",
    };
    final amount = double.tryParse(_amountController.text) ?? 0;
    //
    http.Response reponse = await paiementController.paiement(e);
    //
    if (reponse.statusCode == 200 ||
        reponse.statusCode == 201 ||
        reponse.statusCode == 202 ||
        reponse.statusCode == 203 ||
        reponse.statusCode == 204) {
      //
      Get.back();
      print("Rep : 1 = ${reponse.statusCode}");
      print("Rep : 1 = ${reponse.body}");
      //
      if (amount > 0) {
        setState(() {
          balance += amount;
          points += (amount * 100).toInt();
        });
        _amountController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Achat réussi: \$$amount'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } else {
      //
      Get.back();
      print("Rep : 2 = ${reponse.statusCode}");
      print("Rep : 2 = ${reponse.body}");
      //
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Achat non éffectué: ${reponse.statusCode}'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    Map user = box.read("user");
    //
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Container(
          width: 500,
          height: double.maxFinite,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOLDE ENTREPRISE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Tableau de bord financier',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Carte principale
              CreditCardWidget(idEntreprise: user['id']),

              const SizedBox(height: 32),

              // Formulaire d'achat
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acheter des points',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        hintText: 'Montant en dollars',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: numero,
                      decoration: InputDecoration(
                        hintText: 'Téléphone ex: 815381693',
                        icon: Text("+243 "),
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _buyPoints,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text(
                          'Convertir en points',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '100 points = 1.00\$ • 10 points = 0.10\$',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class CreditCardWidget extends StatelessWidget {
  final int idEntreprise;

  const CreditCardWidget({super.key, required this.idEntreprise});

  Future<Map<String, dynamic>> fetchCredit(int idEntreprise) async {
    final response = await http.get(
      Uri.parse("${Requete.url}/credits/$idEntreprise"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors du chargement du crédit");
    }
  }

  Widget _buildPointItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchCredit(idEntreprise),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Erreur: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text("Aucune donnée"));
        }

        final data = snapshot.data!;
        final double solde = data["solde"] ?? 0.0;
        final int points = (solde * 100).toInt(); // Exemple: 1$ = 100 pts

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Colors.blue.shade700,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Solde disponible',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${solde.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildPointItem('Points accumulés', points.toString()),
                  const SizedBox(width: 20),
                  _buildPointItem('Taux', '1\$ = 100 pts'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
