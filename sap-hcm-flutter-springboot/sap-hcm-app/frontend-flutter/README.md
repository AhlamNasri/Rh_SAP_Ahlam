# Frontend Flutter — Application RH SAP HCM

Interface moderne, responsive et professionnelle pour consommer l'API Spring Boot.

## Démarrage

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
```

## Architecture

```text
lib/
├── core/
│   ├── constants
│   ├── theme
│   ├── routes
│   ├── network
│   ├── storage
│   └── widgets
└── features/
    ├── auth
    ├── dashboard
    ├── profile
    ├── leaves
    ├── attendance
    ├── payroll
    ├── recruitment
    ├── admin
    ├── performance
    ├── training
    ├── organization
    └── reports
```

## Fonctionnalités UI

- Authentification JWT.
- Stockage sécurisé du token avec Flutter Secure Storage.
- Navigation go_router.
- Gestion des rôles dans le drawer.
- Widgets réutilisables: boutons, champs, cartes, badges, tableaux, états loading/erreur/vide.
- Graphiques dashboard avec fl_chart.
- Workflows concrets: congé, validation, pointage, paie, recrutement, formation, évaluation, rapports.
