import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../BaseScaffold.dart';
import '../../Core/Models/CommandeModel.dart';
import '../../Services/CommandeService.dart';
import '../../constants.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final CommandeService _commandeService = CommandeService();
  bool _isLoading = true;
  String? _errorMessage;
  CommandeModel? _order;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await _commandeService.getCommandeById(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des détails de la commande: $e';
        _isLoading = false;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Date non disponible';
    return DateFormat('dd/MM/yyyy – HH:mm').format(date);
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
                  'Détails de la Commande ${widget.orderId}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Contenu principal
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Expanded(
                child: Center(
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
                        onPressed: _loadOrderDetails,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_order == null)
              const Expanded(
                child: Center(child: Text('Commande non trouvée')),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 16),
                      _buildGeneralInfoCard(),
                      const SizedBox(height: 16),
                      _buildProductDetailsCard(),
                      const SizedBox(height: 16),
                      _buildFinancialInfoCard(),
                      if (_order!.description.isNotEmpty) ...[  
                        const SizedBox(height: 16),
                        _buildDescriptionCard(),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    // Déterminer la couleur en fonction de l'état de la commande
    Color statusColor;
    IconData statusIcon;
    
    switch (_order!.etat.toLowerCase()) {
      case 'en attente':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'termine':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'annulée':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.blue; // Pour les états en cours de traitement
        statusIcon = Icons.engineering;
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(statusIcon, size: 40, color: statusColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut de la commande',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _order!.etat,
                    style: TextStyle(fontSize: 20, color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (_order!.etat.toLowerCase() != 'termine' && _order!.etat.toLowerCase() != 'annulée')
              ElevatedButton(
                onPressed: () {
                  // Implémenter la mise à jour du statut
                  // Cette fonctionnalité pourrait être ajoutée ultérieurement
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.vertMenthe,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mettre à jour'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInfoCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations générales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.numbers, 'ID de commande', _order!.id.toString()),
            _buildInfoRow(Icons.calendar_today, 'Date de commande', formatDate(_order!.date)),
            _buildInfoRow(Icons.person_outline, 'Client', _order!.clientName ?? 'Non spécifié'),
            if (_order!.createdAt != null)
              _buildInfoRow(Icons.access_time, 'Créée le', formatDate(_order!.createdAt)),
            if (_order!.updatedAt != null)
              _buildInfoRow(Icons.update, 'Mise à jour le', formatDate(_order!.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails du produit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.category, 'Type', _order!.type ?? 'Non spécifié'),
            _buildInfoRow(Icons.design_services, 'Modèle', _order!.typeModele ?? 'Non spécifié'),
            _buildInfoRow(Icons.texture, 'Tissu', _order!.typeTissue ?? 'Non spécifié'),
            _buildInfoRow(Icons.color_lens, 'Couleur', _order!.couleur ?? 'Non spécifié'),
            _buildInfoRow(Icons.format_list_numbered, 'Quantité totale', _order!.quantiteTotale.toString()),
            if (_order!.logo != null && _order!.logo!.isNotEmpty)
              _buildInfoRow(Icons.image, 'Logo', 'Disponible'),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInfoCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations financières',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.euro, 
              'Prix total', 
              '${_order!.prixTotal.toStringAsFixed(2)} €'
            ),
            _buildInfoRow(
              Icons.payment, 
              'Acompte requis', 
              '${_order!.acompteRequis.toStringAsFixed(2)} €'
            ),
            _buildInfoRow(
              _order!.acomptePaye ? Icons.check_circle : Icons.cancel, 
              'Acompte payé', 
              _order!.acomptePaye ? 'Oui' : 'Non',
              valueColor: _order!.acomptePaye ? Colors.green : Colors.red,
            ),
            if (!_order!.acomptePaye)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await _commandeService.marquerAcompteCommePaye(_order!.id.toString());
                      _loadOrderDetails(); // Recharger les détails après la mise à jour
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Acompte marqué comme payé avec succès')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Marquer l\'acompte comme payé'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.vertMenthe,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(_order!.description),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}