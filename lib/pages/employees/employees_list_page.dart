import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../BaseScaffold.dart';
import '../../Core/Cubit/UserCubit.dart';
import '../../Core/Models/UserModel.dart';
import '../../Core/State/userState.dart';
import '../../Services/UserService.dart';
import '../../constants.dart';

class EmployeesListPage extends StatefulWidget {
  const EmployeesListPage({super.key});

  @override
  State<EmployeesListPage> createState() => _EmployeesListPageState();
}

class _EmployeesListPageState extends State<EmployeesListPage> {
  late final UserCubit _userCubit;
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour le formulaire
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _salaireController = TextEditingController();
  String _etatValue = 'Déclaré'; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    _userCubit = UserCubit(UserService());
    _loadEmployees();
  }

  @override
  void dispose() {
    // Libérer les contrôleurs
    _nameController.dispose();
    _phoneController.dispose();
    _cinController.dispose();
    _salaireController.dispose();
    _userCubit.close();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    // Appeler fetchUsers pour charger les données
    // La mise à jour de l'UI sera gérée par le BlocBuilder dans le widget build
    _userCubit.fetchUsers();
  }

  void _showAddEmployeeDialog() {
    // Réinitialiser les contrôleurs
    _nameController.clear();
    _phoneController.clear();
    _cinController.clear();
    _salaireController.clear();
    _etatValue = 'Déclaré';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ajouter un employé',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Constants.vertMenthe),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Remplissez les informations ci-dessous',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormField(
                      controller: _nameController,
                      label: 'Nom et prénom',
                      icon: Icons.person,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un nom' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _phoneController,
                      label: 'Numéro de téléphone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un numéro de téléphone' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      value: _etatValue,
                      label: 'État',
                      icon: Icons.work,
                      items: const [
                        DropdownMenuItem(value: 'Déclaré', child: Text('Déclaré')),
                        DropdownMenuItem(value: 'Non déclaré', child: Text('Non déclaré')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _etatValue = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _salaireController,
                      label: 'Salaire par heure',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un salaire' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _cinController,
                      label: 'CIN',
                      icon: Icons.badge,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un CIN' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Constants.bleuCanard),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Annuler', style: TextStyle(color: Constants.bleuCanard)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _addEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.bleuCanard,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Ajouter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Constants.bleuCanard),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Constants.bleuCanard, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
  
  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Constants.bleuCanard),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Constants.vertMenthe, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Future<void> _addEmployee() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Utiliser le nouvel endpoint pour ajouter un employé via le UserCubit
        await _userCubit.addEmployee(
          _nameController.text,
          numeroTelephone: _phoneController.text,
          etat: _etatValue,
          salaireH: double.tryParse(_salaireController.text) ?? 0.0,
          cin: _cinController.text,
        );
        
        Navigator.of(context).pop(); // Fermer le dialogue
        // Pas besoin d'appeler _loadEmployees() car le UserCubit émet déjà un nouvel état
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employé ajouté avec succès')),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Fermer le dialogue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showEditEmployeeDialog(UserModel employee) {
    // Initialiser les contrôleurs avec les valeurs actuelles
    _nameController.text = employee.name ?? '';
    _phoneController.text = employee.numeroTelephone ?? '';
    _cinController.text = employee.cin ?? '';
    _salaireController.text = (employee.salaireH ?? 0).toString();
    _etatValue = employee.etat ?? 'Déclaré';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modifier un employé',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Constants.bleuOcean),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Modifiez les informations ci-dessous',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormField(
                      controller: _nameController,
                      label: 'Nom et prénom',
                      icon: Icons.person,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un nom' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _phoneController,
                      label: 'Numéro de téléphone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un numéro de téléphone' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      value: _etatValue,
                      label: 'État',
                      icon: Icons.work,
                      items: const [
                        DropdownMenuItem(value: 'Déclaré', child: Text('Déclaré')),
                        DropdownMenuItem(value: 'Non déclaré', child: Text('Non déclaré')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _etatValue = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _salaireController,
                      label: 'Salaire par heure',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un salaire' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _cinController,
                      label: 'CIN',
                      icon: Icons.badge,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un CIN' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Constants.vertMenthe),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Annuler', style: TextStyle(color: Constants.vertMenthe)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _updateEmployee(employee),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.vertMenthe,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateEmployee(UserModel employee) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Créer un nouvel objet UserModel avec les valeurs mises à jour
        final updatedEmployee = UserModel(
          id: employee.id,
          name: _nameController.text,
          email: employee.email,
          password: employee.password,
          role: employee.role,
          resetPasswordToken: employee.resetPasswordToken,
          createdAt: employee.createdAt,
          updatedAt: DateTime.now(),
          numeroTelephone: _phoneController.text,
          etat: _etatValue,
          salaireH: double.tryParse(_salaireController.text) ?? 0.0,
          conge: employee.conge,
          absence: employee.absence,
          cin: _cinController.text,
          accounte: employee.accounte,
        );

        // Mettre à jour l'employé dans la base de données via le UserCubit
        await _userCubit.updateUser(employee.id!, updatedEmployee);
        Navigator.of(context).pop(); // Fermer le dialogue
        // Pas besoin d'appeler _loadEmployees() car le UserCubit émet déjà un nouvel état
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employé mis à jour avec succès')),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Fermer le dialogue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(UserModel employee) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Confirmer la suppression',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Êtes-vous sûr de vouloir supprimer l\'employé ${employee.name}?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Cette action est irréversible.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text('Annuler', style: TextStyle(color: Colors.grey[700])),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _deleteEmployee(employee),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteEmployee(UserModel employee) async {
    try {
      await _userCubit.deleteUser(employee.id!);
      Navigator.of(context).pop(); // Fermer le dialogue
      // Pas besoin d'appeler _loadEmployees() car le UserCubit émet déjà un nouvel état
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employé supprimé avec succès')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Fermer le dialogue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
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
            // En-tête avec titre et bouton d'ajout
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: Constants.vertMenthe.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Liste des employés',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Constants.bleuOcean),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gérez votre équipe efficacement',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEmployeeDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.vertMenthe,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<UserCubit, UserState>(
                bloc: _userCubit,
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Constants.vertMenthe),
                    );
                  } else if (state is UserError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('Erreur: ${state.message}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadEmployees,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.vertMenthe,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is UserLoaded) {
                    final employees = state.users.where((user) => user.role?.toLowerCase() == 'employee').toList();

                    if (employees.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun employé trouvé',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showAddEmployeeDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un employé'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.vertMenthe,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Grille de cartes moderne pour afficher les employés
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showEditEmployeeDialog(employee),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          employee.name ?? 'N/A',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Constants.bleuOcean),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: employee.etat == 'Déclaré' ? Constants.vertJade.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          employee.etat ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: employee.etat == 'Déclaré' ? Constants.vertJade : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 6),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              _infoRow(Icons.phone, employee.numeroTelephone ?? 'N/A'),
                                              _infoRow(Icons.badge, 'CIN: ${employee.cin ?? 'N/A'}'),
                                              _infoRow(Icons.attach_money, '${employee.salaireH ?? 0} DT/h'),

                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              _infoRow(Icons.account_balance_wallet, '${employee.accounte ?? 0} DT'),
                                              _infoRow(Icons.beach_access, 'Congé: ${employee.conge ?? 0} j'),
                                              _infoRow(Icons.access_time, 'Absence: ${employee.absence ?? 0} j'),
                                              _infoRow(Icons.attach_money, 'Accounte ${employee.accounte ?? 0}'),

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Constants.vertMenthe, size: 20),
                                        onPressed: () => _showEditEmployeeDialog(employee),
                                        tooltip: 'Modifier',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _showDeleteConfirmationDialog(employee),
                                        tooltip: 'Supprimer',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Chargement des données...'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Constants.bleuCanard),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
