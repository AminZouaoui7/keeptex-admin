import 'package:dio/dio.dart';
import '../Core/Models/UserModel.dart';
import '../Core/utils/cacheHelper.dart';
import '../Core/api/endpoints.dart';

class UserService {
  late final Dio dio;

  UserService() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://172.21.160.1:5000/api',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 15),
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
      // Récupérer le token d'authentification
      final token = await CacheHelper().getData(key: 'token');
      
      // Ajouter le token aux en-têtes de la requête
      final response = await dio.get(
        '/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      final data = response.data;
      print('DEBUG: Response data from /users: $data');
      
      if (data is Map && data.containsKey('data')) {
        // Vérifier si data['data'] est une liste
        if (data['data'] is List) {
          return (data['data'] as List).map((json) {
            // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
            if (json is Map) {
              final Map<String, dynamic> userMap = {};
              json.forEach((key, value) {
                userMap[key.toString()] = value;
              });
              return UserModel.fromJson(userMap);
            } else {
              throw Exception('Format de données utilisateur inattendu: ${json.runtimeType}');
            }
          }).toList();
        } else if (data['data'] is Map) {
          // Si data['data'] n'est pas une liste, créer une liste avec un seul élément
          final Map<String, dynamic> userMap = {};
          (data['data'] as Map).forEach((key, value) {
            userMap[key.toString()] = value;
          });
          return [UserModel.fromJson(userMap)];
        } else {
          throw Exception('Format de données inattendu pour data["data"]: ${data['data'].runtimeType}');
        }
      } else if (data is List) {
        return data.map((json) {
          // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
          if (json is Map) {
            final Map<String, dynamic> userMap = {};
            json.forEach((key, value) {
              userMap[key.toString()] = value;
            });
            return UserModel.fromJson(userMap);
          } else {
            throw Exception('Format de données utilisateur inattendu: ${json.runtimeType}');
          }
        }).toList();
      } else if (data is Map) {
        // Si la réponse est un objet unique, créer une liste avec un seul élément
        final Map<String, dynamic> userMap = {};
        data.forEach((key, value) {
          userMap[key.toString()] = value;
        });
        return [UserModel.fromJson(userMap)];
      } else {
        throw Exception('Format de réponse inattendu: ${data.runtimeType}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      rethrow;
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      // Récupérer le token d'authentification
      final token = await CacheHelper().getData(key: 'token');
      
      // Ajouter le token aux en-têtes de la requête
      final response = await dio.get(
        '/users/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      final data = response.data;
      print('DEBUG: Response data from /users/$id: $data');
      
      if (data is Map) {
        if (data.containsKey('data')) {
          // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
          final Map<String, dynamic> userData = {};
          (data['data'] as Map).forEach((key, value) {
            userData[key.toString()] = value;
          });
          return UserModel.fromJson(userData);
        } else {
          // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
          final Map<String, dynamic> userData = {};
          data.forEach((key, value) {
            userData[key.toString()] = value;
          });
          return UserModel.fromJson(userData);
        }
      } else {
        throw Exception('Format de réponse inattendu: ${data.runtimeType}');
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur $id: $e');
      rethrow;
    }
  }


  Future<void> createUser(UserModel user) async {
    try {
      // Récupérer le token d'authentification
      final token = await CacheHelper().getData(key: 'token');
      
      // Ajouter le token aux en-têtes de la requête
      await dio.post(
        '/users', 
        data: user.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur: $e');
      rethrow;
    }
  }

  Future<void> addEmployee(String name, {String? numeroTelephone, String? etat, double? salaireH, String? cin}) async {
    try {
      // Récupérer le token d'authentification
      final token = await CacheHelper().getData(key: 'token');
      
      // Générer un timestamp pour l'email et le mot de passe uniques
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Préparer les données pour l'API
      final Map<String, dynamic> data = {
        'name': name,
        // Champs générés automatiquement selon les spécifications
        'email': 'timestamp$timestamp@keeptemp.com', // Email temporaire unique
        'password': 'Keeptemp@123', // Mot de passe par défaut sécurisé
        'emailConfirmed': false, // Statut emailConfirmed défini à false
      };
      
      // Ajouter les champs optionnels s'ils sont fournis
      if (numeroTelephone != null) data['num'] = numeroTelephone;
      if (etat != null) data['etat'] = etat;
      if (salaireH != null) data['salaire_h'] = salaireH;
      if (cin != null) data['cin'] = cin;
      
      // Appeler le nouvel endpoint
      await dio.post(
        '/users/add-employee',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'employé: $e');
      rethrow;
    }
  }

  Future<void> updateUser(String id, UserModel user) async {
    try {
      // Récupérer le token d'authentification
      final token = await CacheHelper().getData(key: 'token');
      
      // Ajouter le token aux en-têtes de la requête
      await dio.put(
        '/users/$id', 
        data: user.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur $id: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      // Récupérer le token d'authentification
      final token = await CacheHelper().getData(key: 'token');
      
      // Ajouter le token aux en-têtes de la requête
      await dio.delete(
        '/users/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
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