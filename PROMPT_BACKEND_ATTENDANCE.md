# 🎯 Prompt pour résoudre le backend - Marquage présent/absent

## 📌 Contexte
L'application Flutter renvoie une **erreur 500** avec le message "Erreur serveur lors de la création/mise à jour de la présence" lorsque vous tentez de marquer un employé comme présent ou absent.

## 🔍 Diagnostic
L'erreur provient du **backend manquant les routes d'attendance**. Le frontend envoie des requêtes POST à `/api/attendance` mais le backend ne possède pas ces endpoints.

## ✅ Solution complète - Actions à effectuer

### 1. 📁 Localiser votre backend
```bash
# Trouvez votre dossier backend (souvent à la racine ou dans backend/)
cd backend
# ou
cd ../keeptex-backend
```

### 2. 🆕 Créer le modèle Attendance
**Fichier : `models/Attendance.js`**
```javascript
const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Attendance = sequelize.define('Attendance', {
    employee_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'Users', key: 'id' }
    },
    date: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM('Présent', 'Absent', 'Congé', 'Non défini'),
      allowNull: false,
      defaultValue: 'Non défini'
    }
  }, {
    tableName: 'attendances',
    timestamps: true,
    underscored: true
  });

  Attendance.associate = (models) => {
    Attendance.belongsTo(models.User, { foreignKey: 'employee_id', as: 'employee' });
  };

  return Attendance;
};
```

### 3. 🛤️ Créer les routes d'attendance
**Fichier : `routes/attendance.js`**
```javascript
const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');

// POST /api/attendance - Créer/mettre à jour présence
router.post('/attendance', authenticateToken, async (req, res) => {
  try {
    const { employee_id, date, status } = req.body;
    
    if (!employee_id || !date || !status) {
      return res.status(400).json({ 
        success: false, 
        error: 'Champs requis manquants' 
      });
    }

    // Vérifier si l'employé existe
    const employee = await User.findByPk(employee_id);
    if (!employee) {
      return res.status(404).json({ 
        success: false, 
        error: 'Employé non trouvé' 
      });
    }

    // Créer ou mettre à jour
    const [attendance, created] = await Attendance.upsert({
      employee_id,
      date,
      status,
      updated_at: new Date()
    }, {
      where: { employee_id, date }
    });

    res.json({
      success: true,
      message: created ? 'Présence créée' : 'Présence mise à jour',
      data: attendance
    });
  } catch (error) {
    console.error('Erreur attendance:', error);
    res.status(500).json({
      success: false,
      error: 'Erreur serveur lors de la création/mise à jour de la présence'
    });
  }
});

// GET /api/attendance?date=YYYY-MM-DD
router.get('/attendance', authenticateToken, async (req, res) => {
  try {
    const { date } = req.query;
    
    const attendances = await Attendance.findAll({
      where: { date },
      include: [{ model: User, as: 'employee', attributes: ['id', 'name'] }]
    });

    res.json({ success: true, data: attendances });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Erreur serveur lors de la récupération des présences'
    });
  }
});

module.exports = router;
```

### 4. 🔄 Mettre à jour le serveur principal
**Fichier : `server.js` ou `app.js`**
```javascript
// Ajoutez ces lignes après vos autres imports
const attendanceRoutes = require('./routes/attendance');

// Ajoutez après vos autres app.use()
app.use('/api', attendanceRoutes);

// Assurez-vous que le modèle est bien importé
const Attendance = require('./models/Attendance')(sequelize);
```

### 5. 🗄️ Migration SQL (optionnel)
**Fichier : `migrations/create_attendances.sql`**
```sql
CREATE TABLE IF NOT EXISTS attendances (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  date DATE NOT NULL,
  status ENUM('Présent', 'Absent', 'Congé', 'Non défini') DEFAULT 'Non défini',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_employee_date (employee_id, date)
);
```

### 6. 🚀 Installation et test
```bash
# 1. Redémarrer le backend
npm install  # si nouvelles dépendances
npm start

# 2. Tester avec curl
curl -X POST http://localhost:5000/api/attendance \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_REAL_TOKEN" \
  -d '{"employee_id": 1, "date": "2024-01-15", "status": "Présent"}'

# 3. Vérifier la réponse
# Devrait retourner: {"success":true,"message":"Présence créée"}
```

### 7. 🧪 Vérification rapide
**Testez dans votre application Flutter :**
1. Ouvrez la page des employés
2. Sélectionnez une date
3. Essayez de marquer un employé comme "Présent"
4. L'erreur 500 devrait avoir disparu

## 🚨 Dépannage

### Si l'erreur persiste :
1. **Vérifiez les logs backend** : `tail -f logs/error.log`
2. **Testez l'endpoint** : `curl http://localhost:5000/api/attendance`
3. **Vérifiez la base de données** : Assurez-vous que la table `attendances` existe
4. **CORS** : Vérifiez que CORS est activé dans votre backend

### Commandes de debug :
```bash
# Vérifier que la route existe
curl -X OPTIONS http://localhost:5000/api/attendance

# Vérifier la base de données
mysql -u root -p -e "DESCRIBE attendances;"
```

## ✅ Checklist finale

- [ ] Backend redémarré avec succès
- [ ] Routes d'attendance ajoutées
- [ ] Modèle Attendance créé
- [ ] Table attendances en base de données
- [ ] Test avec curl réussi
- [ ] Application Flutter fonctionne sans erreur 500

Une fois ces étapes complétées, votre backend pourra correctement gérer le marquage présent/absent des employés depuis l'application Flutter.