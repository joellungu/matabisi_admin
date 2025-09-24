import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:matabisi_admin/pages/entreprises/entreprise_controller.dart';
import 'package:matabisi_admin/utils/produit.dart';
import 'package:matabisi_admin/utils/requete.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:http/http.dart' as http;

class Item {
  final String keyUnique;
  final DateTime date;

  Item(this.keyUnique, this.date);
}

class ItemsPage extends StatefulWidget {
  Map produitCat;
  ItemsPage(this.produitCat, {super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final List<Item> _items = List.generate(
    10,
    (i) => Item(
      "KEY-${i + 1}-${DateTime.now().millisecondsSinceEpoch}",
      DateTime.now().subtract(Duration(days: i)),
    ),
  );

  DateTime? _selectedDate;
  //
  EntrepriseController entrepriseController = Get.find();

  List<Item> get _filteredItems {
    if (_selectedDate == null) return _items;
    return _items.where((item) {
      return item.date.year == _selectedDate!.year &&
          item.date.month == _selectedDate!.month &&
          item.date.day == _selectedDate!.day;
    }).toList();
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  /////////////////////////////////////////////////////////////
  List<Produit> produits = [];
  int page = 0;
  bool isLoading = false;
  bool hasMore = true;
  /////////////////////////////////////////////////////////////

  void _deleteItem(int idItem) {
    setState(() {
      //
      entrepriseController.getSupprimerProduit(
        idItem,
        widget.produitCat['idEntreprise'],
        widget.produitCat['nom'],
      );
    });
  }

  //
  Future<void> fetchProduits() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse(
        "${Requete.url}/api/produit/all/${widget.produitCat['idEntreprise']}/${widget.produitCat['nom']}?page=$page",
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Produit> newProduits =
          data.map((json) => Produit.fromJson(json)).toList();

      setState(() {
        page++;
        produits.addAll(newProduits);
        isLoading = false;
        if (newProduits.length < 20) hasMore = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    //
    entrepriseController.getAllProduits(
      widget.produitCat['idEntreprise'],
      widget.produitCat['nom'],
    );
    //
    Timer(const Duration(seconds: 1), () {
      //
      //fetchProduits();
    });
    //
    super.initState();
    //
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau des produits"),
        actions: [
          IconButton(icon: const Icon(Icons.filter_alt), onPressed: _pickDate),
          if (_selectedDate != null)
            IconButton(icon: const Icon(Icons.clear), onPressed: _clearFilter),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ProduitPage(
              widget.produitCat['idEntreprise'],
              widget.produitCat['nom'],
            ),
            // child: SingleChildScrollView(
            //   child: Obx(
            //     () => DataTable(
            //       columns: const [
            //         DataColumn(label: Text("QrCode")),
            //         DataColumn(label: Text("Clé Unique")),
            //         DataColumn(label: Text("Utilisé")),
            //         DataColumn(label: Text("Actions")),
            //       ],
            //       rows:
            //           entrepriseController.produits.map((item) {
            //             //Map p = entrepriseController.produits[];
            //             return DataRow(
            //               cells: [
            //                 DataCell(
            //                   InkWell(
            //                     onTap: () {
            //                       //
            //                       Get.dialog(
            //                         Center(
            //                           child: Container(
            //                             height: 300,
            //                             width: 300,
            //                             color: Colors.white,
            //                             child: PrettyQrView.data(
            //                               data: item['codeUnique'],
            //                               decoration: const PrettyQrDecoration(
            //                                 // image: PrettyQrDecorationImage(
            //                                 //   image: AssetImage('images/flutter.png'),
            //                                 // ),
            //                                 quietZone:
            //                                     PrettyQrQuietZone.standart,
            //                               ),
            //                             ),
            //                           ),
            //                         ),
            //                       );
            //                     },
            //                     child: Text(""),
            //                   ),
            //                 ),
            //                 DataCell(Text(item['codeUnique'])),
            //                 DataCell(Text(item['utilise'] ? "Oui" : "Non")),
            //                 DataCell(
            //                   IconButton(
            //                     icon: const Icon(
            //                       Icons.delete,
            //                       color: Colors.red,
            //                     ),
            //                     onPressed: () => _deleteItem(item['id']),
            //                   ),
            //                 ),
            //               ],
            //             );
            //           }).toList(),
            //     ),
            //   ),
            // ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                //
                List<Map<String, dynamic>> items = await pickAndLoadExcelKeys();
                //
                Get.dialog(
                  Center(
                    child: Card(
                      elevation: 1,
                      child: Container(
                        height: 250,
                        width: 300,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Nombre de ticket à générer"),
                            TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                //
                                Get.back();
                                //
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,

                                  builder: (c) {
                                    return SizedBox(
                                      height: Get.height / 1.3,
                                      width: 300,
                                      child: UploadPage(
                                        items,
                                        widget.produitCat['idEntreprise'],
                                        widget.produitCat['nom'],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text("Envoyer"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
                "Ajouter produits",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  //

  Future<List<Map<String, dynamic>>> pickAndLoadExcelKeys() async {
    // Ouvre un explorateur pour choisir le fichier Excel
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['xlsx'],
    // );

    CodeGenerator codeGenerator = CodeGenerator();
    //
    final result = codeGenerator.generateCodes(1000);
    // if (result != null) {
    //   setState(() {
    //     logo = result.files.first.bytes;
    //   });
    // }

    if (result != null) {
      //File file = File(result.files.single.path!);
      //Uint8List? bytes = result.files.first.bytes;
      try {
        // Décoder le fichier Excel
        //final excel = Excel.decodeBytes(bytes!);
        //
        //print("Excel: $excel");

        // Récupérer la première feuille
        // final sheet = excel.tables.keys.first;
        // final table = excel.tables[sheet];

        // // Extraire les valeurs de la première colonne
        // List<String> keys = [];
        //
        List<Map<String, dynamic>> prods = [];
        //

        final updatedAt = DateTime.now().toIso8601String();
        //
        if (result.isNotEmpty) {
          for (String code in result) {
            // skip(1) pour ignorer l’en-tête

            prods.add({
              "nomCategorie": widget.produitCat["nom"],
              "codeUnique": code,
              "valeurPoints": widget.produitCat["point"],
              "utilise": false,
              "idEntreprise": widget.produitCat["idEntreprise"],
              "updatedAt": updatedAt,
            });
          }
        }
        //
        //print("Execl liste: $prods");

        return prods;
      } catch (e) {
        //
        print("Er: $e");
        //
        return [];
      }
    } else {
      // L'utilisateur a annulé la sélection
      return [];
    }
  }
}

class UploadPage extends StatefulWidget {
  //
  List<Map<String, dynamic>> _items;
  //
  int idEntreprise;
  //
  String nomCategorie;
  //
  UploadPage(this._items, this.idEntreprise, this.nomCategorie, {super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  double _progress = 0.0;
  bool _isUploading = false;
  String _statusMessage = "";
  //
  EntrepriseController entrepriseController = Get.find();

  Future<void> _uploadData() async {
    setState(() {
      _isUploading = true;
      _progress = 0.0;
      _statusMessage = "⏳ Envoi en cours...";
    });

    final dio = Dio();

    try {
      final response = await dio.post(
        "${Requete.url}/api/produit/${widget.idEntreprise}", // 👉 adapte l’URL
        data: jsonEncode(widget._items),
        options: Options(headers: {"Content-Type": "application/json"}),
        onSendProgress: (int sent, int total) {
          if (total != -1) {
            setState(() {
              _progress = sent / total;
              _statusMessage =
                  "📤 Téléchargement : ${(100 * _progress).toStringAsFixed(0)} %";
            });
          }
        },
      );

      setState(() {
        if (response.statusCode == 200 || response.statusCode == 201) {
          _statusMessage = "✅ Envoi terminé avec succès !";
          entrepriseController.getAllProduits(
            widget.idEntreprise,
            widget.nomCategorie,
          );
        } else {
          _statusMessage =
              "❌ Erreur serveur : ${response.statusCode} ${response.statusMessage}";
        }
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _statusMessage = "⚠️ Erreur réseau : $e";
      });
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isUploading = false;
        });
      });
    }
  }

  @override
  void initState() {
    //
    super.initState();
    //
    Timer(const Duration(seconds: 1), () {
      _uploadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload item")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isUploading) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 12),
                Text(_statusMessage),
              ] else ...[
                // ElevatedButton.icon(
                //   onPressed: _uploadData,
                //   icon: const Icon(Icons.cloud_upload),
                //   label: const Text("Envoyer la liste"),
                // ),
                const SizedBox(height: 12),
                Text(_statusMessage),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CodeGenerator {
  //
  final int codeLength;
  //
  final Random _random = Random();
  //
  final Set<String> _usedCodes = {};
  //
  CodeGenerator({this.codeLength = 8}); // longueur du code (par défaut 8)

  /// Génère [count] codes uniques
  List<String> generateCodes(int count) {
    List<String> codes = [];
    //
    DateTime now = DateTime.now();
    //
    String year = now.year.toString().substring(
      2,
    ); // prend seulement les 2 derniers chiffres
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');
    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');
    String second = now.second.toString().padLeft(2, '0');

    while (codes.length < count) {
      String code = _generateRandomCode();
      if (_usedCodes.add(code)) {
        codes.add("$year$month$day$hour$minute$second$code");
      }
      // sinon, il est déjà utilisé => on continue
    }

    return codes;
  }

  /// Génère un code aléatoire
  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      codeLength,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }
}

class ProduitPage extends StatefulWidget {
  //
  int idEntreprise;
  String nom;
  //
  ProduitPage(this.idEntreprise, this.nom, {Key? key}) : super(key: key);
  //
  @override
  _ProduitPageState createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  List<Produit> produits = [];
  int page = 0;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> fetchProduits() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse(
        "${Requete.url}/api/produit/all/${widget.idEntreprise}/${widget.nom}?page=$page",
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Produit> newProduits =
          data.map((json) => Produit.fromJson(json)).toList();

      setState(() {
        page++;
        produits.addAll(newProduits);
        isLoading = false;
        if (newProduits.length < 20) hasMore = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProduits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Produits")),
      body: ListView.builder(
        itemCount: produits.length + 1,
        itemBuilder: (context, index) {
          if (index < produits.length) {
            final p = produits[index];
            return ListTile(
              title: Text(p.nomCategorie),
              subtitle: RichText(
                text: TextSpan(
                  text: "${p.codeUnique} \n",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "${p.valeurPoints} Pt",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // TextSpan(
              //   "Code: ${p.codeUnique} - Points: ${p.valeurPoints}",
              // ),
            );
          } else {
            // Loader à la fin
            if (hasMore) {
              // on décale l'appel de fetchProduits après le build courant
              WidgetsBinding.instance.addPostFrameCallback((_) {
                fetchProduits();
              });
              return Center(child: CircularProgressIndicator());
            } else {
              return Center(child: Text("Fin de la liste"));
            }
          }
        },
      ),
    );
  }
}
