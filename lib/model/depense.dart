class Depense {
  final int? id;
  final double montant;
  final String date; // format ISO 'yyyy-MM-dd'
  final int? categorieId;
  final String? libelle;
  final String? observation;

  Depense({
    this.id,
    required this.montant,
    required this.date,
    this.categorieId,
    this.libelle,
    this.observation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montant': montant,
      'date': date,
      'categorieId': categorieId,
      'libelle': libelle,
      'observation': observation,
    };
  }

  factory Depense.fromMap(Map<String, dynamic> map) {
    return Depense(
      id: map['id'],
      montant: map['montant'],
      date: map['date'],
      categorieId: map['categorieId'],
      libelle: map['libelle'],
      observation: map['observation'],
    );
  }
}
