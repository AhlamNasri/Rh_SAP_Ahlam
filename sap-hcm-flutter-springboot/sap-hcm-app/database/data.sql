-- Donnees de demonstration indicatives.
-- En execution Spring Boot, les donnees sont creees par DataSeeder afin de produire des mots de passe BCrypt valides.

INSERT INTO roles(id, name) VALUES (1,'EMPLOYEE'), (2,'MANAGER'), (3,'HR'), (4,'ADMIN') ON CONFLICT DO NOTHING;
INSERT INTO departments(id, name, description) VALUES
  (1,'Direction','Pilotage global'),
  (2,'Ressources Humaines','Gestion RH, paie et formation'),
  (3,'IT','Solutions digitales et integration SAP'),
  (4,'Finance','Comptabilite et controle de gestion'),
  (5,'Operations','Production et support')
ON CONFLICT DO NOTHING;

-- Les utilisateurs de test sont disponibles au lancement: employee@test.com, manager@test.com, hr@test.com, admin@test.com / password.
-- Voir backend-springboot/src/main/java/com/example/saphcm/config/DataSeeder.java pour le dataset complet.
