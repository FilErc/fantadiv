import 'package:flutter/material.dart';
import '../../viewmodels/calendar_viewmodel.dart';

class OriginalView extends StatelessWidget {
  final CalendarViewModel viewModel;

  const OriginalView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSectionTitle("Seleziona il numero di partite:"),
        _buildNumberInput(viewModel),
        const SizedBox(height: 20),
        _buildSectionTitle("Seleziona i giocatori:"),
        _buildPlayerChips(viewModel),
        const SizedBox(height: 20),
        _buildGenerateButton(viewModel),
        const SizedBox(height: 20),
        if (viewModel.schedule.isNotEmpty) _buildSchedule(viewModel),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 18, color: Colors.amber));
  }

  Widget _buildNumberInput(CalendarViewModel viewModel) {
    return TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: "Inserisci il numero di partite",
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.amber),
      onChanged: (value) {
        final int? newValue = int.tryParse(value);
        viewModel.setSelectedNumMatches(newValue ?? 0);
      },
    );
  }

  Widget _buildPlayerChips(CalendarViewModel viewModel) {
    return Wrap(
      spacing: 8.0,
      children: viewModel.availablePlayers.map((player) {
        return FilterChip(
          label: Text(player, style: const TextStyle(color: Colors.amber)),
          selected: viewModel.players.contains(player),
          onSelected: (selected) => viewModel.togglePlayerSelection(player, selected),
          selectedColor: Colors.amber,
          backgroundColor: Colors.grey[800],
          checkmarkColor: Colors.black,
        );
      }).toList(),
    );
  }

  Widget _buildGenerateButton(CalendarViewModel viewModel) {
    return ElevatedButton(
      onPressed: viewModel.players.length >= 8 && viewModel.selectedNumMatches > 0
          ? viewModel.generateSchedule
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        disabledBackgroundColor: Colors.grey,
        foregroundColor: Colors.black,
      ),
      child: const Text("Genera Calendario"),
    );
  }

  Widget _buildSchedule(CalendarViewModel viewModel) {
    return Expanded(
      child: ListView.builder(
        itemCount: viewModel.schedule.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Text("Giornata ${viewModel.schedule[index].day}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              ...viewModel.schedule[index].matches.map(
                    (match) => Text("${match.team1} vs ${match.team2}",
                    style: const TextStyle(color: Colors.white)),
              ),
              const Divider(color: Colors.amber),
            ],
          );
        },
      ),
    );
  }
}
