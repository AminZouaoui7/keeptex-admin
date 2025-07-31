import 'package:dio/dio.dart';
import '../Core/Models/UserModel.dart';
import '../Core/utils/cacheHelper.dart';
import '../Core/api/endpoints.dart';

class UserService {
  late final Dio dio;

  UserService() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://192.168.1.128:5000/api',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
    ));

    // Ajouter des interceptors si nécessaire
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data == null) {
        throw Exception("Réponse vide du serveur");
      }

      final userData = response.data['user'];
      final token = response.data['token'];

      // Store token in CacheHelper
      if (token != null) {
        await CacheHelper().saveData(key: 'token', value: token);
      }

      if (userData == null) {
        // If user data is missing but token exists, create a minimal user with token
        if (token != null) {
          return UserModel(token: token, name: '', email: '', password: '', role: '', resetPasswordToken: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), numeroTelephone: '', etat: '', salaireH: 0, conge: 0, absence: 0, cin: '', accounte: 0);
        }
        return null;
      }

      final user = UserModel.fromJson(userData);
      return user.copyWith(token: token);
    } catch (e) {
      if (e is DioException && e.response != null) {
        // Extract error message from response data
        final errorMsg = e.response?.data['error'] ?? e.response?.data['message'] ?? 'Erreur inconnue';
        print('Erreur de connexion: $errorMsg');
        throw Exception(errorMsg);
      }
      throw Exception('Erreur de connexion: $e');
    }
  }


  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await dio.get('/users');
      return (response.data as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      rethrow;
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      final response = await dio.get('/users/$id');
      return UserModel.fromJson(response.data);
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur $id: $e');
      rethrow;
    }
  }


  Future<void> createUser(UserModel user) async {
    try {
      await dio.post('/users', data: user.toJson());
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur: $e');
      rethrow;
    }
  }

  Future<void> updateUser(String id, UserModel user) async {
    try {
      await dio.put('/users/$id', data: user.toJson());
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur $id: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await dio.delete('/users/$id');
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur $id: $e');
      rethrow;
    }
  }
  
  Future<UserModel?> register(UserModel user) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: user.toJson(),
      );

      if (response.data == null) {
        throw Exception("Réponse vide du serveur");
      }

      final userData = response.data['user'];
      final token = response.data['token'];

      // Store token in CacheHelper
      if (token != null) {
        await CacheHelper().saveData(key: 'token', value: token);
      }

      if (userData == null) {
        // If user data is missing but token exists, create a minimal user with token
        if (token != null) {
          return user.copyWith(token: token);
        }
        return null;
      }

      final registeredUser = UserModel.fromJson(userData);
      return registeredUser.copyWith(token: token);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorMsg = e.response?.data['error'] ?? e.response?.data['message'] ?? 'Erreur inconnue';
        print('Erreur lors de l\'inscription: $errorMsg');
        throw Exception(errorMsg);
      }
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }
}