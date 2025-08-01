import 'package:flutter/material.dart';
import '../../BaseScaffold.dart';
import '../../Core/Models/UserModel.dart';
import '../../Services/UserService.dart';
import '../../constants.dart';
import 'client_details_page.dart';

class CustomersListPage extends StatefulWidget {
  const CustomersListPage({super.key});

  @override
  State<CustomersListPage> createState() => _CustomersListPageState();
}

class _CustomersListPageState extends State<CustomersListPage> {
  final UserService _userService = UserService();
  bool _isLoading = false;
  String? _errorMessage;
  List<UserModel> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer tous les utilisateurs
      final allUsers = await _userService.getAllUsers();
      
      // Filtrer pour ne garder que les clients
      setState(() {
        _clients = allUsers.where((user) => user.role?.toLowerCase() == 'client').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des clients: $e';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Liste des Clients',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _loadClients,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.vertMenthe,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                      onPressed: _loadClients,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            else if (_clients.isEmpty)
              const Center(child: Text('Aucun client disponible'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _clients.length,
                  itemBuilder: (context, index) {
                    final client = _clients[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.primaries[index % Colors.primaries.length],
                          child: Text(
                            client.name?.isNotEmpty == true ? client.name![0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(client.name?.toString() ?? 'Client sans nom'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (client.email != null && client.email!.isNotEmpty)
                              Text('Email: ${client.email}'),
                            if (client.numeroTelephone != null && client.numeroTelephone!.isNotEmpty)
                              Text('Téléphone: ${client.numeroTelephone}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Implémenter la modification du client
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Implémenter la suppression du client
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // Naviguer vers la page de détails du client
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ClientDetailsPage(client: client),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
