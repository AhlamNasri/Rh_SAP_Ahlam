# Backend Spring Boot — Application RH SAP HCM

API REST sécurisée pour l'application RH SAP HCM.

## Démarrage

```bash
mvn spring-boot:run
```

API: `http://localhost:8080/api`

Mode démo: H2 mémoire avec données générées par `DataSeeder`.

## Variables utiles

```bash
SERVER_PORT=8080
JWT_SECRET=SAP_HCM_DEMO_SECRET_KEY_2026_CHANGE_ME_32_CHARS_MINIMUM
DB_URL=jdbc:postgresql://localhost:5432/saphcm
DB_DRIVER=org.postgresql.Driver
DB_USERNAME=postgres
DB_PASSWORD=postgres
JPA_DDL_AUTO=update
```

## Architecture

```text
com.example.saphcm
├── config       # SecurityConfig, DataSeeder
├── controller   # Endpoints REST
├── dto          # DTO d'entrée/sortie
├── entity       # Entités JPA
├── enums        # Enums métier
├── exception    # ApiException + ControllerAdvice
├── mapper       # DtoMapper
├── repository   # Spring Data JPA
├── security     # JWT, filtre, utilisateur courant
└── service      # Logique métier + abstraction SAP
```

## Sécurité

- `POST /api/auth/login` et `POST /api/auth/register` sont publics.
- Tous les autres endpoints exigent `Authorization: Bearer <token>`.
- Les mots de passe sont chiffrés avec BCrypt.
- Les rôles sont: EMPLOYEE, MANAGER, HR, ADMIN.

## Collection Postman

`postman/SAP_HCM_API_Collection.json`

Ordre conseillé: Login → Auth Me → Employees Me → Leaves → Attendance → Dashboard → Payroll → Recruitment → Training → Reports.
