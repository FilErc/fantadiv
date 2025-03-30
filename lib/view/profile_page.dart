import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '/viewmodels/profile_viewmodel.dart';

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
    if (viewModel.squad == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("La mia email:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
          Text(user?.email ?? "Email non disponibile", style: const TextStyle(fontSize: 18, color: Colors.amber)),
          const SizedBox(height: 30),

          const Text("Nome Squadra:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),

          TextField(
            controller: viewModel.teamNameController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              labelStyle: TextStyle(color: Colors.amber),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: viewModel.updateTeamName,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: const Text("Salva"),
          ),

          const SizedBox(height: 20),
          const Text("Rosa:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
          viewModel.squad!.reference == null || viewModel.squad!.reference!.isEmpty
              ? const Text("Rosa non inserita", style: TextStyle(color: Colors.amber))
              : Column(
            children: viewModel.squad!.reference!.map((ref) => Text(ref.path, style: const TextStyle(color: Colors.white))).toList(),
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
}
