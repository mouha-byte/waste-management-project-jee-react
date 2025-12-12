de plus de ça ajouter:
nombre de patient, nombre de medecin, nbre rendez vous aujoutd'hui,
nombre de consultation, liste des rendez vous aujourd'hui //ajouter les methode dnas le repository et aussi mettre a jour le controller et service pour l'affichage dans le dashboard
[]: # 
[]: # ## 📊 Statistiques et Dashboard
[]: # 
[]: # - Nombre total de patients
[]: # - Nombre total de médecins
[]: # - Nombre total de rendez-vous aujourd'hui
[]: # - Nombre total de consultations
[]: # - Liste des rendez-vous prévus pour aujourd'hui
[]: # 
[]: # Ces statistiques seront accessibles via un endpoint dédié et affichées sur une page de dashboard simple.
[]: # 
[]: # ---


# API RENDEZVOUS - Guide de Test Postman

## 🚀 Démarrage de l'Application

```cmd
.\mvnw.cmd spring-boot:run
```

**URL de base:** `http://localhost:8081`

**Console H2:** `http://localhost:8081/h2-console`
- JDBC URL: `jdbc:h2:mem:rendezvousdb`
- Username: `sa`
- Password: *(laisser vide)*

---

## 📋 ORDRE DE TEST RECOMMANDÉ

Pour tester correctement l'application, suivez cet ordre :

1. **Spécialités** (créer en premier)
2. **Médecins** (nécessitent des spécialités)
3. **Patients**
4. **Rendez-vous** (nécessitent médecins et patients)
5. **Consultations** (nécessitent des rendez-vous)

---

## 🏥 1. API SPÉCIALITÉS

### 1.1 Créer une Spécialité
```
POST http://localhost:8081/api/specialites
Content-Type: application/json

{
  "nomspecialite": "Cardiologie"
}
```

**Autres exemples à créer:**
```json
{"nomspecialite": "Dermatologie"}
{"nomspecialite": "Pédiatrie"}
{"nomspecialite": "Ophtalmologie"}
```

### 1.2 Lister toutes les Spécialités
```
GET http://localhost:8081/api/specialites
```

### 1.3 Obtenir une Spécialité par ID
```
GET http://localhost:8081/api/specialites/1
```

### 1.4 Modifier une Spécialité
```
PUT http://localhost:8081/api/specialites/1
Content-Type: application/json

{
  "nomspecialite": "Cardiologie Interventionnelle"
}
```

### 1.5 Supprimer une Spécialité
```
DELETE http://localhost:8081/api/specialites/1
```

---

## 👨‍⚕️ 2. API MÉDECINS

### 2.1 Créer un Médecin
```
POST http://localhost:8081/api/medecins
Content-Type: application/json

{
  "nom": "Dupont",
  "prenom": "Jean",
  "adr": "123 Rue de la Santé, Paris",
  "email": "jean.dupont@hopital.fr",
  "idspec": 1
}

```

**Autres exemples:**
```json
{
  "nom": "Martin",
  "prenom": "Sophie",
  "adr": "45 Avenue des Médecins, Lyon",
  "email": "sophie.martin@clinique.fr",
  "idspec": 2
}
```

```json
{
  "nom": "Benali",
  "prenom": "Ahmed",
  "adr": "78 Boulevard de l'Hôpital, Marseille",
  "email": "ahmed.benali@centre-medical.fr",
  "idspec": 1
}
```

### 2.2 Lister tous les Médecins
```
GET http://localhost:8081/api/medecins
```

### 2.3 Obtenir un Médecin par ID
```
GET http://localhost:8081/api/medecins/1
```

### 2.4 Obtenir les Médecins par Spécialité
```
GET http://localhost:8081/api/medecins/specialite/1
```

### 2.5 Modifier un Médecin
```
PUT http://localhost:8081/api/medecins/1
Content-Type: application/json

{
  "nom": "Dupont",
  "prenom": "Jean-Pierre",
  "adr": "123 Rue de la Santé, Paris",
  "email": "jp.dupont@hopital.fr",
  "idspec": 1
}
```

### 2.6 Supprimer un Médecin
```
DELETE http://localhost:8081/api/medecins/1
```

---

## 🧑‍🤝‍🧑 3. API PATIENTS

### 3.1 Créer un Patient
```
POST http://localhost:8081/api/patients
Content-Type: application/json

{
  "nompatient": "Dubois",
  "prenornpatient": "Marie",
  "emailpatient": "marie.dubois@email.fr"
}
```

**Autres exemples:**
```json
{
  "nompatient": "Bernard",
  "prenornpatient": "Pierre",
  "emailpatient": "pierre.bernard@email.fr"
}
```

```json
{
  "nompatient": "Petit",
  "prenornpatient": "Claire",
  "emailpatient": "claire.petit@email.fr"
}
```

### 3.2 Lister tous les Patients
```
GET http://localhost:8081/api/patients
```

### 3.3 Obtenir un Patient par ID
```
GET http://localhost:8081/api/patients/1
```

### 3.4 Obtenir un Patient par Email
```
GET http://localhost:8081/api/patients/email/marie.dubois@email.fr
```

### 3.5 Modifier un Patient
```
PUT http://localhost:8081/api/patients/1
Content-Type: application/json

{
  "nompatient": "Dubois-Martin",
  "prenornpatient": "Marie",
  "emailpatient": "marie.dubois@email.fr"
}
```

### 3.6 Supprimer un Patient
```
DELETE http://localhost:8081/api/patients/1
```

---

## 📅 4. API RENDEZ-VOUS

### 4.1 Créer un Rendez-vous
```
POST http://localhost:8081/api/rendezvous
Content-Type: application/json

{
  "daterdv": "2025-10-20",
  "heurerdv": "10:30:00",
  "medecinId": 1,
  "patientId": 1
}
```

**Autres exemples:**
```json
{
  "daterdv": "2025-10-21",
  "heurerdv": "14:00:00",
  "medecinId": 1,
  "patientId": 2
}
```

```json
{
  "daterdv": "2025-10-22",
  "heurerdv": "09:00:00",
  "medecinId": 2,
  "patientId": 1
}
```

### 4.2 Lister tous les Rendez-vous
```
GET http://localhost:8081/api/rendezvous
```

### 4.3 Obtenir un Rendez-vous par ID
```
GET http://localhost:8081/api/rendezvous/1
```

### 4.4 Obtenir les Rendez-vous d'un Médecin
```
GET http://localhost:8081/api/rendezvous/medecin/1
```

### 4.5 Obtenir les Rendez-vous d'un Patient
```
GET http://localhost:8081/api/rendezvous/patient/1
```

### 4.6 Obtenir les Rendez-vous par Date
```
GET http://localhost:8081/api/rendezvous/date/2025-10-20
```

### 4.7 Modifier un Rendez-vous
```
PUT http://localhost:8081/api/rendezvous/1
Content-Type: application/json

{
  "daterdv": "2025-10-20",
  "heurerdv": "11:00:00",
  "medecinId": 1,
  "patientId": 1
}
```

### 4.8 Supprimer un Rendez-vous
```
DELETE http://localhost:8081/api/rendezvous/1
```

---

## 📝 5. API CONSULTATIONS

### 5.1 Créer une Consultation
```
POST http://localhost:8081/api/consultations
Content-Type: application/json

{
  "datecons": "2025-10-20",
  "recapcons": "Consultation de routine. Patient en bonne santé. Tension artérielle normale. Aucun traitement nécessaire.",
  "idrdv": 1
}
```

**Autres exemples:**
```json
{
  "datecons": "2025-10-21",
  "recapcons": "Examen dermatologique. Prescription d'une crème pour traiter l'eczéma. Revoir dans 2 semaines.",
  "idrdv": 2
}
```

### 5.2 Lister toutes les Consultations
```
GET http://localhost:8081/api/consultations
```

### 5.3 Obtenir une Consultation par ID
```
GET http://localhost:8081/api/consultations/1
```

### 5.4 Obtenir la Consultation d'un Rendez-vous
```
GET http://localhost:8081/api/consultations/rendezvous/1
```

### 5.5 Modifier une Consultation
```
PUT http://localhost:8081/api/consultations/1
Content-Type: application/json

{
  "datecons": "2025-10-20",
  "recapcons": "Consultation de routine. Patient en bonne santé. Tension artérielle normale: 120/80. Aucun traitement nécessaire. Prochain contrôle dans 6 mois.",
  "idrdv": 1
}
```

### 5.6 Supprimer une Consultation
```
DELETE http://localhost:8081/api/consultations/1
```

---

## 🧪 SCÉNARIO DE TEST COMPLET

### Étape 1: Créer les données de base

**1.1 Créer des Spécialités**
```json
POST /api/specialites
{"nomspecialite": "Cardiologie"}

POST /api/specialites
{"nomspecialite": "Dermatologie"}
```

**1.2 Créer des Médecins**
```json
POST /api/medecins
{
  "nom": "Dupont",
  "prenom": "Jean",
  "adr": "123 Rue de la Santé, Paris",
  "email": "jean.dupont@hopital.fr",
  "idspec": 1
}

POST /api/medecins
{
  "nom": "Martin",
  "prenom": "Sophie",
  "adr": "45 Avenue des Médecins, Lyon",
  "email": "sophie.martin@clinique.fr",
  "idspec": 2
}
```

**1.3 Créer des Patients**
```json
POST /api/patients
{
  "nompatient": "Dubois",
  "prenornpatient": "Marie",
  "emailpatient": "marie.dubois@email.fr"
}

POST /api/patients
{
  "nompatient": "Bernard",
  "prenornpatient": "Pierre",
  "emailpatient": "pierre.bernard@email.fr"
}
```

### Étape 2: Créer des Rendez-vous

```json
POST /api/rendezvous
{
  "daterdv": "2025-10-20",
  "heurerdv": "10:30:00",
  "medecinId": 1,
  "patientId": 1
}

POST /api/rendezvous
{
  "daterdv": "2025-10-21",
  "heurerdv": "14:00:00",
  "medecinId": 2,
  "patientId": 2
}
```

### Étape 3: Créer des Consultations

```json
POST /api/consultations
{
  "datecons": "2025-10-20",
  "recapcons": "Consultation de routine. Patient en bonne santé.",
  "idrdv": 1
}

POST /api/consultations
{
  "datecons": "2025-10-21",
  "recapcons": "Examen dermatologique. Prescription d'une crème.",
  "idrdv": 2
}
```

### Étape 4: Tester les Lectures (GET)

```
GET /api/specialites
GET /api/medecins
GET /api/patients
GET /api/rendezvous
GET /api/consultations

GET /api/medecins/specialite/1
GET /api/rendezvous/medecin/1
GET /api/rendezvous/patient/1
GET /api/rendezvous/date/2025-10-20
GET /api/consultations/rendezvous/1
```

### Étape 5: Tester les Modifications (PUT)

```json
PUT /api/specialites/1
{"nomspecialite": "Cardiologie Interventionnelle"}

PUT /api/medecins/1
{
  "nom": "Dupont",
  "prenom": "Jean-Pierre",
  "adr": "123 Rue de la Santé, Paris",
  "email": "jp.dupont@hopital.fr",
  "idspec": 1
}
```

### Étape 6: Tester les Suppressions (DELETE)

```
DELETE /api/consultations/1
DELETE /api/rendezvous/1
DELETE /api/patients/1
DELETE /api/medecins/1
DELETE /api/specialites/1
```

---

## ⚠️ GESTION DES ERREURS

### Erreur 404 - Resource Not Found
```json
GET /api/medecins/999

Réponse:
{
  "timestamp": "2025-10-13T10:30:00",
  "status": 404,
  "error": "Not Found",
  "message": "Médecin non trouvé avec l'id : 999",
  "path": "/api/medecins/999"
}
```

### Erreur 500 - Données invalides
Si vous essayez de créer un médecin avec une spécialité inexistante:
```json
POST /api/medecins
{
  "nom": "Test",
  "prenom": "Test",
  "adr": "Test",
  "email": "test@test.fr",
  "idspec": 999
}

Réponse:
{
  "timestamp": "2025-10-13T10:30:00",
  "status": 404,
  "error": "Not Found",
  "message": "Spécialité non trouvée avec l'id : 999",
  "path": "/api/medecins"
}
```

---

## 📊 COLLECTION POSTMAN

### Importer dans Postman

1. Créez une nouvelle Collection "RendezVous API"
2. Ajoutez une variable d'environnement:
   - `baseUrl` = `http://localhost:8081`
3. Créez des dossiers pour chaque entité
4. Ajoutez les requêtes ci-dessus

### Variables d'Environnement Recommandées

```
baseUrl = http://localhost:8081
specialiteId = 1
medecinId = 1
patientId = 1
rendezvousId = 1
consultationId = 1
```

---

## ✅ CHECKLIST DE TEST

- [ ] **Spécialités**
  - [ ] Créer une spécialité
  - [ ] Lister toutes les spécialités
  - [ ] Obtenir une spécialité par ID
  - [ ] Modifier une spécialité
  - [ ] Supprimer une spécialité

- [ ] **Médecins**
  - [ ] Créer un médecin
  - [ ] Lister tous les médecins
  - [ ] Obtenir un médecin par ID
  - [ ] Obtenir les médecins par spécialité
  - [ ] Modifier un médecin
  - [ ] Supprimer un médecin

- [ ] **Patients**
  - [ ] Créer un patient
  - [ ] Lister tous les patients
  - [ ] Obtenir un patient par ID
  - [ ] Obtenir un patient par email
  - [ ] Modifier un patient
  - [ ] Supprimer un patient

- [ ] **Rendez-vous**
  - [ ] Créer un rendez-vous
  - [ ] Lister tous les rendez-vous
  - [ ] Obtenir un rendez-vous par ID
  - [ ] Obtenir les rendez-vous d'un médecin
  - [ ] Obtenir les rendez-vous d'un patient
  - [ ] Obtenir les rendez-vous par date
  - [ ] Modifier un rendez-vous
  - [ ] Supprimer un rendez-vous

- [ ] **Consultations**
  - [ ] Créer une consultation
  - [ ] Lister toutes les consultations
  - [ ] Obtenir une consultation par ID
  - [ ] Obtenir la consultation d'un rendez-vous
  - [ ] Modifier une consultation
  - [ ] Supprimer une consultation

---

## 🎯 RÉSULTATS ATTENDUS

Après avoir testé tous les endpoints, vous devriez avoir:

✅ **5 entités** fonctionnelles avec CRUD complet
✅ **30 endpoints API** testés et validés
✅ **Gestion des erreurs** fonctionnelle
✅ **Relations entre entités** correctes
✅ **Base de données H2** avec des données de test

---

## 📞 SUPPORT

En cas de problème:

1. Vérifiez que l'application est démarrée: `.\mvnw.cmd spring-boot:run`
2. Vérifiez les logs dans la console
3. Accédez à la console H2 pour vérifier les données
4. Assurez-vous que les IDs existent avant de faire des requêtes GET/PUT/DELETE

**Bon test ! 🚀**

