import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String username = 'Cheapy and Spendy';
  final List<String> _users = ['Cheapy', 'Spendy'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

            //avatar
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    username[0],
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                //username
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            //users display
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  String user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user[0]),
                    ),
                    title: Text(user),
                    onTap: () {},
                  );
                },
              ),
            ),

            //logout
            Center(
              child: ElevatedButton.icon(
                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out')),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

