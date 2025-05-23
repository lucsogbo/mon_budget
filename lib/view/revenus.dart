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
  final _montantController = TextEditingController();
  final _libelleController = TextEditingController();

  List<Revenu> _revenus = [];

  @override
  void initState() {
    super.initState();
    _loadRevenus();
  }

  Future<void> _loadRevenus() async {
    final list = await _service.getAllRevenus();
    setState(() {
      _revenus = list;
    });
  }

  Future<void> _addRevenu() async {
    final montant = double.tryParse(_montantController.text);
    final libelle = _libelleController.text.trim();

    if (montant == null || libelle.isEmpty) return;

    final date = DateTime.now().toIso8601String().split('T')[0];

    final revenu = Revenu(
      montant: montant,
      date: date,
      libelle: libelle,
    );

    await _service.insertRevenu(revenu);
    _montantController.clear();
    _libelleController.clear();
    _loadRevenus();
  }

  Future<void> _deleteRevenu(int id) async {
    await _service.deleteRevenu(id);
    _loadRevenus();
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
        title: const Text('Revenus'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajouter un revenu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant (F CFA)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _libelleController,
              decoration: const InputDecoration(
                labelText: 'Libellé',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addRevenu,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Liste des revenus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._revenus.map((rev) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add_circle, color: Colors.white),
                ),
                title: Text(rev.libelle ?? ''),
                subtitle: Text(formatDate(rev.date)),
                trailing: Text(
                  '+${rev.montant.toStringAsFixed(0)} F CFA',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onLongPress: () => _deleteRevenu(rev.id!),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
