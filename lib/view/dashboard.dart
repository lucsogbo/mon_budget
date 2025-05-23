import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/depense.dart';
import '../model/budget.dart';
import '../model/categorie.dart';
import '../service/DepenseService.dart';
import '../service/BudgetService.dart';
import '../service/CategorieService.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DepenseService _depenseService = DepenseService();
  final BudgetService _budgetService = BudgetService();
  final CategorieService _categorieService = CategorieService();

  List<Depense> _depenses = [];
  List<Budget> _budgets = [];
  List<Categorie> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _depenses = await _depenseService.getAllDepenses();
    _budgets = await _budgetService.getAllBudgets();
    _categories = await _categorieService.getAllCategories();
    setState(() {});
  }

  double getTotalDepenseParCategorie(int catId) {
    return _depenses
        .where((d) => d.categorieId == catId)
        .fold(0.0, (sum, d) => sum + d.montant);
  }

  Widget buildPieChart() {
    List<PieChartSectionData> sections = [];
    double totalGlobal = 0;

    for (final cat in _categories) {
      double total = getTotalDepenseParCategorie(cat.id ?? 0);
      if (total > 0) {
        totalGlobal += total;
        sections.add(PieChartSectionData(
          value: total,
          title: '',
          radius: 60,
        ));
      }
    }

    if (sections.isEmpty) {
      return const Center(child: Text("Aucune dépense enregistrée"));
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 4,
              centerSpaceRadius: 30,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ..._categories.where((cat) => getTotalDepenseParCategorie(cat.id ?? 0) > 0).map((cat) {
          double val = getTotalDepenseParCategorie(cat.id ?? 0);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 10),
                const SizedBox(width: 6),
                Text(cat.libelle),
                const Spacer(),
                Text('${val.toStringAsFixed(0)} F CFA'),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget buildBarChart() {
    List<BarChartGroupData> barGroups = [];
    List<String> labels = [];

    for (int i = 0; i < _budgets.length; i++) {
      final budget = _budgets[i];
      double totalDep = getTotalDepenseParCategorie(budget.categorieId);
      final catName = _categories.firstWhere(
              (c) => c.id == budget.categorieId,
          orElse: () => Categorie(id: 0, libelle: "Inconnu"))
          .libelle;

      labels.add(catName);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: budget.montant,
              color: Colors.green,
              width: 8,
            ),
            BarChartRodData(
              toY: totalDep,
              color: Colors.red,
              width: 8,
            ),
          ],
        ),
      );
    }

    if (barGroups.isEmpty) {
      return const Center(child: Text("Aucun budget enregistré"));
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, meta) {
                      if (value.toInt() >= labels.length) return const SizedBox.shrink();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 12)),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dépenses par catégorie",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            buildPieChart(),
            const SizedBox(height: 30),
            const Text("Dépenses vs Budgets",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            buildBarChart(),
          ],
        ),
      ),
    );
  }
}