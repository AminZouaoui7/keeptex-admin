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

  final BoxDecoration cardStyle = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Commande #${widget.orderId}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0f3460),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(12),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildCard(_buildGeneralInfoCard()),
                          _buildCard(_buildProductDetailsCard()),
                          _buildCard(_buildFinancialInfoCard()),
                          if (_order!.description.isNotEmpty)
                            _buildCard(_buildDescriptionCard()),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      decoration: cardStyle,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      child: child,
    );
  }

  Widget _buildGeneralInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations générales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.numbers, 'ID de commande', _order!.id.toString()),
        _buildInfoRow(Icons.calendar_today, 'Date de commande', formatDate(_order!.date)),
        _buildInfoRow(Icons.person_outline, 'Client', _order!.clientName ?? 'Non spécifié'),
        if (_order!.createdAt != null)
          _buildInfoRow(Icons.access_time, 'Créée le', formatDate(_order!.createdAt)),
        if (_order!.updatedAt != null)
          _buildInfoRow(Icons.update, 'Mise à jour le', formatDate(_order!.updatedAt)),
      ],
    );
  }

  Widget _buildProductDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Détails du produit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.category, 'Type', _order!.type),
        _buildInfoRow(Icons.design_services, 'Modèle', _order!.typeModele),
        _buildInfoRow(Icons.texture, 'Tissu', _order!.typeTissue),
        _buildInfoRow(Icons.color_lens, 'Couleur', _order!.couleur,
          suffix: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _order!.couleur.startsWith('#')
                  ? Color(int.parse('0xFF${_order!.couleur.substring(1)}'))
                  : Colors.grey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
        ),
        _buildInfoRow(Icons.format_list_numbered, 'Quantité totale', _order!.quantiteTotale.toString()),
        if (_order!.logo.isNotEmpty)
          _buildInfoRow(Icons.image, 'Logo', 'Disponible'),
        const SizedBox(height: 16),
        if (_order!.tailles.isNotEmpty) ...[
          const Text('Tailles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._order!.tailles.map((taille) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 18, color: Colors.indigo),
                const SizedBox(width: 8),
                Text('${taille.taille} - ${taille.quantite} pièces'),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildFinancialInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations financières', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.euro, 'Prix total', '${_order!.prixTotal.toStringAsFixed(2)} €'),
        _buildInfoRow(Icons.payment, 'Acompte requis', '${_order!.acompteRequis.toStringAsFixed(2)} €'),
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
                  _loadOrderDetails();
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
    );
  }

  Widget _buildDescriptionCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(_order!.description),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor, Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
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
          if (suffix != null) ...[  
            const SizedBox(width: 8),
            suffix,
          ],
        ],
      ),
    );
  }
}