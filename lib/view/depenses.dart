// Nouvelle version inspirée de budgets.dart avec formulaire intégré

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
  String _selectedPeriod = 'Tous';
  final List<String> _periodOptions = ['Tous', 'Hebdomadaire', 'Mensuel', 'Trimestriel', 'Annuel'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _categories = await _categorieService.getAllCategories();
    _depenses = await _service.getAllDepenses();
    setState(() {});
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

  void _showAddDepenseDialog() {
    final _formKey = GlobalKey<FormState>();
    final _dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final _montantCtrl = TextEditingController();
    final _libelleCtrl = TextEditingController();
    final _obsCtrl = TextEditingController();
    int? selectedCategorieId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle dépense'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _dateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Date de la dépense',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedCategorieId,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie de la dépense',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.libelle),
                  )).toList(),
                  onChanged: (val) => selectedCategorieId = val,
                  validator: (val) => val == null ? 'Choisir une catégorie' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _montantCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Montant de la dépense',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Entrer un montant' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _libelleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Libellé de la dépense',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Entrer un libellé' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _obsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Observation (facultatif)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final dep = Depense(
                  date: _dateCtrl.text,
                  categorieId: selectedCategorieId!,
                  montant: double.parse(_montantCtrl.text),
                  libelle: _libelleCtrl.text,
                  observation: _obsCtrl.text,
                );
                await _service.insertDepense(dep);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dépenses'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Liste des dépenses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedPeriod,
              items: _periodOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                  // TODO: filtrer par période
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _depenses.length,
                itemBuilder: (context, index) {
                  final dep = _depenses[index];
                  final cat = _categories.firstWhere(
                        (c) => c.id == dep.categorieId,
                    orElse: () => Categorie(libelle: 'Inconnue'),
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      title: Text(dep.libelle ?? ''),
                      subtitle: Text('${formatDate(dep.date)}\nCatégorie : ${cat.libelle}\n${dep.observation ?? ''}'),
                      trailing: Text('-${dep.montant.toStringAsFixed(0)} F CFA', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onLongPress: () => _deleteDepense(dep.id!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDepenseDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
