class Budget {
  final int? id;
  final int categorieId;
  final double montant;
  final String periodicite; // exemple : "mensuel", "trimestriel"

  Budget({
    this.id,
    required this.categorieId,
    required this.montant,
    required this.periodicite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categorieId': categorieId,
      'montant': montant,
      'periodicite': periodicite,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categorieId: map['categorieId'],
      montant: map['montant'],
      periodicite: map['periodicite'],
    );
  }
}
