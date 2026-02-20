import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveProfile(UserProfile userProfile) async {
    try {
      String docId = userProfile.id.isNotEmpty ? userProfile.id : 'test_user_123';

      // ⚡ ADDED TIMEOUT: Stop hanging after 5 seconds and throw an error
      await _firestore
          .collection('users')
          .doc(docId)
          .set(userProfile.toJson())
          .timeout(const Duration(seconds: 5));
          
      print("✅ Profile successfully saved to Firestore with ID: $docId");
    } catch (e) {
      throw Exception('Database Error: $e'); // This will now show up in the SnackBar!
    }
  }
}