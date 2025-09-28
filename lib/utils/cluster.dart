import 'dart:math';
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:matabisi_admin/utils/point_data.dart';

class Cluster {
  final double lat;
  final double lon;
  final int count;
  final List<PointData> points;
  final String? type;
  final double averageValue;

  Cluster({
    required this.lat,
    required this.lon,
    required this.count,
    required this.points,
    this.type,
    required this.averageValue,
  });

  LatLng get position => LatLng(lat, lon);
}

class ClusterManager {
  static List<Cluster> clusterPoints(
    List<PointData> points, {
    double clusterRadius = 0.01, // ~1km
    int minClusterSize = 2,
  }) {
    if (points.isEmpty) return [];

    final clusters = <Cluster>[];
    final processed = List<bool>.filled(points.length, false);

    for (int i = 0; i < points.length; i++) {
      if (processed[i]) continue;

      final currentPoint = points[i];
      final nearbyPoints = <PointData>[currentPoint];
      processed[i] = true;

      for (int j = i + 1; j < points.length; j++) {
        if (processed[j]) continue;

        final otherPoint = points[j];
        final distance = _calculateDistance(
          currentPoint.lat,
          currentPoint.lon,
          otherPoint.lat,
          otherPoint.lon,
        );

        if (distance <= clusterRadius) {
          nearbyPoints.add(otherPoint);
          processed[j] = true;
        }
      }

      if (nearbyPoints.length >= minClusterSize) {
        // Créer un cluster
        final center = _calculateCenter(nearbyPoints);
        final averageValue = nearbyPoints.map((p) => p.valeur).average;
        final dominantType = _getDominantType(nearbyPoints);

        clusters.add(
          Cluster(
            lat: center.latitude,
            lon: center.longitude,
            count: nearbyPoints.length,
            points: nearbyPoints,
            type: dominantType,
            averageValue: averageValue,
          ),
        );
      } else {
        // Points isolés - créer des clusters individuels
        for (final point in nearbyPoints) {
          clusters.add(
            Cluster(
              lat: point.lat,
              lon: point.lon,
              count: 1,
              points: [point],
              type: point.type,
              averageValue: point.valeur,
            ),
          );
        }
      }
    }

    return clusters;
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  static LatLng _calculateCenter(List<PointData> points) {
    final avgLat = points.map((p) => p.lat).average;
    final avgLon = points.map((p) => p.lon).average;
    return LatLng(avgLat, avgLon);
  }

  static String? _getDominantType(List<PointData> points) {
    final typeCounts = <String, int>{};
    for (final point in points) {
      typeCounts[point.type] = (typeCounts[point.type] ?? 0) + 1;
    }

    if (typeCounts.isEmpty) return null;

    final maxEntry = typeCounts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return maxEntry.key;
  }
}
