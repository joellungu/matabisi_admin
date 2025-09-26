import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:matabisi_admin/utils/requete.dart';

class PublicitePage extends StatefulWidget {
  const PublicitePage({super.key});

  @override
  State<PublicitePage> createState() => _PubliciteDashboardState();
}

class _PubliciteDashboardState extends State<PublicitePage> {
  final String apiUrl = "${Requete.url}/publicites";
  List<dynamic> publicites = [];

  final titreController = TextEditingController();
  final descController = TextEditingController();
  String? imageBase64;
  Uint8List bytes = Uint8List.fromList([]);
  int? editingId;
  late html.File file;

  bool showForm = false;

  @override
  void initState() {
    super.initState();
    fetchPublicites();
  }

  Future<void> fetchPublicites() async {
    final res = await http.get(Uri.parse(apiUrl));
    if (res.statusCode == 200) {
      setState(() {
        publicites = jsonDecode(res.body);
      });
    }
  }

  Future<void> pickImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      file = uploadInput.files!.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        final encoded = reader.result as String;
        setState(() {
          imageBase64 = encoded.split(",").last;
          bytes = base64Decode(imageBase64!);
        });
      });
    });
  }

  Future<void> savePublicite() async {
    final pub = {
      "titre": titreController.text,
      "description": descController.text,
      "actif": true,
      "image": bytes, //imageBase64 != null ? base64Decode(imageBase64!) : null,
    };

    if (editingId != null) {
      await http.put(
        Uri.parse("$apiUrl/$editingId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(pub),
      );
    } else {
      await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(pub),
      );
    }

    clearForm();
    fetchPublicites();
  }

  Future<void> deletePublicite(int id) async {
    await http.delete(Uri.parse("$apiUrl/$id"));
    fetchPublicites();
  }

  void clearForm() {
    titreController.clear();
    descController.clear();
    imageBase64 = null;
    editingId = null;
    setState(() {
      showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text("🎯 Gestion des Publicités"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => setState(() => showForm = true),
            icon: const Icon(Icons.add),
            label: const Text("Nouvelle publicité"),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: Colors.white,
            child: Column(
              children: const [
                DrawerHeader(
                  child: Text(
                    "📊 Dashboard",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.campaign),
                  title: Text("Publicités"),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Paramètres"),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 4 / 3,
                ),
                itemCount: publicites.length,
                itemBuilder: (context, index) {
                  final pub = publicites[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child:
                              pub["id"] != null
                                  ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      "$apiUrl/${pub["id"]}/image",
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Container(color: Colors.grey[300]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pub["titre"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pub["description"] ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        editingId = pub["id"];
                                        titreController.text = pub["titre"];
                                        descController.text =
                                            pub["description"] ?? "";
                                        showForm = true;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => deletePublicite(pub["id"]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Drawer Form
          if (showForm)
            Container(
              width: 350,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    editingId != null
                        ? "Modifier Publicité"
                        : "Nouvelle Publicité",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titreController,
                    decoration: const InputDecoration(
                      labelText: "Titre",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  bytes != null
                      ? Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: MemoryImage(bytes)),
                        ),
                      )
                      : Container(),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.upload),
                    label: const Text("Choisir image"),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: savePublicite,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            editingId != null ? "Mettre à jour" : "Enregistrer",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: clearForm,
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
