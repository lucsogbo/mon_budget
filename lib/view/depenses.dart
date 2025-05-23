import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/depense.dart';
import '../model/categorie.dart';
import '../service/DepenseService.dart';
import '../service/CategorieService.dart';

class DepensesScreen extends StatefulWidget {
  const DepensesScreen({super.key});

  @override
  _DepensesScreenState createState() => _DepensesScreenState();
}

class _DepensesScreenState extends State<DepensesScreen> {
  final DepenseService _service = DepenseService();
  final CategorieService _categorieService = CategorieService();

  final _montantController = TextEditingController();
  final _libelleController = TextEditingController();
  int? _selectedCategorieId;

  List<Depense> _depenses = [];
  List<Categorie> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _depenses = await _service.getAllDepenses();
    _categories = await _categorieService.getAllCategories();
    setState(() {});
  }

  Future<void> _addDepense() async {
    final montant = double.tryParse(_montantController.text);
    final libelle = _libelleController.text.trim();

    if (montant == null || libelle.isEmpty || _selectedCategorieId == null) return;

    final date = DateTime.now().toIso8601String().split('T')[0];

    final depense = Depense(
      montant: montant,
      date: date,
      libelle: libelle,
      categorieId: _selectedCategorieId,
    );

    await _service.insertDepense(depense);
    _montantController.clear();
    _libelleController.clear();
    _selectedCategorieId = null;
    _loadData();
  }

  Future<void> _deleteDepense(int id) async {
    await _service.deleteDepense(id);
    _loadData();
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM', 'fr_FR').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dépenses'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter une dépense',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant (F CFA)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _libelleController,
              decoration: const InputDecoration(
                labelText: 'Libellé',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedCategorieId,
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.libelle),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategorieId = value),
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addDepense,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Liste des dépenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._depenses.map((dep) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.remove_circle, color: Colors.white),
                ),
                title: Text(dep.libelle ?? ''),
                subtitle: Text(formatDate(dep.date)),
                trailing: Text(
                  '-${dep.montant.toStringAsFixed(0)} F CFA',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onLongPress: () => _deleteDepense(dep.id!),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
