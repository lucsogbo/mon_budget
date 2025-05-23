# 💸 Mon Budget - Application Flutter

Application mobile personnelle de gestion de budget et de dépenses, développée avec Flutter et SQLite.

---

## 🚀 Fonctionnalités principales

- 📊 **Dashboard graphique** (camembert et barres) des dépenses par catégorie et budget
- 🧾 **Dépenses** : ajout, affichage, suppression, filtre par période
- 💰 **Revenus** : saisie, consultation, filtre par période
- 🎯 **Budgets** : création, affectation à des catégories, visualisation
- 🗂 **Catégories** : gestion simple avec suppression conditionnelle (pas utilisée ailleurs)
- 🧮 **Calcul automatique** du solde courant
- 📆 **Filtrage dynamique** (Mensuel, Hebdomadaire, Trimestriel, Annuel)
- 📦 Données locales persistantes via SQLite
- ✅ Compatible Android et Windows (via sqflite_common_ffi)

---

## 🗂 Structure du projet

```bash
mon_budget/
├── lib/
│   ├── db/                # Base de données SQLite
│   ├── model/             # Modèles de données : Budget, Depense, Revenu, Categorie
│   ├── service/           # Services métier SQLite
│   ├── view/              # Écrans UI (Dashboard, Dépenses, Revenus, etc.)
│   └── main.dart          # Entrée principale
```

---

## 📦 Dépendances principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.2.8+4
  sqflite_common_ffi: ^2.3.0 # pour support Windows/macOS
  path: ^1.8.3
  path_provider: ^2.1.2
  intl: ^0.18.1
  fl_chart: ^0.64.0
```

---

## ⚙️ Lancer l'application

```bash
flutter pub get
flutter run
```

✅ Pour lancer sur Windows :  
Assurez-vous d’utiliser `sqflite_common_ffi` dans `main.dart`.

✅ Pour Android :  
Aucun changement requis. Le fichier `DatabaseHelper.dart` insère automatiquement des données de base.

---

## ❗ Problèmes fréquents

- **Base vide au démarrage ?**  
  Supprimez l’ancienne base ou augmentez la `version` dans `openDatabase(...)`.

- **Erreur sur Windows ?**  
  Assurez-vous d’avoir ajouté :
  ```dart
  if (Platform.isWindows || ...) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  ```

---

## 🔮 Améliorations futures possibles

- Export PDF / CSV
- Authentification utilisateur
- Sauvegarde cloud ou synchronisation
- Notifications automatiques

---

## 👨‍🎓 Projet académique
> ESGIS Bénin – Master 2 IRT  
> TP Flutter Mobile – 2024–2025  
> Auteur : [Groupe 4]
Membres
KAKPO	René
ACHAKA	Éric
SOGBO	Luc