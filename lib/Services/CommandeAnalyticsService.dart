import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../Core/Models/CommandeModel.dart';
import '../Services/CommandeService.dart';
import '../constants.dart';

class CommandeAnalyticsService {
  final CommandeService _commandeService = CommandeService();

  // Récupérer toutes les statistiques des commandes
  Future<Map<String, dynamic>> getCommandeAnalytics() async {
    try {
      final List<CommandeModel> commandes = await _commandeService.getAllCommandes();
      
      if (commandes.isEmpty) {
        return {
          'totalCommandes': 0,
          'commandesEnCours': 0,
          'commandesTerminees': 0,
          'commandesAnnulees': 0,
          'montantTotal': 0.0,
          'montantRestant': 0.0,
          'distributionEtats': <String, int>{},
        };
      }
      
      // Statistiques de base
      int totalCommandes = commandes.length;
      int commandesEnCours = 0;
      int commandesTerminees = 0;
      int commandesAnnulees = 0;
      double montantTotal = 0.0;
      double montantRestant = 0.0;
      
      // Distribution par état
      Map<String, int> distributionEtats = {};
      
      // Commandes par mois
      Map<int, int> commandesParMois = {};
      Map<int, double> montantParMois = {};
      
      // Initialiser les mois (1-12)
      for (int i = 1; i <= 12; i++) {
        commandesParMois[i] = 0;
        montantParMois[i] = 0.0;
      }
      
      // Analyser chaque commande
      for (var commande in commandes) {
        // Calculer les statistiques par état
        String etat = commande.etat.toLowerCase();
        distributionEtats[etat] = (distributionEtats[etat] ?? 0) + 1;
        
        if (etat == 'en cours') {
          commandesEnCours++;
        } else if (etat == 'termine' || etat == 'terminé' || etat == 'terminée') {
          commandesTerminees++;
          // Normaliser l'état pour la distribution
          if (etat != 'termine') {
            distributionEtats['termine'] = (distributionEtats['termine'] ?? 0) + 1;
            distributionEtats.remove(etat);
          }
        } else if (etat == 'annulee' || etat == 'annulé' || etat == 'annulée') {
          commandesAnnulees++;
          // Normaliser l'état pour la distribution
          if (etat != 'annulee') {
            distributionEtats['annulee'] = (distributionEtats['annulee'] ?? 0) + 1;
            distributionEtats.remove(etat);
          }
        }
        
        // Calculer les montants
        montantTotal += commande.prixTotal;
        
        // Si la commande n'est pas terminée ou annulée, ajouter au montant restant
        if (!(etat == 'termine' || etat == 'terminé' || etat == 'terminée' || 
              etat == 'annulee' || etat == 'annulé' || etat == 'annulée')) {
          montantRestant += commande.prixTotal;
        }
        
        // Analyser par mois
        DateTime dateCommande = commande.date;
        int mois = dateCommande.month;
        
        commandesParMois[mois] = (commandesParMois[mois] ?? 0) + 1;
        montantParMois[mois] = (montantParMois[mois] ?? 0) + commande.prixTotal;
      }
      
      return {
        'totalCommandes': totalCommandes,
        'commandesEnCours': commandesEnCours,
        'commandesTerminees': commandesTerminees,
        'commandesAnnulees': commandesAnnulees,
        'montantTotal': montantTotal,
        'montantRestant': montantRestant,
        'distributionEtats': distributionEtats,
        'commandesParMois': commandesParMois,
        'montantParMois': montantParMois,
      };
    } catch (e) {
      print('Erreur lors de l\'analyse des commandes: $e');
      return {
        'totalCommandes': 0,
        'commandesEnCours': 0,
        'commandesTerminees': 0,
        'commandesAnnulees': 0,
        'montantTotal': 0.0,
        'montantRestant': 0.0,
        'distributionEtats': <String, int>{},
      };
    }
  }
  
  // Générer les données pour le graphique en camembert
  Future<List<PieChartSectionData>> getPieChartData() async {
    try {
      final analytics = await getCommandeAnalytics();
      final Map<String, int> distribution = analytics['distributionEtats'] ?? {};
      
      if (distribution.isEmpty) {
        return [];
      }
      
      final int totalCommandes = analytics['totalCommandes'];
      final List<PieChartSectionData> sections = [];
      
      // Couleurs pour les différents états
      final Map<String, Color> colors = {
        'en cours': Colors.blue,
        'termine': Colors.green,
        'terminé': Colors.green,
        'terminée': Colors.green,
        'annulee': Colors.red,
        'annulé': Colors.red,
        'annulée': Colors.red,
        'en attente': Colors.orange,
      };
      
      // Créer les sections du camembert
      distribution.forEach((etat, count) {
        final double percentage = (count / totalCommandes) * 100;
        final Color color = colors[etat] ?? Constants.vertMenthe;
        
        sections.add(
          PieChartSectionData(
            value: percentage,
            color: color,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 40,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        );
      });
      
      return sections;
    } catch (e) {
      print('Erreur lors de la génération des données du camembert: $e');
      return [];
    }
  }
  
  // Générer les légendes pour le graphique en camembert
  Future<List<Map<String, dynamic>>> getPieChartLegends() async {
    try {
      final analytics = await getCommandeAnalytics();
      final Map<String, int> distribution = analytics['distributionEtats'] ?? {};
      
      if (distribution.isEmpty) {
        return [];
      }
      
      final List<Map<String, dynamic>> legends = [];
      
      // Couleurs pour les différents états
      final Map<String, Color> colors = {
        'en cours': Colors.blue,
        'termine': Colors.green,
        'terminé': Colors.green,
        'terminée': Colors.green,
        'annulee': Colors.red,
        'annulé': Colors.red,
        'annulée': Colors.red,
        'en attente': Colors.orange,
      };
      
      // Créer les légendes
      distribution.forEach((etat, count) {
        final Color color = colors[etat] ?? Constants.vertMenthe;
        String label = etat.substring(0, 1).toUpperCase() + etat.substring(1);
        
        // Normaliser les labels pour l'affichage
        if (etat == 'terminé' || etat == 'terminée') {
          label = 'Terminé';
        } else if (etat == 'annulé' || etat == 'annulée') {
          label = 'Annulé';
        }
        
        legends.add({
          'label': label,
          'color': color,
        });
      });
      
      return legends;
    } catch (e) {
      print('Erreur lors de la génération des légendes: $e');
      return [];
    }
  }
  
  // Générer les données pour le graphique linéaire
  Future<List<FlSpot>> getLineChartData() async {
    try {
      final analytics = await getCommandeAnalytics();
      final Map<int, int> commandesParMois = analytics['commandesParMois'] ?? {};
      
      if (commandesParMois.isEmpty) {
        return [];
      }
      
      final List<FlSpot> spots = [];
      
      // Créer les points du graphique
      commandesParMois.forEach((mois, count) {
        spots.add(FlSpot(mois.toDouble() - 1, count.toDouble()));
      });
      
      // Trier les points par mois
      spots.sort((a, b) => a.x.compareTo(b.x));
      
      return spots;
    } catch (e) {
      print('Erreur lors de la génération des données du graphique linéaire: $e');
      return [];
    }
  }
  
  // Générer les données pour le graphique à barres
  Future<List<BarChartGroupData>> getBarChartData() async {
    try {
      final analytics = await getCommandeAnalytics();
      final Map<int, double> montantParMois = analytics['montantParMois'] ?? {};
      
      if (montantParMois.isEmpty) {
        return [];
      }
      
      final List<BarChartGroupData> barGroups = [];
      
      // Créer les barres du graphique
      montantParMois.forEach((mois, montant) {
        barGroups.add(
          BarChartGroupData(
            x: mois.toInt() - 1,
            barRods: [
              BarChartRodData(
                toY: montant,
                gradient: LinearGradient(
                  colors: [
                    Constants.bleuOcean,
                    Constants.vertMenthe,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 15,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        );
      });
      
      // Trier les barres par mois
      barGroups.sort((a, b) => a.x.compareTo(b.x));
      
      return barGroups;
    } catch (e) {
      print('Erreur lors de la génération des données du graphique à barres: $e');
      return [];
    }
  }
}