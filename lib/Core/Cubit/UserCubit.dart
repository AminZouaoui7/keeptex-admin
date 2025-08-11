import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../Services/UserService.dart';
import '../../Services/AttendanceService.dart';
import '../Models/UserModel.dart';
import '../State/userState.dart';
import '../utils/cacheHelper.dart';
import '../ViewModels/employee_card_vm.dart';


class UserCubit extends Cubit<UserState> {
  final UserService userService;

  UserCubit(this.userService) : super(UserInitial());

  Future<void> fetchUsers() async {
    emit(UserLoading());
    try {
      final users = await userService.getAllUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError("Erreur lors du chargement des utilisateurs : $e"));
    }
  }

  /// 🔎 Charger un utilisateur par ID
  Future<void> fetchUserById(String id) async {
    emit(UserLoading());
    try {
      final user = await userService.getUserById(id);
      emit(SingleUserLoaded(user));
    } catch (e) {
      emit(UserError("Erreur lors du chargement de l'utilisateur : $e"));
    }
  }

  /// ➕ Ajouter un utilisateur
  Future<void> createUser(UserModel user) async {
    emit(UserLoading());
    try {
      await userService.createUser(user);
      await fetchUsers(); // rechargement
    } catch (e) {
      emit(UserError("Erreur lors de la création : $e"));
    }
  }
  
  /// ➕ Ajouter un employé
  Future<void> addEmployee(String name, {String? numeroTelephone, String? etat, double? salaireH, String? cin}) async {
    emit(UserLoading());
    try {
      await userService.addEmployee(name, numeroTelephone: numeroTelephone, etat: etat, salaireH: salaireH, cin: cin);
      await fetchUsers(); // rechargement
    } catch (e) {
      emit(UserError("Erreur lors de l'ajout de l'employé : $e"));
    }
  }

  /// ✏️ Modifier un utilisateur
  Future<void> updateUser(String id, UserModel user) async {
    emit(UserLoading());
    try {
      await userService.updateUser(id, user);
      await fetchUsers(); // rechargement
    } catch (e) {
      emit(UserError("Erreur lors de la modification : $e"));
    }
  }

  /// ❌ Supprimer un utilisateur
  Future<void> deleteUser(String id) async {
    emit(UserLoading());
    try {
      await userService.deleteUser(id);
      await fetchUsers(); // rechargement
    } catch (e) {
      emit(UserError("Erreur lors de la suppression : \$e"));
    }
  }

  /// 🚪 Déconnexion de l'utilisateur
  Future<void> logout() async {
    // Effacer le token d'authentification
    await CacheHelper().removeData(key: 'token');
    emit(UserLoggedOut());
  }

  /// 📊 Charger les employés avec leurs statistiques mensuelles
  Future<void> fetchUsersWithStats([String? yyyymm]) async {
    emit(UserLoading());
    try {
      final now = DateTime.now();
      final month = yyyymm ?? '${now.year}-${now.month.toString().padLeft(2, '0')}';
      
      debugPrint('📊 Loading users with stats for month: $month');

      // 1) Charger tous les utilisateurs
      final allUsers = await userService.getAllUsers();
      final employees = allUsers.where((u) => u.role == 'employee').toList();
      debugPrint('📊 Found ${employees.length} employees');

      // 2) Charger les statistiques de présence mensuelle
      final attendanceService = AttendanceService();
      final statsMap = await attendanceService.getMonthlyStatsMap(month);
      debugPrint('📊 Loaded attendance stats for ${statsMap.length} users');

      // 3) Fusionner les données
      final enrichedEmployees = employees.map((user) {
        final stats = statsMap[user.id] ?? {};
        final present = stats['present'] ?? 0;
        final absent = stats['absent'] ?? 0;
        final conge = stats['conge'] ?? 0;
        final salaireH = (user.salaireH ?? 0).toDouble();
        final accounte = (user.accounte ?? 0).toDouble();

        return EmployeeCardVM(
          id: user.id ?? '',
          name: user.name ?? 'Inconnu',
          phone: user.numeroTelephone,
          cin: user.cin,
          salaireH: salaireH,
          presentDays: present,
          absentDays: absent,
          congeDays: conge,
          accounte: accounte,
          user: user,
        );
      }).toList();

      debugPrint('📊 Created ${enrichedEmployees.length} enriched employee cards');
      emit(UserLoadedEnriched(employees, enrichedEmployees));
    } catch (e) {
      debugPrint('❌ Error loading users with stats: $e');
      emit(UserError("Erreur lors du chargement des employés avec statistiques : $e"));
    }
  }
}
