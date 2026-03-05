import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;

import 'inbox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _matches = [];
  bool _isLoading = true;
  final String myUserId = "11111111-1111-1111-1111-111111111111";

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/matches');
    final targetUser = {
      "id": myUserId,
      "name": "Farhan",
      "age": 22,
      "gender": "Male",
      "looking_for": "Female",
      "interests": ["coding", "night rides", "machine learning"]
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(targetUser),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _matches = data['matches'];
          _isLoading = false;
        });
      } else {
        print("Server error: ${response.statusCode}");
        setState(() => _isLoading = false); 
      }
    } catch (e) {
      print("Network error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recordSwipe(String targetId, String action) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/swipe');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "swiper_id": myUserId,
          "target_id": targetId,
          "action": action,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['is_match'] == true) {
          print("🎉 MUTUAL MATCH TRIGGERED!");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 IT\'S A MATCH! You both swiped right!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.pinkAccent,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Network error while swiping: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Discovery", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFFFF4081)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const InboxScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
          : _matches.isEmpty
              ? const Center(child: Text("No more matches in your area!"))
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CardSwiper(
                      cardsCount: _matches.length,
                      // ✨ THE FIX: Dynamically adjusts cards to prevent the crash!
                      numberOfCardsDisplayed: _matches.length == 1 ? 1 : 2, 
                      onSwipe: (previousIndex, currentIndex, direction) {
                        final swipedUser = _matches[previousIndex]['candidate'];
                        final targetId = swipedUser['id'];
                        String action = direction == CardSwiperDirection.right ? 'like' : 'pass'; 
                        
                        _recordSwipe(targetId, action);
                        return true;
                      },
                      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                        final match = _matches[index];
                        return _buildProfileCard(match['candidate'], match['vibe_score']);
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> candidate, int vibeScore) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFFF79A1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: const Center(child: Icon(Icons.person, size: 100, color: Colors.white54)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text("${candidate['name']}, ${candidate['age']}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Text("🔥 $vibeScore% Vibe", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(candidate['bio'], style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: (candidate['interests'] as List<dynamic>).map((interest) {
                        return Chip(label: Text(interest), backgroundColor: Colors.grey[200], side: BorderSide.none);
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}