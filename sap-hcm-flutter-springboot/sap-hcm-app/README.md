# Application RH — SAP HCM

Application académique/professionnelle full-stack simulant une application RH connectable à SAP HCM via SAP Business Accelerator Hub. Le projet contient un backend Spring Boot sécurisé par JWT, une application Flutter responsive, des scripts SQL, une collection Postman et une documentation de démonstration jury.

## Contenu

```text
sap-hcm-app/
├── backend-springboot/      # API REST Spring Boot, JWT, JPA, données mockées
├── frontend-flutter/        # Interface Flutter responsive avec 12 modules RH
├── database/                # schema.sql et data.sql indicatifs
├── documentation/           # Architecture, installation, endpoints et scénario jury
└── README.md
```

## Technologies

- Backend: Java 17, Spring Boot, Spring Web, Spring Security, JWT, Spring Data JPA, Validation, Lombok.
- Base: mode démo H2 en mémoire, compatible PostgreSQL/MySQL via variables d'environnement.
- Frontend: Flutter, Dio, Flutter Secure Storage, Provider, go_router, fl_chart, intl.
- Sécurité: JWT obligatoire, BCrypt, autorisations par rôle.

## Lancer le backend

```bash
cd backend-springboot
mvn spring-boot:run
```

Par défaut, l'API démarre sur `http://localhost:8080/api` avec une base H2 mémoire pour garantir une démonstration stable. Pour PostgreSQL:

```bash
cd backend-springboot
DB_URL=jdbc:postgresql://localhost:5432/saphcm \
DB_DRIVER=org.postgresql.Driver \
DB_USERNAME=postgres \
DB_PASSWORD=postgres \
mvn spring-boot:run
```

## Lancer le frontend

```bash
cd frontend-flutter
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

Sur mobile Android Emulator, remplacer l'URL par `http://10.0.2.2:8080/api`.

## Comptes de test

| Rôle | Email | Mot de passe |
|---|---|---|
| EMPLOYEE | employee@test.com | password |
| MANAGER | manager@test.com | password |
| HR | hr@test.com | password |
| ADMIN | admin@test.com | password |

## Modules disponibles

1. Login / Connexion
2. Profil Employé
3. Gestion des Congés
4. Pointage / Présences
5. Dashboard RH
6. Gestion de la Paie
7. Recrutement
8. Administration RH
9. Évaluation des Performances
10. Suivi des Formations
11. Organigramme
12. Rapports RH / Export

## Endpoints principaux

- `POST /api/auth/login`
- `GET /api/auth/me`
- `GET /api/employees/me`
- `GET /api/leaves`, `POST /api/leaves`, `PUT /api/leaves/{id}/approve`
- `POST /api/attendance/check-in`, `POST /api/attendance/check-out`
- `GET /api/dashboard/stats`
- `GET /api/payroll/my`
- `GET /api/jobs`, `GET /api/candidates`
- `GET /api/trainings`, `GET /api/organization/tree`
- `GET /api/reports/leaves`

## Scénario de démonstration rapide

1. Se connecter avec `employee@test.com`.
2. Consulter le profil et modifier téléphone/adresse.
3. Créer une demande de congé.
4. Pointer entrée puis sortie.
5. Consulter les fiches de paie.
6. Se connecter avec `manager@test.com` et valider/refuser un congé de l'équipe.
7. Se connecter avec `hr@test.com` et consulter dashboard, recrutement, formations et rapports.
8. Se connecter avec `admin@test.com` et gérer les utilisateurs.

## SAP Business Accelerator Hub

Le backend expose une couche d'abstraction prête pour SAP:

- `SapEmployeeService` / `MockSapEmployeeService`
- `SapLeaveService` / `MockSapLeaveService`
- `SapPayrollService` / `MockSapPayrollService`
- `SapAttendanceService` / `MockSapAttendanceService`

La phrase de présentation recommandée est: “L’application est prête pour l’intégration SAP, mais utilise actuellement des données simulées pour garantir une démonstration stable.”
