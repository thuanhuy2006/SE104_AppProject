import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_providers.dart';
import '../services/database.dart';

class ChatRoomPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final dynamic
  product; // Bạn có thể thay 'dynamic' bằng tên class Model sản phẩm (VD: ProductModel)

  const ChatRoomPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.product,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  void _sendMessage(String senderId) {
    if (_messageController.text.trim().isNotEmpty) {
      _dbService.sendMessage(
        senderId,
        widget.receiverId,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tin nhắn')),
        body: const Center(child: Text('Vui lòng đăng nhập để nhắn tin')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: etsyBackground,
        foregroundColor: Colors.white,
      ),
      backgroundColor: etsyBackground,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _dbService.getMessages(
                currentUser.uid,
                widget.receiverId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Lỗi ChatRoomPage: ${snapshot.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Đã xảy ra lỗi:\n${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final bool isMe = data['senderId'] == currentUser.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.deepOrange
                              : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['text'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              8.0,
              8.0,
              8.0,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 8.0
                  : 8.0,
            ),
            color: etsyCardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepOrange,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(currentUser.uid),
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
