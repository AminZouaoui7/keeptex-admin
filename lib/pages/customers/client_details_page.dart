import 'package:flutter/material.dart';
import '../../BaseScaffold.dart';
import '../../Core/Models/UserModel.dart';
import '../../Core/Models/CommandeModel.dart';
import '../../Services/CommandeService.dart';
import '../../constants.dart';
import '../orders/order_details_page.dart';
class ClientDetailsPage extends StatefulWidget {
  final UserModel client;

  const ClientDetailsPage({super.key, required this.client});

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  final CommandeService _commandeService = CommandeService();
  bool _isLoading = false;
  String? _errorMessage;
  List<CommandeModel> _commandes = [];

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer toutes les commandes du client
      final commandes = await _commandeService.getCommandesByUser(widget.client.id!);
      
      setState(() {
        _commandes = commandes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des commandes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec bouton de retour
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Détails du Client',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Carte d'informations du client
            _buildClientInfoCard(),
            
            const SizedBox(height: 20),
            
            // En-tête de la section commandes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Commandes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _loadCommandes,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.vertMenthe,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Liste des commandes
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCommandes,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            else if (_commandes.isEmpty)
              const Center(child: Text('Aucune commande disponible pour ce client'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _commandes.length,
                  itemBuilder: (context, index) {
                    final commande = _commandes[index];
                    return _buildCommandeCard(commande);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar du client
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Text(
                    widget.client.name?.isNotEmpty == true ? widget.client.name![0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                
                // Informations du client
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.client.name?.toString() ?? 'Client sans nom',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (widget.client.email != null && widget.client.email!.isNotEmpty)
                        _buildInfoRow(Icons.email, widget.client.email!),
                      if (widget.client.numeroTelephone != null && widget.client.numeroTelephone!.isNotEmpty)
                        _buildInfoRow(Icons.phone, widget.client.numeroTelephone!),
                      if (widget.client.createdAt != null)
                        _buildInfoRow(Icons.calendar_today, 'Client depuis: ${_formatDate(widget.client.createdAt!)}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandeCard(CommandeModel commande) {
    // Déterminer la couleur en fonction de l'état de la commande
    Color statusColor;
    switch (commande.etat.toLowerCase()) {
      case 'en attente':
        statusColor = Colors.orange;
        break;
      case 'en cours':
        statusColor = Colors.blue;
        break;
      case 'terminée':
        statusColor = Colors.green;
        break;
      case 'annulée':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Naviguer vers les détails de la commande
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(orderId: commande.id!),
            ),
          ).then((_) => _loadCommandes()); // Recharger les commandes au retour
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la commande avec ID et date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commande #${commande.id}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatDate(commande.date),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Détails de la commande
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCommandeInfoRow('Type:', commande.type),
                        _buildCommandeInfoRow('Modèle:', commande.typeModele),
                        _buildCommandeInfoRow('Tissu:', commande.typeTissue),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCommandeInfoRow('Quantité:', '${commande.quantiteTotale}'),
                        _buildCommandeInfoRow('Prix:', '${commande.prixTotal.toStringAsFixed(2)} €'),
                        _buildCommandeInfoRow('Acompte:', commande.acomptePaye ? 'Payé' : 'Non payé'),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // État de la commande
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  commande.etat,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandeInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}