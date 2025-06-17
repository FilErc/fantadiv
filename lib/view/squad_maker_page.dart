import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/round.dart';
import '../viewmodels/squad_maker_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../models/players.dart';
import '../widgets/football_field_painter.dart';

class SquadMakerPage extends StatefulWidget {
  final Round giornata;
  const SquadMakerPage({super.key, required this.giornata});


  @override
  State<SquadMakerPage> createState() => _SquadMakerPageState();
}

class _SquadMakerPageState extends State<SquadMakerPage> {
  final List<String> modules = ['3-4-3', '3-5-2', '4-3-3', '4-4-2', '4-5-1', '5-3-2', '5-4-1'];
  String selectedModule = '4-4-2';
  bool timeoutReached = false;
  late Timer _timeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimeout());
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      final profileVM = context.read<ProfileViewModel>();
      if (mounted && profileVM.loadedPlayers.isEmpty) {
        setState(() {
          timeoutReached = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer.cancel();
    super.dispose();
  }

  Map<String, int> _moduleToRoleCounts(String module) {
    final parts = module.split('-').map(int.parse).toList();
    return {
      'D': parts[0],
      'C': parts[1],
      'A': parts[2],
      'P': 1,
    };
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

  String _roleName(String role) {
    switch (role) {
      case 'P':
        return 'Portiere';
      case 'D':
        return 'Difensore';
      case 'C':
        return 'Centrocampista';
      case 'A':
        return 'Attaccante';
      default:
        return 'Ruolo';
    }
  }

  void _showPlayersByRole(
      BuildContext context,
      List<Players> players,
      String role,
      Function(Players) onPlayerSelected,
      ) {
    final selected = context.read<SquadMakerViewModel>().roleToPlayers.values.expand((e) => e).map((p) => p.name).toSet();

    final filtered = players
        .where((p) => p.position == role && !selected.contains(p.name))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            "Seleziona ${_roleName(role)}",
            style: TextStyle(color: _color(role), fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final player = filtered[i];
              return ListTile(
                title: Text(player.name, style: TextStyle(color: _color(player.position))),
                subtitle: Text(player.team, style: const TextStyle(color: Colors.amberAccent)),
                trailing: IconButton(
                  icon: const Icon(Icons.add_box),
                  color: _color(player.position),
                  onPressed: () {
                    Navigator.pop(context);
                    onPlayerSelected(player);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SquadMakerViewModel, ProfileViewModel>(
      builder: (context, squadVM, profileVM, _) {
        final playersMap = profileVM.loadedPlayers;

        if (playersMap.isEmpty) {
          return timeoutReached
              ? const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'Errore: impossibile caricare i giocatori.',
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          )
              : const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.amber)),
          );
        }

        final roleCounts = _moduleToRoleCounts(selectedModule);
        final allPlayers = List<Players>.from(playersMap.values);

        if (squadVM.orderedBench.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final selectedNames = squadVM.roleToPlayers.values.expand((e) => e).map((p) => p.name).toSet();
            squadVM.initializeBench(allPlayers, selectedNames);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Crea Formazione"),
            backgroundColor: Colors.amber,
            centerTitle: true,
          ),
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: DropdownButton<String>(
                      value: selectedModule,
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.amber),
                      iconEnabledColor: Colors.amber,
                      items: modules.map((mod) {
                        return DropdownMenuItem(value: mod, child: Text(mod));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedModule = value!;
                          squadVM.clearSquadWithStructure(_moduleToRoleCounts(selectedModule));
                          final selected = squadVM.roleToPlayers.values.expand((e) => e).map((p) => p.name).toSet();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            squadVM.initializeBench(allPlayers, selected);
                          });
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          CustomPaint(size: Size.infinite, painter: FootballFieldPainter()),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final height = constraints.maxHeight;
                              List<Widget> buttons = [];

                              final yMap = {
                                'P': height * 0.05,
                                'D': height * 0.25,
                                'C': height * 0.5,
                                'A': height * 0.75,
                              };

                              for (final role in ['P', 'D', 'C', 'A']) {
                                final count = roleCounts[role]!;
                                for (int i = 0; i < count; i++) {
                                  final x = width / (count + 1) * (i + 1);
                                  final y = yMap[role]!;
                                  final player = squadVM.getPlayerAt(role, i);

                                  buttons.add(Positioned(
                                    left: x - 30,
                                    top: y - 30,
                                    child: Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _showPlayersByRole(
                                              context,
                                              allPlayers,
                                              role,
                                                  (selected) => squadVM.setPlayerAt(role, i, selected),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(12),
                                            backgroundColor: _color(role),
                                          ),
                                          child: Text(
                                            player == null ? role : player.name[0],
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        if (player != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: SizedBox(
                                              width: 60,
                                              child: Text(
                                                player.name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Colors.white, fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ));
                                }
                              }

                              return Stack(children: buttons);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Panchina",
                    style: TextStyle(color: Colors.amber, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Per modificare l’ordine dei panchinari, tieni premuto su un giocatore e trascinalo nella posizione desiderata.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    child: ReorderableListView(
                      padding: const EdgeInsets.all(8),
                      buildDefaultDragHandles: true,
                      children: squadVM.orderedBench.map((player) {
                        return Container(
                          key: ValueKey(player.name),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _color(player.position), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                color: _color(player.position),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final updated = List<Players>.from(squadVM.orderedBench);
                        final moved = updated.removeAt(oldIndex);
                        updated.insert(newIndex, moved);
                        squadVM.updateBenchOrder(updated);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: squadVM.isSquadComplete(roleCounts)
                        ? () {
                      final profileVM = context.read<ProfileViewModel>();
                      final squad = profileVM.squad;
                      squadVM.confirmSquad(widget.giornata, squad!);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Conferma Formazione"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}