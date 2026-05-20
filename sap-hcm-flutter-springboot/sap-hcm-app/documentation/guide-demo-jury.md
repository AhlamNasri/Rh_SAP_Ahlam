# Guide de démonstration devant jury

## Pitch court

Cette application RH simule une intégration SAP HCM. Le backend utilise actuellement des données mockées pour assurer une démonstration stable, mais l'architecture contient déjà une couche `Sap*Service` qui permet de remplacer les mocks par des appels SAP Business Accelerator Hub.

## Scénario conseillé

### 1. Connexion employé

- Email: `employee@test.com`
- Mot de passe: `password`

Montrer:

- Dashboard.
- Profil employé.
- Modification téléphone/adresse.
- Demande de congé.
- Pointage entrée/sortie.
- Fiche de paie personnelle.
- Formations et évaluations personnelles.

### 2. Connexion manager

- Email: `manager@test.com`
- Mot de passe: `password`

Montrer:

- Demandes de congés de l'équipe.
- Approbation/refus.
- Présences de l'équipe.
- Évaluation d'un employé.

### 3. Connexion RH

- Email: `hr@test.com`
- Mot de passe: `password`

Montrer:

- Dashboard RH.
- Liste des employés.
- Paie globale.
- Recrutement.
- Formation.
- Rapports RH avec export PDF/Excel simulé.

### 4. Connexion Admin

- Email: `admin@test.com`
- Mot de passe: `password`

Montrer:

- Administration utilisateurs.
- Changement de statut.
- Accès global.

## Points techniques à valoriser

- JWT et Spring Security.
- BCrypt.
- DTO et séparation Controller/Service/Repository.
- Règles métier réelles: solde congé, pointage unique par jour, confidentialité paie.
- UI responsive Flutter.
- Préparation SAP Business Accelerator Hub.
