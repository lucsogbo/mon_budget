class Revenu {
  final int? id;
  final double montant;
  final String date;
  final String? libelle;
  final String? observation;

  Revenu({
    this.id,
    required this.montant,
    required this.date,
    this.libelle,
    this.observation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montant': montant,
      'date': date,
      'libelle': libelle,
      'observation': observation,
    };
  }

  factory Revenu.fromMap(Map<String, dynamic> map) {
    return Revenu(
      id: map['id'],
      montant: map['montant'],
      date: map['date'],
      libelle: map['libelle'],
      observation: map['observation'],
    );
  }
}
