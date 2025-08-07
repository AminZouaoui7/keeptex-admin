import 'package:dio/dio.dart';
import '../Core/Models/CommandeModel.dart';
import '../Core/utils/cacheHelper.dart';

class CommandeService {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://192.168.1.128:5000/api')); // Remplace par ton IP si besoin

  Future<Options> _getAuthHeaders() async {
    final token = await CacheHelper().getData(key: "token");
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  Future<void> marquerAcompteCommePaye(String commandeId) async {
    final token = await CacheHelper().getData(key: "token");

    final response = await dio.put(
      '/commandes/$commandeId/acomptepaye',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );

    print("✅ Acompte payé : ${response.data}");
  }


  Future<List<CommandeModel>> getAllCommandes() async {
    final options = await _getAuthHeaders();
    final response = await dio.get('/commandes', options: options);
    final data = response.data;

    print('DEBUG: Response data from /commandes: $data');

    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).map((json) => CommandeModel.fromJson(json)).toList();
    } else if (data is List) {
      return data.map((json) => CommandeModel.fromJson(json)).toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  Future<CommandeModel> getCommandeById(String id) async {
    final options = await _getAuthHeaders();
    final response = await dio.get('/commandes/$id', options: options);
    final data = response.data;

    final commandeData = data['data'] ?? data; // très important
    print("✅ Commande reçue : $commandeData");

    return CommandeModel.fromJson(commandeData);
  }

  Future<void> createCommande(CommandeModel commande) async {
    final options = await _getAuthHeaders();
    await dio.post('/commandes', data: commande.toJson(), options: options);
  }


  Future<void> deleteCommande(String id) async {
    final options = await _getAuthHeaders();
    await dio.delete('/commandes/$id', options: options);
  }

  Future<void> updateEtatCommande(String id, String newEtat) async {
    final options = await _getAuthHeaders();

    try {
      final response = await dio.put(
        '/commandes/$id/etat',
        data: {'etat': newEtat},
        options: options,
      );

      print("✅ État mis à jour: ${response.data}");
    } on DioException catch (e) {
      print("❌ Erreur updateEtatCommande: ${e.response?.data}");
      throw Exception('Échec de la mise à jour de l’état: ${e.response?.data}');
    }
  }


  Future<List<CommandeModel>> getCommandesByUser(String userId) async {
    final options = await _getAuthHeaders();
    final response = await dio.get('/commandes/user/$userId', options: options);

    final data = response.data;

    // Assure-toi que 'data' existe dans la réponse
    if (data is Map && data.containsKey('data')) {
      final commandesList = data['data'] as List;
      return commandesList.map((json) => CommandeModel.fromJson(json)).toList();
    } else {
      throw Exception('Unexpected response format: ${response.data}');
    }
  }
}
