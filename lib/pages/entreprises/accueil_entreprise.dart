import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:matabisi_admin/pages/entreprises/cat_produits.dart';
import 'package:matabisi_admin/pages/entreprises/parametres_entreprise.dart';
import 'package:matabisi_admin/pages/entreprises/transaction_entreprise.dart';
import 'package:matabisi_admin/pages/super_admin/nouvelle_entreprise2.dart';
import 'package:http/http.dart' as http;
import 'package:matabisi_admin/utils/requete.dart';

import 'entreprise_controller.dart';

class AccueilEntreprise extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AccueilEntreprise> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    CatProduits(),
    TransactionEntreprise(),
    ParametresEntreprise(),
  ];
  var box = GetStorage();
  Map entreprise = {};
  //
  Requete requete = Requete();
  //
  EntrepriseController entrepriseController = Get.find();
  //

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    //
    entreprise = box.read("user") ?? {};
    //
    super.initState();
    //
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Admin - ${entreprise['nom']} • ${entreprise['secteur']}',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF111B21), // const Color(0xFF128C7E),
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.account_circle), onPressed: () {}),
        ],
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
                _buildSidebarItem(Icons.business, 'Produits', 0),
                //_buildSidebarItem(Icons.people, 'Utilisateurs', 1),
                _buildSidebarItem(Icons.shopping_cart, 'Rapports', 1),
                _buildSidebarItem(Icons.settings, 'Parametres', 2),
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
                          'Produits',
                          "${entrepriseController.produits.length}",
                        ),
                      ),
                      Obx(
                        () => _buildStatItem(
                          'Catégorie',
                          '${entrepriseController.produitCategories.length}',
                        ),
                      ),
                      FutureBuilder(
                        future: getAllProduits(entreprise['id']),
                        builder: (c, t) {
                          //
                          if (t.hasData) {
                            Map compteEnt = t.data as Map;
                            //
                            return _buildStatItem(
                              'Compte',
                              '${compteEnt['soldePoints']} Pts',
                            );
                          } else if (t.hasError) {
                            return _buildStatItem('Compte', '0 Pts');
                          }
                          return _buildStatItem('Compte', '-0 Pts');
                        },
                      ),
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

  Future<Map> getAllProduits(int idEntreprise) async {
    //
    Map user = box.read("user") ?? {};
    //idEntreprise
    http.Response response = await requete.getE(
      "api/Compte/entreprise/$idEntreprise",
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
      return {};
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

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Utilisateurs',
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
                    hintText: 'Rechercher un utilisateur...',
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
              FilterChip(label: Text('Nouveaux'), onSelected: (bool value) {}),
            ],
          ),
          SizedBox(height: 16),
          // Liste des utilisateurs
          Expanded(
            child: ListView(
              children: [
                _buildUserCard(
                  'Marie Dupont',
                  'marie.dupont@example.com',
                  '06 12 34 56 78',
                  '1 245 points',
                  '12 achats',
                ),
                _buildUserCard(
                  'Jean Martin',
                  'jean.martin@example.com',
                  '06 23 45 67 89',
                  '2 567 points',
                  '18 achats',
                ),
                _buildUserCard(
                  'Sophie Lambert',
                  'sophie.lambert@example.com',
                  '06 34 56 78 90',
                  '3 128 points',
                  '24 achats',
                ),
                _buildUserCard(
                  'Thomas Leroy',
                  'thomas.leroy@example.com',
                  '06 45 67 89 01',
                  '876 points',
                  '9 achats',
                ),
                _buildUserCard(
                  'Camille Petit',
                  'camille.petit@example.com',
                  '06 56 78 90 12',
                  '1 987 points',
                  '15 achats',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    String name,
    String email,
    String phone,
    String points,
    String purchases,
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
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                SizedBox(width: 4),
                Text(points),
                SizedBox(width: 16),
                Icon(
                  Icons.shopping_cart,
                  size: 16,
                  color: const Color(0xFF128C7E),
                ),
                SizedBox(width: 4),
                Text(purchases),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // Voir les détails de l'utilisateur
        },
      ),
    );
  }
}

class PurchasesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achats',
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
                    hintText: 'Rechercher un achat...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              SizedBox(width: 16),
              FilterChip(
                label: Text('Aujourd\'hui'),
                onSelected: (bool value) {},
                backgroundColor: const Color(0xFF128C7E),
                labelStyle: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 8),
              FilterChip(
                label: Text('Cette semaine'),
                onSelected: (bool value) {},
              ),
              SizedBox(width: 8),
              FilterChip(label: Text('Ce mois'), onSelected: (bool value) {}),
            ],
          ),
          SizedBox(height: 16),
          // Statistiques
          Row(
            children: [
              _buildStatCard('Achats aujourd\'hui', '247', Icons.shopping_cart),
              SizedBox(width: 16),
              _buildStatCard('Points distribués', '12 458', Icons.star),
              SizedBox(width: 16),
              _buildStatCard('Valeur moyenne', '24,75€', Icons.euro),
            ],
          ),
          SizedBox(height: 16),
          // Liste des achats
          Expanded(
            child: ListView(
              children: [
                _buildPurchaseCard(
                  'Marie Dupont',
                  'Café de la Gare',
                  '12,50 €',
                  '125 points',
                  'Aujourd\'hui, 09:24',
                ),
                _buildPurchaseCard(
                  'Jean Martin',
                  'Boulangerie Dupont',
                  '8,20 €',
                  '82 points',
                  'Aujourd\'hui, 10:15',
                ),
                _buildPurchaseCard(
                  'Sophie Lambert',
                  'Restaurant Le Petit Jardin',
                  '32,40 €',
                  '324 points',
                  'Aujourd\'hui, 12:45',
                ),
                _buildPurchaseCard(
                  'Thomas Leroy',
                  'Magasin Bio Nature',
                  '18,75 €',
                  '187 points',
                  'Aujourd\'hui, 15:30',
                ),
                _buildPurchaseCard(
                  'Camille Petit',
                  'Librairie Page 42',
                  '22,00 €',
                  '220 points',
                  'Aujourd\'hui, 17:12',
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildPurchaseCard(
    String user,
    String enterprise,
    String amount,
    String points,
    String date,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF128C7E),
          child: Icon(Icons.shopping_cart, color: Colors.white),
        ),
        title: Text(user, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(enterprise),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.euro, size: 16, color: const Color(0xFF128C7E)),
                SizedBox(width: 4),
                Text(amount),
                SizedBox(width: 16),
                Icon(Icons.star, size: 16, color: Colors.amber),
                SizedBox(width: 4),
                Text(points),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        onTap: () {
          // Voir les détails de l'achat
        },
      ),
    );
  }
}
