import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/squad_maker_viewmodel.dart';

class SquadMakerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SquadMakerViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Crea Formazione"),
          backgroundColor: Colors.amber,
        ),
        body: Consumer<SquadMakerViewModel>(
          builder: (context, viewModel, child) {
            return Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Formazione Attuale",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.selectedPlayers.length,
                      itemBuilder: (context, index) {
                        final player = viewModel.selectedPlayers[index];
                        return ListTile(
                          title: Text(
                            player,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => viewModel.removePlayer(player),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: viewModel.confirmSquad,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Conferma Formazione"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
