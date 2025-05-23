import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/revenu.dart';
import '../service/RevenuService.dart';

class RevenusScreen extends StatefulWidget {
  const RevenusScreen({super.key});

  @override
  _RevenusScreenState createState() => _RevenusScreenState();
}

class _RevenusScreenState extends State<RevenusScreen> {
  final RevenuService _service = RevenuService();
  List<Revenu> _revenus = [];
  DateTimeRange? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allRevenus = await _service.getAllRevenus();
    if (_selectedPeriod == null) {
      final now = DateTime.now();
      _selectedPeriod = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      );
    }
    _revenus = allRevenus.where((r) {
      final date = DateTime.tryParse(r.date);
      return date != null && _selectedPeriod!.start.isBefore(date.add(const Duration(days: 1))) && date.isBefore(_selectedPeriod!.end.add(const Duration(days: 1)));
    }).toList();
    setState(() {});
  }

  Future<void> _addRevenu() async {
    final _montantController = TextEditingController();
    final _libelleController = TextEditingController();
    final _observationController = TextEditingController();
    DateTime? selectedDate = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau revenu'),
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
              if (montant == null || _libelleController.text.isEmpty) return;

              final revenu = Revenu(
                montant: montant,
                libelle: _libelleController.text.trim(),
                date: selectedDate!.toIso8601String().split('T')[0],
                observation: _observationController.text.trim(),
              );

              await _service.insertRevenu(revenu);
              Navigator.pop(context, true);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true) _loadData();
  }

  Future<void> _deleteRevenu(int id) async {
    await _service.deleteRevenu(id);
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
        title: const Text('Revenus'),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Filtrer par période',
            onPressed: _selectPeriod,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRevenu,
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liste des revenus',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._revenus.map((rev) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.add_circle, color: Colors.white),
                ),
                title: Text(rev.libelle ?? ''),
                subtitle: Text('${formatDate(rev.date)}\n${rev.observation ?? ''}'),
                trailing: Text(
                  '+${rev.montant.toStringAsFixed(0)} F CFA',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onLongPress: () => _deleteRevenu(rev.id!),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
