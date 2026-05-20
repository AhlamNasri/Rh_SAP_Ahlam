# Architecture du projet

## Vue d'ensemble

L'application est organisée en deux couches principales:

- Frontend Flutter: interface responsive, gestion d'état Provider, navigation go_router, appels API Dio.
- Backend Spring Boot: API REST, logique métier RH, sécurité JWT, persistance JPA.

## Backend

Le backend suit l'architecture Controller / Service / Repository / DTO.

- Controller: expose les endpoints REST et applique les annotations de sécurité.
- Service: contient la logique métier: calcul des jours de congé, contrôle des soldes, règles de pointage, visibilité par rôle.
- Repository: accès aux données via Spring Data JPA.
- DTO: évite l'exposition directe des entités JPA.
- Mapper: conversion entités → DTO.
- Security: JWT, filtre d'authentification, service utilisateur courant.
- SAP abstraction: interfaces `SapEmployeeService`, `SapLeaveService`, `SapPayrollService`, `SapAttendanceService` pour remplacer les mocks par SAP Business Accelerator Hub.

## Frontend

Chaque module suit une structure feature-first:

```text
feature/
├── data/
│   ├── models
│   └── services
└── presentation/
    ├── pages
    └── widgets
```

Les appels API sont centralisés via `ApiClient`, qui injecte automatiquement le JWT dans les headers.

## Rôles

- EMPLOYEE: accès à ses données, demandes de congés, pointage, paie personnelle.
- MANAGER: équipe, validation/refus de congés, présences d'équipe, évaluations.
- HR: gestion RH complète, recrutement, paie, rapports, formations.
- ADMIN: accès complet et gestion des rôles.
