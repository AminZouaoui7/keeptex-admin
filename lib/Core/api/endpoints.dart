class EndPoint {
  static const String baseUrl = "http://172.21.160.1:5000/api";

  // 🔐 Authentification
  static String register = "$baseUrl/auth/register";
  static String login = "$baseUrl/auth/login";
  static String me = "$baseUrl/auth/me";
  static String logout = "$baseUrl/auth/logout";

  // 👥 Utilisateurs
  static String users = "$baseUrl/users";
  static String getClients = "$baseUrl/users/clients";
  static String getEmployees = "$baseUrl/users/employees";
  static String getAdmins = "$baseUrl/users/admins";
  static String getUserById(String id) => "$baseUrl/users/$id";
  static String createUser = "$baseUrl/users";
  static String updateUser(String id) => "$baseUrl/users/$id";
  static String deleteUser(String id) => "$baseUrl/users/$id";
  static String changePassword(String id) => "$baseUrl/users/$id/password";

  // 🛍️ Produits
  static String products = "$baseUrl/products";
  static String featuredProducts = "$baseUrl/products/featured";
  static String getProductById(String id) => "$baseUrl/products/$id";
  static String createProduct = "$baseUrl/products";
  static String updateProduct(String id) => "$baseUrl/products/$id";
  static String deleteProduct(String id) => "$baseUrl/products/$id";

  // 🧵 Services
  static String services = "$baseUrl/services";
  static String getServiceById(String id) => "$baseUrl/services/$id";
  static String createService = "$baseUrl/services";
  static String updateService(String id) => "$baseUrl/services/$id";
  static String deleteService(String id) => "$baseUrl/services/$id";

  // ✉️ Contact
  static String contact = "$baseUrl/contact";
  static String getContactById(String id) => "$baseUrl/contact/$id";
  static String markContactAsRead(String id) => "$baseUrl/contact/$id/read";
  static String deleteContact(String id) => "$baseUrl/contact/$id";

  // 📦 Commandes
  static String commandes = "$baseUrl/commandes";
  static String getCommandeById(String id) => "$baseUrl/commandes/$id";
  static String getUserCommandes(String userId) => "$baseUrl/commandes/user/$userId";
  static String createCommande = "$baseUrl/commandes";
  static String updateCommande(String id) => "$baseUrl/commandes/$id";
  static String deleteCommande(String id) => "$baseUrl/commandes/$id";

  // 🗣️ Feedback
  static String feedbacks = "$baseUrl/feedbacks";
  static String getFeedbackById(String id) => "$baseUrl/feedbacks/$id";
  static String getUserFeedbacks(String userId) => "$baseUrl/feedbacks/user/$userId";
  static String createFeedback = "$baseUrl/feedbacks";
  static String updateFeedback(String id) => "$baseUrl/feedbacks/$id";
  static String deleteFeedback(String id) => "$baseUrl/feedbacks/$id";

  // 🖼️ Upload
  static String uploadImage = "$baseUrl/upload";
  static String uploadMultiple = "$baseUrl/upload/multiple";

  // 📅 Attendance & Pointage
  static String markPresent(String userId) => "$baseUrl/users/$userId/mark-present";
  static String markAbsent(String userId) => "$baseUrl/users/$userId/mark-absent";
  static String addAdvance(String userId) => "$baseUrl/users/$userId/add-advance";
  static String getAttendanceHistory(String userId) => "$baseUrl/users/$userId/attendance";
  static String getAttendanceStats(String userId) => "$baseUrl/users/$userId/attendance-stats";
}

class ApiKey {
  static const String id = "id";
  static const String name = "name";
  static const String email = "email";
  static const String password = "password";
  static const String role = "role";
  static const String resetPasswordToken = "resetpasswordToken";
  static const String createdAt = "createdat";
  static const String updatedAt = "updatedat";
  static const String numeroTelephone = "num";
  static const String etat = "etat";
  static const String salaireH = "salaire_h";
  static const String conge = "conge";
  static const String absence = "absence";
  static const String cin = "cin";
  static const String accounte = "accounte";
}

