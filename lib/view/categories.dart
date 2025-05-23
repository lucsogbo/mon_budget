import 'package:flutter/material.dart';
import '../model/categorie.dart';
import '../service/CategorieService.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategorieService _service = CategorieService();
  List<Categorie> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final list = await _service.getAllCategories();
    setState(() {
      _categories = list;
    });
  }

  Future<void> _deleteCategorie(int id) async {
    final used = await _service.isUsedInDepense(id);
    if (used) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer : catégorie utilisée.')),
      );
      return;
    }
    await _service.deleteCategorie(id);
    _loadCategories();
  }

  void _navigateToAddCategorie() async {
    final libelle = await showDialog<String>(
      context: context,
      builder: (context) {
        final _controller = TextEditingController();
        return AlertDialog(
          title: const Text('Nouvelle catégorie'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Libellé'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _controller.text.trim()),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (libelle != null && libelle.isNotEmpty) {
      await _service.insertCategorie(Categorie(libelle: libelle));
      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCategorie,
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        tooltip: 'Ajouter une catégorie',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Liste des catégories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.category, color: Colors.white),
                      ),
                      title: Text(cat.libelle),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategorie(cat.id!),
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
