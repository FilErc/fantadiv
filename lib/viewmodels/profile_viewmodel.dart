import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/login_page.dart';
import '/db/firebase_util_storage.dart';
import '/models/squad.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseUtilStorage _firebaseUtil = FirebaseUtilStorage();
  Squad? _squad;
  bool _hasTeam = false;
  bool _loading = true;
  final TextEditingController teamNameController = TextEditingController();

  bool get isLoading => _loading;
  bool get hasTeam => _hasTeam;
  Squad? get squad => _squad;

  ProfileViewModel() {
    _checkUserTeam();
  }

  Future<void> _checkUserTeam() async {
    bool result = await _firebaseUtil.hasTeam();
    if (result) {
      Squad? squad = await _firebaseUtil.getUserTeam();
      _hasTeam = true;
      _squad = squad;
      teamNameController.text = squad?.teamName ?? '';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> createTeam() async {
    String teamName = teamNameController.text.trim();
    if (teamName.isEmpty) return;

    await _firebaseUtil.createTeam(teamName);
    _hasTeam = true;
    await _checkUserTeam();

    notifyListeners();
  }

  Future<void> updateTeamName() async {
    if (_squad == null || teamNameController.text.isEmpty) return;

    await _firebaseUtil.updateTeamName(_squad!.id, teamNameController.text.trim());
    _squad = Squad(
      id: _squad!.id,
      teamName: teamNameController.text.trim(),
      owner: _squad!.owner,
      createdAt: _squad!.createdAt,
      reference: _squad!.reference,
    );

    notifyListeners();
  }

  Future<void> resetPassword(BuildContext context) async {
    await _firebaseUtil.resetPassword();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email di reset inviata!")),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to the LoginPage after sign-out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()), // Replace with LoginPage
    );

  }
}
