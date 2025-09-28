import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:matabisi_admin/utils/cluster.dart';
import 'package:matabisi_admin/utils/point_data.dart';

class ClusterMap extends StatefulWidget {
  final List<PointData> points;

  const ClusterMap({Key? key, required this.points}) : super(key: key);

  @override
  _ClusterMapState createState() => _ClusterMapState();
}

class _ClusterMapState extends State<ClusterMap> {
  late List<Cluster> _clusters;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _updateClusters();
  }

  @override
  void didUpdateWidget(ClusterMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _updateClusters();
    }
  }

  void _updateClusters() {
    _clusters = ClusterManager.clusterPoints(widget.points);
  }

  Color _getClusterColor(Cluster cluster) {
    if (cluster.count == 1) {
      // Points individuels - couleur par type
      switch (cluster.type) {
        case 'GAIN':
          return Colors.green;
        case 'PERTE':
          return Colors.red;
        default:
          return Colors.blue;
      }
    } else {
      // Clusters multiples - couleur par densité
      if (cluster.count <= 5) {
        return Colors.orange;
      } else if (cluster.count <= 20) {
        return Colors.deepOrange;
      } else {
        return Colors.red;
      }
    }
  }

  double _getClusterSize(Cluster cluster) {
    // Taille du cercle proportionnelle au nombre de points
    final baseSize = 20.0;
    final scaleFactor = log(cluster.count + 1) / log(2);
    return baseSize * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(-4.3361212, 15.2743104), // Centre sur le Congo
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          CircleLayer(
            circles:
                _clusters.map((cluster) {
                  return CircleMarker(
                    point: cluster.position,
                    color: _getClusterColor(cluster).withOpacity(0.7),
                    borderColor: _getClusterColor(cluster).withOpacity(0.9),
                    borderStrokeWidth: 2,
                    radius: _getClusterSize(cluster),
                  );
                }).toList(),
          ),
          MarkerLayer(
            markers:
                _clusters.map((cluster) {
                  return Marker(
                    point: cluster.position,
                    width: _getClusterSize(cluster) * 2,
                    height: _getClusterSize(cluster) * 2,

                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        cluster.count > 1 ? cluster.count.toString() : '•',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: cluster.count > 1 ? 14 : 20,
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
}
