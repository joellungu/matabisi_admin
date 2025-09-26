import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matabisi_admin/pages/login.dart';
import 'package:matabisi_admin/pages/super_admin/nouvelle_entreprise2.dart';
import 'package:matabisi_admin/pages/super_admin/publicite_page.dart';
import 'package:matabisi_admin/pages/super_admin/super_admin_controller.dart';
import 'package:http/http.dart' as http;
import 'package:matabisi_admin/pages/super_admin/transactions.dart';
import 'package:matabisi_admin/utils/requete.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    EntrepriseFormPage(),
    TransactionPage(),
    PublicitePage(),
  ];
  //
  Requete requete = Requete();
  //
  SuperAdminController superAdminController = Get.find();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Admin - Plateforme',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF111B21), // const Color(0xFF128C7E),
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Get.offAll(LoginScreen());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: const Color(0xFF128C7E)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: const Color(0xFF128C7E),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Administrateur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'admin@platform.com',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.business, color: const Color(0xFF128C7E)),
              title: Text('Entreprises'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: const Color(0xFF128C7E)),
              title: Text('Utilisateurs'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.shopping_cart,
                color: const Color(0xFF128C7E),
              ),
              title: Text('Achats'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey),
              title: Text('Paramètres'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.grey),
              title: Text('Déconnexion'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'MENU PRINCIPAL',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSidebarItem(Icons.business, 'Entreprises', 0),
                //_buildSidebarItem(Icons.people, 'Utilisateurs', 1),
                _buildSidebarItem(Icons.shopping_cart, 'Transaction', 1),
                _buildSidebarItem(Icons.announcement, 'Publicités', 2),
                Spacer(),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STATISTIQUES',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildStatItem('Taux', '10 Pts = 0.1 \$'),
                      Obx(
                        () => _buildStatItem(
                          'Entreprises',
                          '${superAdminController.entreprises.length}',
                        ),
                      ),
                      //_buildStatItem('Utilisateurs', '1,542'),
                      FutureBuilder(
                        future: getAllUtilisateurs(),
                        builder: (c, t) {
                          //
                          if (t.hasData) {
                            int compteEnt = t.data as int;
                            //
                            return _buildStatItem(
                              'Utilisateurs',
                              '$compteEnt Uts',
                            );
                          } else if (t.hasError) {
                            return _buildStatItem('Utilisateurs', '0 Uts');
                          }
                          return _buildStatItem('Utilisateurs', '-0 Uts');
                        },
                      ),
                      _buildStatItem('Achats aujourd\'hui', '247'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(width: 1),
          // Main content
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }

  //
  Future<int> getAllUtilisateurs() async {
    //
    http.Response response = await requete.getE(
      "api/Client/nombre",
      //user['token'],
    );
    //
    if (response.statusCode == 200 || response.statusCode == 201) {
      //
      print("SUCCES: ${response.statusCode}");
      print("SUCCES: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("ERREUR: ${response.statusCode}");
      print("ERREUR: ${response.body}");
      return 0;
    }
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? const Color(0xFF128C7E) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color:
              _selectedIndex == index
                  ? const Color(0xFF111B21) //const Color(0xFF128C7E)
                  : Colors.black87,
          fontWeight:
              _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _selectedIndex == index,
      onTap: () {
        _onItemTapped(index);
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF128C7E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class EnterprisesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entreprises partenaires',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          // Filtres et recherche
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Rechercher une entreprise...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              SizedBox(width: 16),
              FilterChip(
                label: Text('Tous'),
                onSelected: (bool value) {},
                backgroundColor: const Color(0xFF128C7E),
                labelStyle: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 8),
              FilterChip(label: Text('Actifs'), onSelected: (bool value) {}),
              SizedBox(width: 8),
              FilterChip(label: Text('Inactifs'), onSelected: (bool value) {}),
            ],
          ),
          SizedBox(height: 16),
          // Liste des entreprises
          Expanded(
            child: ListView(
              children: [
                _buildEnterpriseCard(
                  'Café de la Gare',
                  'cafe-gare@example.com',
                  '01 42 34 56 78',
                  '12 345 points',
                  true,
                ),
                _buildEnterpriseCard(
                  'Boulangerie Dupont',
                  'boulangerie-dupont@example.com',
                  '01 43 45 67 89',
                  '8 765 points',
                  true,
                ),
                _buildEnterpriseCard(
                  'Librairie Page 42',
                  'contact@page42.com',
                  '01 44 56 78 90',
                  '5 432 points',
                  false,
                ),
                _buildEnterpriseCard(
                  'Restaurant Le Petit Jardin',
                  'contact@petitjardin.fr',
                  '01 45 67 89 01',
                  '15 678 points',
                  true,
                ),
                _buildEnterpriseCard(
                  'Magasin Bio Nature',
                  'info@bionature.fr',
                  '01 46 78 90 12',
                  '9 876 points',
                  true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterpriseCard(
    String name,
    String email,
    String phone,
    String points,
    bool isActive,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF128C7E),
          child: Text(
            name.substring(0, 1),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(email),
            SizedBox(height: 4),
            Text(phone),
            SizedBox(height: 4),
            Text(points),
          ],
        ),
        trailing: Chip(
          label: Text(
            isActive ? 'Actif' : 'Inactif',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: isActive ? const Color(0xFF25D366) : Colors.grey,
        ),
        onTap: () {
          // Voir les détails de l'entreprise
        },
      ),
    );
  }
}
