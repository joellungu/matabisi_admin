import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:matabisi_admin/utils/requete.dart';

class FraisRetrait extends StatefulWidget {
  Map entreprise; // Id de l'entreprise à modifier
  FraisRetrait({super.key, required this.entreprise});

  @override
  State<FraisRetrait> createState() => _FraisRetrait();
}

class _FraisRetrait extends State<FraisRetrait> {
  // Champs de formulaire

  int status = 1;
  TextEditingController usdCtrl = TextEditingController();

  void saveEntreprise() async {
    final entreprise = {
      "nom": widget.entreprise['nom'],
      "secteur": widget.entreprise['secteur'],
      "email": widget.entreprise['email'],
      "motDePasse": widget.entreprise['motDePasse'],
      //"status": 1,
      "fraisRetraitUSD": int.tryParse(usdCtrl.text) ?? 1,
      "status": widget.entreprise['status'],
    };

    // TODO: Envoyer au backend Quarkus via API REST
    //debugPrint("Entreprise sauvegardée: $entreprise");
    final url = Uri.parse(
      "${Requete.url}/api/Entreprise/${widget.entreprise['id']}",
    );

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(entreprise),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entreprise mise à jour avec succès ✅")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: ${response.body}")));
    }
  }

  @override
  void initState() {
    //
    usdCtrl.text = "${widget.entreprise['fraisRetraitUSD']}" ?? "1";
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Mise à jour frais de retrait",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    """
Information importante sur le système de points

Lorsque vous saisissez un montant dans ce formulaire, il ne s’agit pas directement d’argent, mais du nombre de points requis pour effectuer une conversion en argent réel.

Le fonctionnement est simple :

Chaque utilisateur accumule des points dans son compte.

Pour pouvoir effectuer un transfert d’argent via les services de mobile money locaux (Airtel Money, Orange Money, Mpesa, Afrimoney, etc.), l’utilisateur doit atteindre le nombre de points que vous avez défini ici.

La conversion se fait ensuite automatiquement selon le barème suivant :

🔹 10 points = 0,1 USD (dollar américain)

Cela signifie que 100 points équivalent à 1 dollar, 1 000 points équivalent à 10 dollars, et ainsi de suite.

✅ En pratique :

Si vous fixez par exemple 500 points, cela veut dire qu’un utilisateur devra avoir au moins 500 points pour demander un retrait équivalent à 5 USD.

Les points accumulés sont donc une sorte de crédit virtuel qui peut être converti en argent liquide grâce au mobile money.

⚠️ Attention : Le paramètre que vous configurez ici détermine la règle de conversion pour tous vos utilisateurs. Il est donc conseillé de bien réfléchir au seuil minimum avant de le valider, afin de garantir un équilibre entre la valeur des points et la facilité de retrait.
""",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Frais Retrait USD & CDF
                  Container(
                    height: 50,
                    width: 200,
                    child: TextField(
                      controller: usdCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: "Frais Retrait USD",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton Sauvegarder
                  ElevatedButton.icon(
                    onPressed: saveEntreprise,
                    icon: const Icon(Icons.save),
                    label: const Text("Sauvegarder"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
