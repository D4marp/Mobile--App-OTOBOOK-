import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:otobook/screen/profile/edit_user_profile.dart';
import 'package:otobook/screen/splash/start_screen.dart';
import 'package:otobook/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart'; // Import shimmer package

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>>? userData;

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse(GetData().logoutUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StartScreen()),
      );
    }
  }

  Future<int?> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return int.tryParse(prefs.getString('id') ?? '');
  }

  Future<Map<String, dynamic>> getUserData() async {
    int? id = await getId();
    final response = await http.get(Uri.parse('${GetData().getUserIdUrl}/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'username': data['username'],
        'email': data['email'],
        'path': data['path'],
      };
    } else {
      throw Exception('Failed to load user data');
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
        MaterialPageRoute(builder: (context) => EditUserPage(id: id)),
      ).then((result) {
        if (result == true) {
          setState(() => userData = getUserData());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => navigateToEditUser(context),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerEffect(); // Tampilkan shimmer saat loading
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text(
                  'Failed to load user data',
                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
              );
            }

            final data = snapshot.data!;
            final coverUrl = '${GetData().Url}${data['path']}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: NetworkImage(coverUrl),
                  onBackgroundImageError:
                      (_, __) =>
                          const AssetImage('assets/profile_placeholder.jpg'),
                ),
                const SizedBox(height: 20.0),
                Text(
                  data['username'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  data['email'],
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30.0),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.blueAccent.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.blueAccent,
                          ),
                          title: const Text(
                            'Username',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          subtitle: Text(
                            data['username'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.email,
                            color: Colors.blueAccent,
                          ),
                          title: const Text(
                            'Email',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          subtitle: Text(
                            data['email'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                      shadowColor: Colors.redAccent.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300, // Warna dasar shimmer
      highlightColor: Colors.grey.shade100, // Warna highlight shimmer
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor:
                Colors.grey.shade300, // Placeholder untuk CircleAvatar
          ),
          const SizedBox(height: 20.0),
          Container(
            width: 150,
            height: 24,
            color: Colors.grey.shade300, // Placeholder untuk username
          ),
          const SizedBox(height: 10.0),
          Container(
            width: 200,
            height: 16,
            color: Colors.grey.shade300, // Placeholder untuk email
          ),
          const SizedBox(height: 30.0),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            shadowColor: Colors.blueAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      color: Colors.grey.shade300, // Placeholder untuk ikon
                    ),
                    title: Container(
                      width: 100,
                      height: 16,
                      color: Colors.grey.shade300, // Placeholder untuk label
                    ),
                    subtitle: Container(
                      width: 150,
                      height: 20,
                      color: Colors.grey.shade300, // Placeholder untuk nilai
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      color: Colors.grey.shade300, // Placeholder untuk ikon
                    ),
                    title: Container(
                      width: 100,
                      height: 16,
                      color: Colors.grey.shade300, // Placeholder untuk label
                    ),
                    subtitle: Container(
                      width: 150,
                      height: 20,
                      color: Colors.grey.shade300, // Placeholder untuk nilai
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300, // Placeholder untuk tombol
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }
}
