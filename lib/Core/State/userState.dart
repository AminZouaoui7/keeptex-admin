

import '../Models/UserModel.dart';
import '../ViewModels/employee_card_vm.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserModel> users;
  UserLoaded(this.users);
}

class UserLoadedEnriched extends UserState {
  final List<UserModel> users; // raw users
  final List<EmployeeCardVM> employeesVM; // enriched for UI
  UserLoadedEnriched(this.users, this.employeesVM);
}

class SingleUserLoaded extends UserState {
  final UserModel user;
  SingleUserLoaded(this.user);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

class UserLoggedOut extends UserState {}
