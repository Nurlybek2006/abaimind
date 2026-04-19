import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _chatRoomsRef => _firestore.collection('chat_rooms');

  Future<String> getOrCreateChatRoom({
    required String studentId,
    required String studentName,
  }) async {
    final existing = await _chatRoomsRef
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final room = ChatRoom(
      id: '',
      studentId: studentId,
      studentName: studentName,
    );
    final doc = await _chatRoomsRef.add(room.toMap());
    return doc.id;
  }

  Stream<List<ChatRoom>> getChatRoomsForCurator() {
    return _chatRoomsRef
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  ChatRoom.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
              .toList(),
        );
  }

  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _chatRoomsRef
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  ChatMessage.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> sendMessage(ChatMessage message) async {
    await _chatRoomsRef
        .doc(message.chatRoomId)
        .collection('messages')
        .add(message.toMap());

    await _chatRoomsRef.doc(message.chatRoomId).update({
      'lastMessage': message.text,
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
    });
  }

  Future<void> markAsRead(String chatRoomId, String userId) async {
    final messages = await _chatRoomsRef
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
