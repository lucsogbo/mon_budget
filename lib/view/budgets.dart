import 'package:flutter/material.dart';
import '../model/budget.dart';
import '../model/categorie.dart';
import '../service/BudgetService.dart';
import '../service/CategorieService.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final BudgetService _budgetService = BudgetService();
  final CategorieService _categorieService = CategorieService();

  List<Budget> _budgets = [];
  List<Categorie> _categories = [];

  final List<String> _periodicites = [
    'Hebdomadaire', 'Mensuel', 'Trimestriel', 'Annuel'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _budgets = await _budgetService.getAllBudgets();
    _categories = await _categorieService.getAllCategories();
    setState(() {});
  }

  Future<void> _deleteBudget(int id) async {
    await _budgetService.deleteBudget(id);
    _loadData();
  }

  void _navigateToAddBudget({Budget? budgetToEdit}) async {
    final TextEditingController _montantCtrl = TextEditingController(text: budgetToEdit?.montant.toString() ?? '');
    String? selectedPeriodicite = budgetToEdit?.periodicite;
    int? selectedCategorieId = budgetToEdit?.categorieId;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(budgetToEdit == null ? 'Nouveau budget' : 'Modifier budget'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _montantCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPeriodicite,
                decoration: const InputDecoration(
                  labelText: 'Périodicité',
                  border: OutlineInputBorder(),
                ),
                items: _periodicites.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p),
                )).toList(),
                onChanged: (value) => selectedPeriodicite = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedCategorieId,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.libelle),
                )).toList(),
                onChanged: (value) => selectedCategorieId = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final montant = double.tryParse(_montantCtrl.text);
              if (montant == null || selectedPeriodicite == null || selectedCategorieId == null) return;

              // empêcher les doublons de périodicité pour une même catégorie
              final exist = _budgets.any((b) =>
              b.periodicite == selectedPeriodicite &&
                  b.categorieId == selectedCategorieId &&
                  (budgetToEdit == null || b.id != budgetToEdit.id));
              if (exist) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ce budget existe déjà pour cette périodicité.')),
                );
                return;
              }

              if (budgetToEdit == null) {
                await _budgetService.insertBudget(Budget(
                  montant: montant,
                  periodicite: selectedPeriodicite!,
                  categorieId: selectedCategorieId!,
                ));
              } else {
                await _budgetService.updateBudget(Budget(
                  id: budgetToEdit.id,
                  montant: montant,
                  periodicite: selectedPeriodicite!,
                  categorieId: selectedCategorieId!,
                ));
              }

              Navigator.pop(context, true);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBudget(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Liste des budgets',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _budgets.length,
                itemBuilder: (context, index) {
                  final b = _budgets[index];
                  final cat = _categories.firstWhere((c) => c.id == b.categorieId, orElse: () => Categorie(libelle: 'Inconnu'));
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.account_balance_wallet),
                      title: Text('${b.montant.toStringAsFixed(0)} F - ${b.periodicite}'),
                      subtitle: Text('Catégorie : ${cat.libelle}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateToAddBudget(budgetToEdit: b),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBudget(b.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
