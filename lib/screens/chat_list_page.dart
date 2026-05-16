import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_providers.dart';
import '../services/database.dart';
import 'chat_room_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final DatabaseService dbService = DatabaseService();

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: etsyBackground,
        body: Center(child: Text('Vui lòng đăng nhập', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        backgroundColor: etsyBackground,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: etsyBackground,
      body: StreamBuilder<QuerySnapshot>(
        stream: dbService.getChatRooms(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi', style: TextStyle(color: Colors.white)));
          }

          final chatRooms = snapshot.data?.docs ?? [];

          if (chatRooms.isEmpty) {
            return const Center(
              child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final data = chatRooms[index].data() as Map<String, dynamic>;
              final participants = List<String>.from(data['participants'] ?? []);
              participants.remove(currentUser.uid); // Lấy ID người chat cùng
              final otherUserId = participants.isNotEmpty ? participants.first : 'Khách';

              return FutureBuilder<UserModel?>(
                future: dbService.getUser(otherUserId),
                builder: (context, userSnapshot) {
                  final otherUserName = userSnapshot.data?.name ?? 'Người dùng ($otherUserId)';
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(otherUserName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      data['lastMessage'] ?? '',
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomPage(
                            receiverId: otherUserId,
                            receiverName: otherUserName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
