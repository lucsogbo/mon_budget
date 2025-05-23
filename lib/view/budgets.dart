import 'package:flutter/material.dart';
import '../model/budget.dart';
import '../service/BudgetService.dart';
import '../model/categorie.dart';
import '../service/CategorieService.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  _BudgetsScreenState createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final BudgetService _budgetService = BudgetService();
  final CategorieService _categorieService = CategorieService();

  final _montantController = TextEditingController();
  String? _periode = 'Mensuel';
  int? _selectedCategorieId;

  List<Budget> _budgets = [];
  List<Categorie> _categories = [];

  final List<String> _periodes = ['Mensuel', 'Trimestriel', 'Annuel'];

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

  Future<void> _addBudget() async {
    final montant = double.tryParse(_montantController.text);
    if (_selectedCategorieId == null || _periode == null || montant == null) return;

    final exists = await _budgetService.isDuplicate(_selectedCategorieId!, _periode!);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Un budget existe déjà pour cette catégorie et cette période.'),
      ));
      return;
    }

    final budget = Budget(
      categorieId: _selectedCategorieId!,
      montant: montant,
      periode: _periode!,
    );

    await _budgetService.insertBudget(budget);
    _montantController.clear();
    _selectedCategorieId = null;
    _periode = 'Mensuel';
    _loadData();
  }

  Future<void> _deleteBudget(int id) async {
    await _budgetService.deleteBudget(id);
    _loadData();
  }

  String? getCategorieName(int id) {
    return _categories.firstWhere((c) => c.id == id, orElse: () => Categorie(id: 0, libelle: "Inconnu")).libelle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajouter un budget',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedCategorieId,
              hint: const Text("Sélectionner une catégorie"),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.libelle),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategorieId = value),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant (F CFA)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _periode,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _periodes.map((periode) {
                return DropdownMenuItem(value: periode, child: Text(periode));
              }).toList(),
              onChanged: (value) => setState(() => _periode = value),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addBudget,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Liste des budgets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._budgets.map((budget) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                ),
                title: Text('${getCategorieName(budget.categorieId)} - ${budget.periode}'),
                subtitle: Text('Montant : ${budget.montant.toStringAsFixed(0)} F CFA'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBudget(budget.id!),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
