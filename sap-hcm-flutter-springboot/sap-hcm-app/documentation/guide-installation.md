# Guide d'installation

## Prérequis

- Java 17+
- Maven 3.9+
- Flutter SDK 3.22+
- VS Code ou IntelliJ IDEA
- Optionnel: PostgreSQL ou MySQL

## Backend

```bash
cd backend-springboot
mvn spring-boot:run
```

L'API démarre sur `http://localhost:8080/api`.

### PostgreSQL optionnel

```bash
createdb saphcm
cd backend-springboot
DB_URL=jdbc:postgresql://localhost:5432/saphcm \
DB_DRIVER=org.postgresql.Driver \
DB_USERNAME=postgres \
DB_PASSWORD=postgres \
mvn spring-boot:run
```

## Frontend

```bash
cd frontend-flutter
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

## Postman

Importer:

`backend-springboot/postman/SAP_HCM_API_Collection.json`

1. Exécuter `Login EMPLOYEE`.
2. Copier le token retourné dans la variable `token`.
3. Tester les autres endpoints.
