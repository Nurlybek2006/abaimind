import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import 'auth_provider.dart';

final chatServiceProvider = Provider((ref) => ChatService());

final chatRoomsProvider = StreamProvider<List<ChatRoom>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(chatServiceProvider).getChatRoomsForCurator();
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, chatRoomId) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(chatServiceProvider).getMessages(chatRoomId);
});
