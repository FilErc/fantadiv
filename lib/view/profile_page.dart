import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '/viewmodels/profile_viewmodel.dart';
import 'player_detail_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          final User? user = FirebaseAuth.instance.currentUser;

          if (viewModel.isLoading) {
            return Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator(color: Colors.amber)),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: viewModel.hasTeam ? _buildProfile(viewModel, user, context) : _buildCreateTeam(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildProfile(ProfileViewModel viewModel, User? user, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text("La mia email:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
          Text(user?.email ?? "Email non disponibile", style: const TextStyle(fontSize: 18, color: Colors.amber)),
          const SizedBox(height: 30),

          const Text("Nome Squadra:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: viewModel.teamNameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.amber),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          //const SizedBox(height: 10),
          //ElevatedButton(
            //onPressed: viewModel.updateTeamName,
            //style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            //child: const Text("Salva"),
          //),

          const SizedBox(height: 20),
          const Text("Rosa:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 10),

          if (viewModel.isFetchingPlayers)
            const Center(child: CircularProgressIndicator(color: Colors.amber))
          else if (viewModel.loadedPlayers.isEmpty)
            const Text("Rosa non inserita", style: TextStyle(color: Colors.amber))
          else
            Column(
              children: (viewModel.squad!.referenceWithPrice!.entries
                  .where((entry) => viewModel.loadedPlayers.containsKey(entry.key))
                  .toList()
                ..sort((a, b) {
                  final roleOrder = {'P': 0, 'D': 1, 'C': 2, 'A': 3};
                  final playerA = viewModel.loadedPlayers[a.key]!;
                  final playerB = viewModel.loadedPlayers[b.key]!;
                  return roleOrder[playerA.position]!.compareTo(roleOrder[playerB.position]!);
                }))
                  .map((entry) {
                final player = viewModel.loadedPlayers[entry.key]!;
                final price = entry.value;
                final color = _color(player.position);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlayerDetailPage(player: player)),
                    );
                  },
                  child: Card(
                    color: Colors.grey[850],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color,
                        child: Text(
                          player.position,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        player.team,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Text(
                        "€$price",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => viewModel.resetPassword(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: const Text("Reset Password"),
          ),
          ElevatedButton(
            onPressed: () => viewModel.logout(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: const Text("Logout"),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCreateTeam(ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Crea la tua squadra!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 20),
          TextField(
            controller: viewModel.teamNameController,
            decoration: const InputDecoration(
              labelText: "Nome della Squadra",
              labelStyle: TextStyle(color: Colors.amber),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: viewModel.createTeam,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: const Text("Crea Squadra"),
          ),
        ],
      ),
    );
  }

  Color _color(String code) {
    switch (code) {
      case 'A':
        return Colors.red;
      case 'C':
        return Colors.lightBlue;
      case 'D':
        return Colors.green;
      case 'P':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
