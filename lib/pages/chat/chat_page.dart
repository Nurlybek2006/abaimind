import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/loading_widget.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  String? _chatRoomId;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Delay so that currentUserProvider is ready after login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initChat();
    });
  }

  Future<void> _initChat() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    if (user.role == UserRole.student) {
      try {
        final roomId = await ref.read(chatServiceProvider).getOrCreateChatRoom(
              studentId: user.uid,
              studentName: user.fullName,
            );
        if (!mounted) return;
        setState(() => _chatRoomId = roomId);
      } catch (_) {
        // ignore — will show loading until retry
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    if (user == null) return const LoadingWidget();

    // Curator sees list of chat rooms
    if (user.role != UserRole.student) {
      return _CuratorChatList();
    }

    // Student sees their chat
    if (_chatRoomId == null) return const LoadingWidget();

    return _ChatView(
      chatRoomId: _chatRoomId!,
      currentUser: user,
    );
  }
}

class _CuratorChatList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRooms = ref.watch(chatRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Хаттар'),
        automaticallyImplyLeading: false,
      ),
      body: chatRooms.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorWidget2(message: e.toString()),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const EmptyWidget(
              message: AppStrings.noMessages,
              icon: Icons.chat_bubble_outline,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _ChatRoomTile(room: room)
                  .animate()
                  .fadeIn(delay: (index * 80).ms);
            },
          );
        },
      ),
    );
  }
}

class _ChatRoomTile extends ConsumerWidget {
  final ChatRoom room;

  const _ChatRoomTile({required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.gold.withValues(alpha: 0.1),
          child: Text(
            room.studentName.isNotEmpty ? room.studentName[0] : '?',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(room.studentName),
        subtitle: room.lastMessage != null
            ? Text(
                room.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: room.unreadCount > 0
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${room.unreadCount}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text(room.studentName)),
                body: _ChatView(
                  chatRoomId: room.id,
                  currentUser: user,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatView extends ConsumerStatefulWidget {
  final String chatRoomId;
  final UserModel currentUser;

  const _ChatView({
    required this.chatRoomId,
    required this.currentUser,
  });

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: '',
      senderId: widget.currentUser.uid,
      senderName: widget.currentUser.fullName,
      receiverId: '', // Will be resolved by backend
      text: text,
      timestamp: DateTime.now(),
      chatRoomId: widget.chatRoomId,
    );

    _messageController.clear();
    await ref.read(chatServiceProvider).sendMessage(message);

    // With reverse:true, scrolling to 0 goes to the newest message (bottom)
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(chatMessagesProvider(widget.chatRoomId));

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            loading: () => const LoadingWidget(),
            error: (e, _) => ErrorWidget2(message: e.toString()),
            data: (messages) {
              if (messages.isEmpty) {
                return const EmptyWidget(
                  message: AppStrings.noMessages,
                  icon: Icons.chat_bubble_outline,
                );
              }
              // reverse:true anchors newest messages to the bottom;
              // messages come ascending (oldest first), so reverse them
              // so index 0 = newest → displayed at bottom.
              final reversed = messages.reversed.toList();
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: reversed.length,
                itemBuilder: (context, index) {
                  final msg = reversed[index];
                  final isMe = msg.senderId == widget.currentUser.uid;
                  return _MessageBubble(message: msg, isMe: isMe);
                },
              );
            },
          ),
        ),
        // Input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: AppStrings.typeMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: AppColors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.gold
                  : Theme.of(context).brightness == Brightness.dark
                      ? AppColors.cardDark
                      : AppColors.backgroundLight,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? AppColors.white : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
