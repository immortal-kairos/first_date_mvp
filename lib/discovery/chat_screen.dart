import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  // We need to pass the profile data of the person we are chatting with
  // from the Inbox screen to this Chat screen!
  final Map<String, dynamic> matchUser;

  const ChatScreen({super.key, required this.matchUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<dynamic> _messages = [];
  bool _isLoading = true;

  // ⚡ FIX: Your exact UUID
  final String myUserId = "11111111-1111-1111-1111-111111111111";

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  // --------------------------------------------------------------------------
  // 📥 API FUNCTION: FETCH CHAT HISTORY
  // --------------------------------------------------------------------------
  Future<void> _fetchMessages() async {
    final matchId = widget.matchUser['id'];
    final url = Uri.parse('http://10.0.2.2:8000/api/messages/$myUserId/$matchId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages = data['messages'];
          _isLoading = false;
        });
        // Scroll to the bottom after loading messages
        _scrollToBottom();
      } else {
        print("Error fetching messages: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Network error: $e");
      setState(() => _isLoading = false);
    }
  }

  // --------------------------------------------------------------------------
  // 📤 API FUNCTION: SEND A MESSAGE
  // --------------------------------------------------------------------------
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final textToSend = _messageController.text.trim();
    final matchId = widget.matchUser['id'];
    
    // Clear the text box immediately so the app feels fast
    _messageController.clear(); 

    // Optimistically add the message to the UI before the server responds
    setState(() {
      _messages.add({
        'sender_id': myUserId,
        'receiver_id': matchId,
        'content': textToSend,
      });
    });
    _scrollToBottom();

    // Now send it to the Python backend to save in Supabase
    final url = Uri.parse('http://10.0.2.2:8000/api/messages');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_id": myUserId,
          "receiver_id": matchId,
          "content": textToSend,
        }),
      );

      if (response.statusCode != 200) {
        print("Failed to send to database: ${response.statusCode}");
        // In a real app, you might show a "failed to send" red exclamation mark here
      }
    } catch (e) {
      print("Network error sending message: $e");
    }
  }

  // Helper function to keep the chat scrolled to the newest message
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --------------------------------------------------------------------------
  // 🎨 THE UI (Built strictly from your wireframe!)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. THE APP BAR (Back button, Avatar, Name, Call Icons)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        titleSpacing: 0, // Removes extra padding
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.pinkAccent.withOpacity(0.2),
              child: Text(
                widget.matchUser['name'][0],
                style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.matchUser['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),

      // 2. THE CHAT BODY
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    // Add 1 to itemCount to make room for our custom Match Banner at the top!
                    itemCount: _messages.length + 1, 
                    itemBuilder: (context, index) {
                      
                      // Render the Match Banner from your sketch at the very top
                      if (index == 0) {
                        return _buildMatchBanner();
                      }

                      // Render the actual chat bubbles
                      final message = _messages[index - 1]; // Subtract 1 because of the banner
                      final isMe = message['sender_id'] == myUserId;

                      return _buildChatBubble(message['content'], isMe);
                    },
                  ),
          ),

          // 3. THE INPUT AREA (Message box, Attachment, Send)
          _buildMessageInput(),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 🖼️ UI WIDGETS
  // --------------------------------------------------------------------------

  // The custom match info banner from your drawing
  Widget _buildMatchBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 30, top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            "You Matched with ${widget.matchUser['name']}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Because you have infinity ∞\nMUTUAL INTERESTS",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Chip(
                label: const Text("LOOKING FOR", style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[300]!),
              ),
              const SizedBox(width: 8),
              Chip(
                label: const Text("Long term partner", style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ],
          )
        ],
      ),
    );
  }

  // The Chat Bubbles
  Widget _buildChatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.pinkAccent : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0), // Flat corner for tail
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        // Ensures the bubble doesn't stretch all the way across the screen
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // The bottom text input area from your drawing
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
              onPressed: () {}, // Attachment logic goes here later
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "message",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.pinkAccent),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}