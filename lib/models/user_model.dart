import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final DateTime createdAt;
  final int avatar;

  UserModel({
    required this.id,
    required this.username,
    required this.createdAt,
    this.avatar = 0,
  });

  // Map para Objeto
  factory UserModel.fromFiresstore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id, 
      username: data['username'] ?? "Jogador", 
      createdAt: data['createdAt'] != null
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
      avatar: data['avatar'] ?? 0
      );
  }

  //Objeto para Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'createdAt': Timestamp.fromDate(createdAt),
      'avatar': avatar
    };
  }

  UserModel copyWith({
    String? username,
    String? avatarUrl,
    int? level,
    int? experience,
  }) {
    return UserModel(
      id: id,
      createdAt: createdAt,
      username: username ?? this.username,
      avatar: avatar,
    );
  }
}