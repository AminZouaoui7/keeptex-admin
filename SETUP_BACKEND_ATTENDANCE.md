# Guide de configuration du backend pour les routes d'attendance

## 🚨 Problème identifié
L'erreur 500 "Erreur serveur lors de la création/mise à jour de la présence" indique que les endpoints d'attendance ne sont pas implémentés sur votre backend.

## ✅ Solution complète

### 1. Vérifier que le backend tourne
```bash
# Dans votre dossier backend
npm start
# ou
node server.js
```

### 2. Ajouter les routes nécessaires dans votre backend

#### Route POST /api/attendance
```javascript
// routes/attendance.js
const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');

// POST /api/attendance - Créer ou mettre à jour une présence
router.post('/attendance', authenticateToken, async (req, res) => {
  try {
    const { employee_id, date, status } = req.body;
    
    if (!employee_id || !date || !status) {
      return res.status(400).json({ 
        success: false, 
        error: 'Champs requis manquants: employee_id, date, status' 
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

    // Vérifier si une présence existe déjà pour cette date
    const existingAttendance = await Attendance.findOne({
      where: {
        employee_id: employee_id,
        date: date
      }
    });

    if (existingAttendance) {
      // Mettre à jour la présence existante
      await existingAttendance.update({
        status: status,
        updated_at: new Date()
      });
      
      return res.json({
        success: true,
        message: 'Présence mise à jour avec succès',
        data: existingAttendance
      });
    } else {
      // Créer une nouvelle présence
      const newAttendance = await Attendance.create({
        employee_id: employee_id,
        date: date,
        status: status,
        created_at: new Date(),
        updated_at: new Date()
      });
      
      return res.status(201).json({
        success: true,
        message: 'Présence créée avec succès',
        data: newAttendance
      });
    }
  } catch (error) {
    console.error('Erreur lors de la création/mise à jour de la présence:', error);
    return res.status(500).json({
      success: false,
      error: 'Erreur serveur lors de la création/mise à jour de la présence'
    });
  }
});

// GET /api/attendance - Récupérer les présences par date
router.get('/attendance', authenticateToken, async (req, res) => {
  try {
    const { date } = req.query;
    
    if (!date) {
      return res.status(400).json({ 
        success: false, 
        error: 'Paramètre date requis' 
      });
    }

    const attendances = await Attendance.findAll({
      where: { date: date },
      include: [
        {
          model: User,
          as: 'employee',
          attributes: ['id', 'name', 'email']
        }
      ],
      order: [['created_at', 'DESC']]
    });

    return res.json({
      success: true,
      data: attendances
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des présences:', error);
    return res.status(500).json({
      success: false,
      error: 'Erreur serveur lors de la récupération des présences'
    });
  }
});

// GET /users/:id/attendance - Historique de présence d'un employé
router.get('/users/:id/attendance', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { startDate, endDate } = req.query;
    
    let whereClause = { employee_id: id };
    
    if (startDate && endDate) {
      whereClause.date = {
        [Op.between]: [startDate, endDate]
      };
    }

    const attendances = await Attendance.findAll({
      where: whereClause,
      include: [
        {
          model: User,
          as: 'employee',
          attributes: ['id', 'name', 'email']
        }
      ],
      order: [['date', 'DESC']]
    });

    return res.json({
      success: true,
      data: attendances
    });
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'historique:', error);
    return res.status(500).json({
      success: false,
      error: 'Erreur serveur lors de la récupération de l\'historique'
    });
  }
});

module.exports = router;
```

### 3. Créer le modèle Attendance
```javascript
// models/Attendance.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Attendance = sequelize.define('Attendance', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  employee_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('Présent', 'Absent', 'Congé', 'Non défini'),
    allowNull: false,
    defaultValue: 'Non défini'
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  updated_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'attendances',
  timestamps: false,
  underscored: true
});

// Relations
Attendance.associate = (models) => {
  Attendance.belongsTo(models.User, {
    foreignKey: 'employee_id',
    as: 'employee'
  });
};

module.exports = Attendance;
```

### 4. Mettre à jour le fichier principal du serveur
```javascript
// server.js ou app.js
const attendanceRoutes = require('./routes/attendance');

// Ajouter après les autres imports
app.use('/api', attendanceRoutes);
```

### 5. Migration SQL pour créer la table
```sql
-- migrations/create_attendances_table.sql
CREATE TABLE IF NOT EXISTS attendances (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  date DATE NOT NULL,
  status ENUM('Présent', 'Absent', 'Congé', 'Non défini') NOT NULL DEFAULT 'Non défini',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_employee_date (employee_id, date)
);
```

### 6. Installation et test
```bash
# 1. Installer les dépendances si nécessaire
npm install

# 2. Redémarrer le backend
npm start

# 3. Tester les endpoints
curl -X POST http://localhost:5000/api/attendance \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"employee_id": 1, "date": "2024-01-15", "status": "Présent"}'
```

## 🔍 Dépannage rapide

### Vérifier les routes disponibles
```bash
curl http://localhost:5000/api/test
curl -X POST http://localhost:5000/api/attendance -H "Content-Type: application/json" -d '{"test": true}'
```

### Vérifier les logs du backend
```bash
# Dans le terminal du backend
tail -f logs/error.log
```

## ✅ Points de vérification

- [ ] La route POST /api/attendance existe
- [ ] La route GET /api/attendance existe  
- [ ] La table 'attendances' existe dans la base de données
- [ ] Le middleware d'authentification fonctionne
- [ ] Les données sont bien insérées/mises à jour

## 🎯 Après configuration

Une fois ces routes ajoutées et le backend redémarré, l'erreur 500 devrait disparaître et vous pourrez marquer les employés comme présents/absents depuis l'application Flutter.