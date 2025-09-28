import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:matabisi_admin/utils/cluster.dart';
import 'package:matabisi_admin/utils/point_data.dart';

class ClusterManager {
  static List<Cluster> clusterPoints(
    List<PointData> points, {
    double clusterRadius = 0.01,
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

      // Trouver tous les points proches
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

      // Calculer les propriétés du cluster
      final center = _calculateCenter(nearbyPoints);
      final averageValue = _calculateAverage(nearbyPoints);
      final dominantType = _getDominantType(nearbyPoints);

      if (nearbyPoints.length >= minClusterSize) {
        // Cluster groupé
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
        // Points individuels
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
    const earthRadius = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static LatLng _calculateCenter(List<PointData> points) {
    double totalLat = 0;
    double totalLon = 0;

    for (final point in points) {
      totalLat += point.lat;
      totalLon += point.lon;
    }

    return LatLng(totalLat / points.length, totalLon / points.length);
  }

  static double _calculateAverage(List<PointData> points) {
    return points.map((p) => p.valeur).reduce((a, b) => a + b) / points.length;
  }

  static String? _getDominantType(List<PointData> points) {
    final counts = <String, int>{};
    for (final point in points) {
      counts[point.type] = (counts[point.type] ?? 0) + 1;
    }

    String? dominantType;
    int maxCount = 0;

    counts.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantType = type;
      }
    });

    return dominantType;
  }
}
