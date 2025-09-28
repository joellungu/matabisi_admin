import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:matabisi_admin/utils/cluster_map.dart';
import 'package:matabisi_admin/utils/data_converter.dart';
import 'package:matabisi_admin/utils/point_data.dart';
import 'package:matabisi_admin/utils/requete.dart';
//
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TransactionEntreprise extends StatefulWidget {
  const TransactionEntreprise({super.key});

  @override
  State<TransactionEntreprise> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionEntreprise> {
  String? _type;
  String? _dateDebut;
  String? _dateFin;
  String? _dateDebut2;
  String? _dateFin2;
  final TextEditingController _phoneCtrl = TextEditingController();
  List le = [];

  List<dynamic> transactions = [];
  bool loading = false;
  int point = 0;
  int totalPoints = 0;
  int montant = 0;
  double valeurParPoint = 0.01;
  //
  final Map<String, LatLngBounds> _provinceBounds = {
    'Kinshasa': LatLngBounds(LatLng(-4.9, 14.9), LatLng(-3.6, 15.7)),
    'Kongo Central': LatLngBounds(LatLng(-6.5, 12.0), LatLng(-3.0, 15.2)),
    'Kwango': LatLngBounds(LatLng(-9.5, 15.0), LatLng(-5.0, 19.5)),
    'Kwilu': LatLngBounds(LatLng(-8.0, 16.5), LatLng(-4.0, 20.8)),
    'Mai-Ndombe': LatLngBounds(LatLng(-6.0, 15.5), LatLng(-1.5, 20.5)),
    'Kasaï': LatLngBounds(LatLng(-9.0, 19.5), LatLng(-4.0, 24.0)),
    'Kasaï-Central': LatLngBounds(LatLng(-7.5, 21.0), LatLng(-4.2, 24.0)),
    'Kasaï-Oriental': LatLngBounds(LatLng(-8.0, 22.5), LatLng(-5.5, 25.5)),
    'Lomami': LatLngBounds(LatLng(-9.0, 22.5), LatLng(-5.5, 26.0)),
    'Sankuru': LatLngBounds(LatLng(-6.0, 21.5), LatLng(-2.0, 25.0)),
    'Lualaba': LatLngBounds(LatLng(-12.0, 23.5), LatLng(-9.0, 27.5)),
    'Haut-Katanga': LatLngBounds(LatLng(-13.0, 24.5), LatLng(-9.0, 29.8)),
    'Haut-Lomami': LatLngBounds(LatLng(-11.0, 23.0), LatLng(-8.0, 26.5)),
    'Tanganyika': LatLngBounds(LatLng(-10.0, 25.5), LatLng(-5.5, 29.8)),
    'Maniema': LatLngBounds(LatLng(-6.0, 24.5), LatLng(-2.0, 28.8)),
    'Ituri': LatLngBounds(LatLng(0.5, 27.0), LatLng(3.5, 31.0)),
    'Nord-Kivu': LatLngBounds(LatLng(-2.0, 28.5), LatLng(0.7, 30.8)),
    'Sud-Kivu': LatLngBounds(LatLng(-5.0, 28.0), LatLng(-2.0, 29.7)),
    'Tshopo': LatLngBounds(LatLng(-3.0, 22.5), LatLng(1.0, 27.0)),
    'Bas-Uele': LatLngBounds(LatLng(1.5, 22.5), LatLng(4.8, 26.5)),
    'Haut-Uele': LatLngBounds(LatLng(1.8, 26.5), LatLng(4.2, 31.0)),
    'Équateur': LatLngBounds(LatLng(-1.0, 15.5), LatLng(3.0, 21.0)),
    'Mongala': LatLngBounds(LatLng(1.5, 17.5), LatLng(3.0, 21.5)),
    'Nord-Ubangi': LatLngBounds(LatLng(3.0, 16.5), LatLng(5.2, 20.2)),
    'Sud-Ubangi': LatLngBounds(LatLng(2.8, 15.8), LatLng(4.8, 18.8)),
    'Tshuapa': LatLngBounds(LatLng(-1.5, 18.5), LatLng(2.5, 23.0)),
  };
  //
  var box = GetStorage();

  final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  Future<void> pickDateTime({required bool isStart}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    DateTime fullDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    String longDate = DateFormat(
      'EEEE dd MMMM yyyy',
      'fr_FR',
    ).format(fullDateTime);

    String formatted = formatter.format(fullDateTime);

    setState(() {
      if (isStart) {
        _dateDebut = formatted;
        _dateDebut2 = longDate;
      } else {
        _dateFin = formatted;
        _dateFin2 = longDate;
      }
    });
  }

  Future<void> fetchTransactions() async {
    setState(() => loading = true);
    Map entreprise = box.read("user");

    try {
      final dio = Dio();
      final response = await dio.get(
        "${Requete.url}/api/transactions/entreprise/filtre",
        queryParameters: {
          if (entreprise['id'] != null) "idEntreprise": entreprise['id'],
          if (_type != null) "type": _type,
          if (_dateDebut != null) "dateDebut": _dateDebut,
          if (_dateFin != null) "dateFin": _dateFin,
          if (_phoneCtrl.text.isNotEmpty) "clientPhone": _phoneCtrl.text,
        },
      );
      print("Truc: ${response.data}");
      setState(() {
        List c = response.data;
        le = c;
        //totalPoints = c.reduce((a, b) => a['valeur'] + b['valeur']);
        c.forEach((x) {
          //
          point = point + int.parse('${x['valeur']}');
        });
        transactions = response.data;
      });
    } catch (e) {
      debugPrint("Erreur: $e");
    } finally {
      setState(() => loading = false);
    }
  }

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
                    "Filtres",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Type"),
                    style: TextStyle(color: Colors.green),
                    items: const [
                      DropdownMenuItem(value: "GAIN", child: Text("GAIN")),
                      DropdownMenuItem(
                        value: "DEPENSE",
                        child: Text("DEPENSE"),
                      ),
                    ],
                    value: _type,
                    onChanged: (val) => setState(() => _type = val),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Date Début: ",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        _dateDebut2 ?? '-',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => pickDateTime(isStart: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // couleur de fond
                      foregroundColor: Colors.white, // couleur du texte
                      maximumSize: Size(250, 45),
                      minimumSize: Size(250, 45),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // bouton arrondi
                      ),
                      elevation: 6,
                    ),
                    child: const Text("Choisir date début"),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Date Fin: ", style: TextStyle(color: Colors.white)),
                      Text(
                        _dateFin2 ?? '-',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => pickDateTime(isStart: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // couleur de fond
                      foregroundColor: Colors.white, // couleur du texte
                      maximumSize: Size(250, 45),
                      minimumSize: Size(250, 45),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // bouton arrondi
                      ),
                      elevation: 6,
                    ),
                    child: const Text("Choisir date fin"),
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    style: TextStyle(color: Colors.green),
                    decoration: const InputDecoration(labelText: "Téléphone"),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: fetchTransactions,
                    icon: const Icon(Icons.search),
                    label: const Text("Rechercher"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // couleur de fond
                      foregroundColor: Colors.white, // couleur du texte
                      maximumSize: Size(250, 45),
                      minimumSize: Size(250, 45),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // bouton arrondi
                      ),
                      elevation: 6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      //
                      //Get.to(MapZonesPage());
                      //
                      _showProvinceList();
                      //
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text("Carte map"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // couleur de fond
                      foregroundColor: Colors.white, // couleur du texte
                      maximumSize: Size(250, 45),
                      minimumSize: Size(250, 45),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // bouton arrondi
                      ),
                      elevation: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Partie droite : résultats
          Expanded(
            child:
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : transactions.isEmpty
                    ? const Center(child: Text("Aucune transaction trouvée"))
                    : Column(
                      children: [
                        Container(
                          height: 130,
                          child: Row(
                            children: [
                              _buildStatCard(
                                'Achats aujourd\'hui',
                                '${transactions.length}',
                                Icons.shopping_cart,
                              ),
                              SizedBox(width: 16),
                              _buildStatCard(
                                'Points distribués',
                                '$point',
                                Icons.star,
                              ),
                              SizedBox(width: 16),
                              _buildStatCard(
                                'Somme total',
                                '${(point * valeurParPoint).toStringAsFixed(2)}\$',
                                Icons.monetization_on,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: transactions.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              return ListTile(
                                leading: Icon(
                                  tx["type"] == "GAIN"
                                      ? Icons.add_circle_outline
                                      : Icons.remove_circle_outline,
                                  color:
                                      tx["type"] == "GAIN"
                                          ? Colors.green
                                          : Colors.red,
                                ),
                                title: Text(
                                  "Valeur: ${tx["valeur"]} points (${tx["type"]})",
                                ),
                                subtitle: Text(
                                  "Date: ${tx["date"]}\nClient: ${tx["clientPhone"] ?? "-"}",
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  //
  void _showProvinceList() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final provinces = _provinceBounds.keys.toList()..sort();
        return ListView.builder(
          itemCount: provinces.length,
          itemBuilder: (context, index) {
            final name = provinces[index];
            LatLngBounds valeur = _provinceBounds[name]!;
            return ListTile(
              title: Text(name),
              onTap: () {
                Get.back();
                //
                // l = [
                //   {
                //     "id": 1,
                //     "type": "GAIN",
                //     "valeur": 3,
                //     "date": "2025-09-23T21:16:37.089803",
                //     "clientPhone": "+243815381693",
                //     "idProduit": 1000,
                //     "idEntreprise": 1,
                //     "lon": 15.2743104,
                //     "lat": -4.3361212,
                //   },
                //   {
                //     "id": 51,
                //     "type": "GAIN",
                //     "valeur": 3,
                //     "date": "2025-09-24T20:05:22.836572",
                //     "clientPhone": "+243815381693",
                //     "idProduit": 1,
                //     "idEntreprise": 1,
                //     "lon": 15.2743187,
                //     "lat": -4.3361143,
                //   },
                // ];
                //
                List<PointData> points = DataConverter.fromMapList(le);
                //
                Get.to(ClusterMap(points: points));
                //Get.to(MapZonesPage(name, valeur));
              },
            );
          },
        );
      },
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
}

class MapZonesPage extends StatelessWidget {
  String nom;
  LatLngBounds map;
  MapZonesPage(this.nom, this.map, {super.key});
  //
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    // Exemple de zones avec un score de concentration
    final List<ZoneData> zones = [
      ZoneData(
        points: [
          LatLng(-4.32, 15.30),
          LatLng(-4.33, 15.31),
          LatLng(-4.34, 15.29),
        ],
        color: Colors.red.withOpacity(0.4),
        borderColor: Colors.red,
        score: 45,
      ),
      ZoneData(
        points: [
          LatLng(-4.33, 15.33),
          LatLng(-4.34, 15.34),
          LatLng(-4.35, 15.32),
        ],
        color: Colors.green.withOpacity(0.4),
        borderColor: Colors.green,
        score: 12,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Carte avec zones")),
      body: FlutterMap(
        //mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(-4.325, 15.322), // Kinshasa par ex.
          cameraConstraint: CameraConstraint.containCenter(bounds: map),
          initialZoom: 13,
          //interactiveFlags: InteractiveFlag.all,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
            //"https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            //subdomains: ['a', 'b', 'c'],
            //userAgentPackageName: 'com.example.matabisi_admin',
            subdomains: const ['a', 'b', 'c'],
            tileProvider: NetworkTileProvider(),
          ),
          // Polygones colorés
          PolygonLayer(
            polygons:
                zones.map((zone) {
                  return Polygon(
                    points: zone.points,
                    color: zone.color,
                    borderStrokeWidth: 2,
                    borderColor: zone.borderColor,
                  );
                }).toList(),
          ),
          // Ajout des chiffres au centre des zones
          MarkerLayer(
            markers:
                zones.map((zone) {
                  final center = _getPolygonCenter(zone.points);
                  return Marker(
                    point: center,
                    width: 50,
                    height: 50,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: zone.borderColor, width: 2),
                      ),
                      child: Text(
                        "${zone.score}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  /// Calcule le centre approximatif d’un polygone
  LatLng _getPolygonCenter(List<LatLng> points) {
    double lat = 0;
    double lng = 0;
    for (var p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }
}

class ZoneData {
  final List<LatLng> points;
  final Color color;
  final Color borderColor;
  final int score;

  ZoneData({
    required this.points,
    required this.color,
    required this.borderColor,
    required this.score,
  });
}
