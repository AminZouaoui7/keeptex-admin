import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Services/UserService.dart';
import '../Models/UserModel.dart';
import '../State/userState.dart';
import '../utils/cacheHelper.dart';


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
}
