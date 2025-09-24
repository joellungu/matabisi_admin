class Produit {
  final int id;
  final String nomCategorie;
  final String codeUnique;
  final int valeurPoints;

  Produit({
    required this.id,
    required this.nomCategorie,
    required this.codeUnique,
    required this.valeurPoints,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'],
      nomCategorie: json['nomCategorie'],
      codeUnique: json['codeUnique'],
      valeurPoints: json['valeurPoints'],
    );
  }
}
