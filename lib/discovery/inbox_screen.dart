import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<dynamic> _matches = [];
  List<dynamic> _admirers = []; // ✨ NEW: Holds people who liked you!
  bool _isPremium = false;      // ✨ NEW: Tracks your VIP status!
  bool _isLoading = true;

  final String myUserId = "11111111-1111-1111-1111-111111111111";

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  // --------------------------------------------------------------------------
  // 📥 API FUNCTION: FETCH INBOX & SECRET ADMIRERS
  // --------------------------------------------------------------------------
  Future<void> _fetchAllData() async {
    final inboxUrl = Uri.parse('http://10.0.2.2:8000/api/inbox/$myUserId');
    final admirersUrl = Uri.parse('http://10.0.2.2:8000/api/who_liked_me/$myUserId');

    try {
      // Future.wait lets us call BOTH Python endpoints at the exact same time!
      final responses = await Future.wait([
        http.get(inboxUrl),
        http.get(admirersUrl),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final inboxData = jsonDecode(responses[0].body);
        final admirersData = jsonDecode(responses[1].body);

        setState(() {
          _matches = inboxData['inbox'];
          
          // ✨ Save the premium data and admirers list
          _isPremium = admirersData['is_premium'] ?? false;
          _admirers = admirersData['admirers'] ?? [];
          
          _isLoading = false;
        });
      } else {
        print("Server error fetching data.");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Network error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.black, size: 28), onPressed: () {}),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("LOGO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 2)),
            // ✨ THE PREMIUM CROWN! Only shows up if is_premium == true
            if (_isPremium) 
               const Padding(padding: EdgeInsets.only(left: 8.0), child: Text("👑", style: TextStyle(fontSize: 20))),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 28), onPressed: () {}),
        ],
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildTabChip("MESSAGES", true),
                      const SizedBox(width: 10),
                      _buildTabChip("Request", false),
                      const SizedBox(width: 10),
                      _buildTabChip("Views", false),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(icon: Icon(Icons.search, color: Colors.grey), hintText: "Search Name", border: InputBorder.none),
                    ),
                  ),
                ),
                
                // ✨ SECRET ADMIRERS ROW (Your Premium Feature!)
                if (_admirers.isNotEmpty)
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _admirers.length,
                      itemBuilder: (context, index) {
                        final admirer = _admirers[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                // Give admirers a shiny gold ring!
                                backgroundColor: Colors.amber, 
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    admirer['name'][0], 
                                    style: const TextStyle(fontSize: 24, color: Colors.amber, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(admirer['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Text("MOST RECENT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[800], letterSpacing: 1)),
                      const SizedBox(width: 5),
                      Icon(Icons.arrow_downward, size: 14, color: Colors.grey[800]),
                      Icon(Icons.menu, size: 14, color: Colors.grey[800]), 
                    ],
                  ),
                ),

                Expanded(
                  child: _matches.isEmpty 
                  ? Center(child: Text("Keep swiping to get matches!", style: TextStyle(color: Colors.grey[500])))
                  : ListView.builder(
                    itemCount: _matches.length,
                    itemBuilder: (context, index) {
                      final match = _matches[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(matchUser: match)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.pinkAccent.withOpacity(0.2),
                                child: Text(match['name'][0], style: const TextStyle(fontSize: 22, color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(match['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(
                                      index % 2 == 0 ? "You: Sounds like a plan!" : "Sent a photo",
                                      style: TextStyle(color: index % 2 == 0 ? Colors.grey[600] : Colors.black87, fontSize: 14),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (index == 0)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black87), borderRadius: BorderRadius.circular(15)),
                                      child: const Text("Match Now", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  Text(index == 0 ? "Under 24h" : index == 1 ? "Mon" : "Oct 12", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}