class PointData {
  final int id;
  final String type;
  final double valeur;
  final DateTime date;
  final String clientPhone;
  final int idProduit;
  final int idEntreprise;
  final double lon;
  final double lat;

  PointData({
    required this.id,
    required this.type,
    required this.valeur,
    required this.date,
    required this.clientPhone,
    required this.idProduit,
    required this.idEntreprise,
    required this.lon,
    required this.lat,
  });

  factory PointData.fromJson(Map<String, dynamic> json) {
    return PointData(
      id: json['id'],
      type: json['type'],
      valeur:
          json['valeur'] is int
              ? (json['valeur'] as int).toDouble()
              : json['valeur'],
      date: DateTime.parse(json['date']),
      clientPhone: json['clientPhone'],
      idProduit: json['idProduit'],
      idEntreprise: json['idEntreprise'],
      lon: json['lon'] is int ? (json['lon'] as int).toDouble() : json['lon'],
      lat: json['lat'] is int ? (json['lat'] as int).toDouble() : json['lat'],
    );
  }
}
