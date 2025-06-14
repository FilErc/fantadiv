import 'package:flutter/material.dart';
import '../../viewmodels/calendar_viewmodel.dart';

class CalendarView extends StatelessWidget {
  final CalendarViewModel viewModel;

  const CalendarView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        title: const Text("Generatore Calendario"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionTitle("1. Seleziona 8 squadre"),
            const SizedBox(height: 10),
            _buildPlayerGrid(viewModel),
            const SizedBox(height: 20),
            _buildSectionTitle("2. Numero giornate"),
            _buildMatchSlider(viewModel),
            const SizedBox(height: 10),
            _buildGenerateButton(viewModel),
            const SizedBox(height: 20),
            if (viewModel.schedule.isNotEmpty) Expanded(child: _buildSchedule(viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPlayerGrid(CalendarViewModel viewModel) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: viewModel.availablePlayers.map((player) {
        final selected = viewModel.players.contains(player);
        return ChoiceChip(
          label: Text(player),
          selected: selected,
          onSelected: (_) {
            if (selected) {
              viewModel.togglePlayerSelection(player, false);
            } else if (viewModel.players.length < 8) {
              viewModel.togglePlayerSelection(player, true);
            }
          },
          selectedColor: Colors.amber,
          backgroundColor: Colors.grey[800],
          labelStyle: TextStyle(
              color: selected ? Colors.black : Colors.amber, fontWeight: FontWeight.w500),
        );
      }).toList(),
    );
  }

  Widget _buildMatchSlider(CalendarViewModel viewModel) {
    return Column(
      children: [
        Slider(
          value: viewModel.selectedNumMatches.toDouble(),
          min: 1,
          max: 38,
          divisions: 37,
          label: "${viewModel.selectedNumMatches} giornate",
          onChanged: (value) {
            viewModel.setSelectedNumMatches(value.toInt());
          },
          activeColor: Colors.amber,
          inactiveColor: Colors.grey[700],
        ),
        Text(
          "${viewModel.selectedNumMatches} giornate",
          style: const TextStyle(color: Colors.amber),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(CalendarViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.calendar_today),
        label: const Text("Genera Calendario"),
        onPressed: viewModel.players.length == 8 && viewModel.selectedNumMatches > 0
            ? viewModel.generateSchedule
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSchedule(CalendarViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.schedule.length,
      itemBuilder: (context, index) {
        final giornata = viewModel.schedule[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Giornata ${giornata.day}",
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ...giornata.matches.map((match) => Text(
                  "${match.team1} vs ${match.team2}",
                  style: const TextStyle(color: Colors.white),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
