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

  String _selectedPeriod = 'Mensuel';
  DateTimeRange _currentRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  );

  final List<String> _periodOptions = [
    'Hebdomadaire', 'Mensuel', 'Trimestriel', 'Annuel'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _updatePeriod(String newPeriod) {
    final now = DateTime.now();
    DateTimeRange range;
    switch (newPeriod) {
      case 'Hebdomadaire':
        range = DateTimeRange(
          start: now.subtract(Duration(days: now.weekday - 1)),
          end: now,
        );
        break;
      case 'Mensuel':
        range = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
        break;
      case 'Trimestriel':
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final startMonth = (currentQuarter - 1) * 3 + 1;
        range = DateTimeRange(
          start: DateTime(now.year, startMonth, 1),
          end: DateTime(now.year, startMonth + 3, 0),
        );
        break;
      case 'Annuel':
        range = DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31),
        );
        break;
      default:
        range = _currentRange;
    }
    setState(() {
      _selectedPeriod = newPeriod;
      _currentRange = range;
      _loadData();
    });
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
        .where((d) {
      final date = DateTime.tryParse(d.date);
      return date != null && _currentRange.start.isBefore(date.add(const Duration(days: 1))) && date.isBefore(_currentRange.end.add(const Duration(days: 1)));
    })
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
          title: cat.libelle,
          radius: 60,
        ));
      }
    }

    if (sections.isEmpty) {
      return const Center(child: Text("Aucune dépense enregistrée"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Dépenses par catégorie", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
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
        const SizedBox(height: 12),
        ...sections.map((s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 10),
              const SizedBox(width: 6),
              Text(s.title ?? ''),
              const Spacer(),
              Text('${s.value.toStringAsFixed(0)} F CFA'),
            ],
          ),
        )),
      ],
    );
  }

  Widget buildBarChart() {
    List<BarChartGroupData> barGroups = [];
    List<String> labels = [];

    for (int i = 0; i < _budgets.length; i++) {
      final budget = _budgets[i];
      double totalDep = getTotalDepenseParCategorie(budget.categorieId);
      labels.add(_categories.firstWhere(
              (c) => c.id == budget.categorieId,
          orElse: () => Categorie(id: 0, libelle: "Inconnu"))
          .libelle);

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Dépenses vs Budgets", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(reservedSize: 42, showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, meta) {
                      if (value.toInt() >= labels.length) return const SizedBox.shrink();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
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
        actions: [
          DropdownButton<String>(
            value: _selectedPeriod,
            onChanged: (val) => _updatePeriod(val!),
            items: _periodOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            dropdownColor: Colors.indigo,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPieChart(),
            const SizedBox(height: 30),
            buildBarChart(),
          ],
        ),
      ),
    );
  }
}
