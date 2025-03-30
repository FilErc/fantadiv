import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../viewmodels/file_picker_viewmodel.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalendarViewModel()),
        ChangeNotifierProvider(create: (_) => FilePickerViewModel()), // Provide it here
      ],
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<CalendarViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SwitchButton(viewModel: viewModel),
                    const SizedBox(height: 16),
                    Expanded(
                      child: viewModel.showAlternativeView
                          ? const AlternativeView()
                          : OriginalView(viewModel: viewModel),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SwitchButton extends StatelessWidget {
  final CalendarViewModel viewModel;

  const SwitchButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: viewModel.toggleView,
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: viewModel.showAlternativeView
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  viewModel.showAlternativeView ? "ON" : "OFF",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class AlternativeView extends StatelessWidget {
  const AlternativeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FilePickerViewModel>(context);

    return viewModel.alreadyLoaded
        ? _buildPlayerList(viewModel)
        : _buildFilePicker(viewModel);
  }

  Widget _buildFilePicker(FilePickerViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Seleziona un file Excel", style: TextStyle(fontSize: 24, color: Colors.amber)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: viewModel.isLoading ? null : viewModel.pickAndProcessFile,
            child: viewModel.isLoading ? const CircularProgressIndicator() : const Text("Scegli File"),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList(FilePickerViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.playersStored.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[850],
          child: ListTile(
            title: Text(viewModel.playersStored[index].name, style: TextStyle(color: Colors.amber)),
          ),
        );
      },
    );
  }
}
