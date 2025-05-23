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
  final TextEditingController _controller = TextEditingController();
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

  Future<void> _addCategorie() async {
    String libelle = _controller.text.trim();
    if (libelle.isEmpty) return;

    await _service.insertCategorie(Categorie(libelle: libelle));
    _controller.clear();
    _loadCategories();
  }

  Future<void> _deleteCategorie(int id) async {
    final used = await _service.isUsedInDepense(id);
    if (used) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible de supprimer : catégorie utilisée.'),
      ));
      return;
    }
    await _service.deleteCategorie(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajouter une catégorie',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Libellé',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _addCategorie,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Liste des catégories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        backgroundColor: Colors.cyan,
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
