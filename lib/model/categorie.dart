class Categorie {
  final int? id;
  final String libelle;

  Categorie({this.id, required this.libelle});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'libelle': libelle,
    };
  }

  factory Categorie.fromMap(Map<String, dynamic> map) {
    return Categorie(
      id: map['id'],
      libelle: map['libelle'],
    );
  }
}
