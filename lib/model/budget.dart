class Budget {
  final int? id;
  final int categorieId;
  final double montant;
  final String periode; // exemple : "mensuel", "trimestriel"

  Budget({
    this.id,
    required this.categorieId,
    required this.montant,
    required this.periode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categorieId': categorieId,
      'montant': montant,
      'periode': periode,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categorieId: map['categorieId'],
      montant: map['montant'],
      periode: map['periode'],
    );
  }
}
