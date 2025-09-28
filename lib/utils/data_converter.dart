import 'package:matabisi_admin/utils/point_data.dart';

class DataConverter {
  static List<PointData> fromMapList(List<dynamic> mapList) {
    return mapList.map((item) {
      if (item is Map<String, dynamic>) {
        return PointData.fromJson(item);
      } else {
        throw FormatException('L\'élément n\'est pas une Map valide: $item');
      }
    }).toList();
  }

  // Alternative avec gestion d'erreurs
  static List<PointData> fromMapListSafe(List<dynamic> mapList) {
    final List<PointData> points = [];

    for (final item in mapList) {
      try {
        if (item is Map<String, dynamic>) {
          points.add(PointData.fromJson(item));
        } else {
          print('Élément ignoré - format invalide: $item');
        }
      } catch (e) {
        print('Erreur lors de la conversion de l\'élément $item: $e');
      }
    }

    return points;
  }
}
