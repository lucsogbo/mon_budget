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

  List<Depense> _depenses = [];
  List<Categorie> _categories = [];
  int? _selectedCategorieId;
  DateTimeRange? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _categories = await _categorieService.getAllCategories();
    final allDepenses = await _service.getAllDepenses();
    if (_selectedPeriod == null) {
      final now = DateTime.now();
      _selectedPeriod = DateTimeRange(
        start: now.subtract(Duration(days: now.weekday - 1)),
        end: now,
      );
    }
    _depenses = allDepenses.where((dep) {
      final date = DateTime.tryParse(dep.date);
      return date != null && _selectedPeriod!.start.isBefore(date.add(const Duration(days: 1))) && date.isBefore(_selectedPeriod!.end.add(const Duration(days: 1)));
    }).toList();
    setState(() {});
  }

  Future<void> _addDepense() async {
    final _montantController = TextEditingController();
    final _libelleController = TextEditingController();
    final _observationController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    int? selectedCategorie;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle dépense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _libelleController,
                decoration: const InputDecoration(labelText: 'Libellé'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Catégorie'),
                value: selectedCategorie,
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.libelle),
                )).toList(),
                onChanged: (val) => selectedCategorie = val,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _observationController,
                decoration: const InputDecoration(labelText: 'Observation (facultatif)'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate!,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) selectedDate = picked;
                },
                child: const Text('Sélectionner une date'),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final montant = double.tryParse(_montantController.text);
              if (montant == null || selectedCategorie == null || _libelleController.text.isEmpty) return;

              final depense = Depense(
                montant: montant,
                libelle: _libelleController.text.trim(),
                date: selectedDate!.toIso8601String().split('T')[0],
                categorieId: selectedCategorie,
                observation: _observationController.text.trim(),
              );

              await _service.insertDepense(depense);
              Navigator.pop(context, true);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true) _loadData();
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

  Future<void> _selectPeriod() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedPeriod,
    );
    if (picked != null) {
      _selectedPeriod = picked;
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dépenses'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Filtrer par période',
            onPressed: _selectPeriod,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDepense,
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liste des dépenses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                subtitle: Text('${formatDate(dep.date)}\n${dep.observation ?? ''}'),
                trailing: Text(
                  '-${dep.montant.toStringAsFixed(0)} F CFA',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onLongPress: () => _deleteDepense(dep.id!),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
