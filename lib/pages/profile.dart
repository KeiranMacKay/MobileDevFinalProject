import 'package:flutter/material.dart';
import 'login.dart';
import 'package:finalproject/notifications.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  //account username
  final String username = 'The cheapies';
  //list of users
  final List<String> _users = [
    'Cheapy',
    'Spendy',
    'Wastey',
    'Hoardy',
    'Greedy',
    'John'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
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

            //dynamic list, 2-6
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user[0]),
                    ),
                    title: Text(user),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$user selected'),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            //logout button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Notifications().showNoti(
                    title: "Logout",
                    body: "You have been logged out.",
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

