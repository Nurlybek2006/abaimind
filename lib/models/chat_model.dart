import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String chatRoomId;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    required this.chatRoomId,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatMessage(
      id: id ?? map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      timestamp:
          (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      chatRoomId: map['chatRoomId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'chatRoomId': chatRoomId,
    };
  }
}

class ChatRoom {
  final String id;
  final String studentId;
  final String studentName;
  final String? curatorId;
  final String? curatorName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.curatorId,
    this.curatorName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatRoom(
      id: id ?? map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      curatorId: map['curatorId'],
      curatorName: map['curatorName'],
      lastMessage: map['lastMessage'],
      lastMessageTime:
          (map['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'curatorId': curatorId,
      'curatorName': curatorName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'unreadCount': unreadCount,
    };
  }
}
