import 'dart:convert';

import 'package:Otobook/screens/editUser_page.dart';
import 'package:Otobook/screens/start.dart';
import 'package:Otobook/services/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>>? userData;
  String? username;
  String? email;

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    // print(token);
    final response = await http.post(
      Uri.parse(GetData().logoutUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await prefs.remove('token');
      await prefs.remove('id');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StartScreen()),
      );
    } else {
      // Handle error
    }
  }

  Future<int?> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    if (id != null) {
      return int.tryParse(id);
    }
    return null;
  }

  Future<Map<String, dynamic>> getUserData() async {
    int? id = await getId();
    final response = await http.get(
      Uri.parse('${GetData().getUserIdUrl}/$id'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'username': data['username'],
        'email': data['email'],
        'path': data['path'],
      };
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  void initState() {
    super.initState();
    userData = getUserData();
  }

  void navigateToEditUser(BuildContext context) async {
    int? id = await getId();
    if (id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EdituserPage(id: id),
        ),
      ).then((result) {
        if (result == true) {
          setState(() {
            userData = getUserData(); // Refresh user data
          });
        }
      });
    } else {
      print("User ID is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 126, 181, 215),
                  Color.fromARGB(255, 177, 190, 210)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Map<String, dynamic>>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('assets/profile_placeholder.jpg'),
                    ),
                  );
                } else {
                  final data = snapshot.data!;
                  final coverUrl = '${GetData().Url}${data['path']}';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/profile_placeholder.jpg',
                            image: coverUrl,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/profile_placeholder.jpg',
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.symmetric(
                              horizontal: constraints.maxWidth * 0.05,
                            ), // Adjust margin to 5% of the screen width
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.person,
                                              color: Colors.blueAccent),
                                          const SizedBox(width: 10.0),
                                          Text(
                                            'Username: ${data['username']}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.email,
                                              color: Colors.blueAccent),
                                          const SizedBox(width: 10.0),
                                          Text(
                                            'Email: ${data['email']}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          navigateToEditUser(context);
                                        },
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blueAccent),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          logout(context);
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 59, 52, 52),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
