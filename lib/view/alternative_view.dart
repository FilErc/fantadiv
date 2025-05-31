import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/file_picker_viewmodel.dart';

class AlternativeView extends StatelessWidget {
  const AlternativeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FilePickerViewModel>(context);

    if (viewModel.isLoadingPlayers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!viewModel.alreadyLoaded) {
      return _buildFilePicker(viewModel);
    }

    return ChangeNotifierProvider(
      create: (_) => _FilterController(),
      child: Column(
        children: const [
          _PositionSelector(),
          Divider(color: Colors.amber),
          Expanded(child: _PositionedPlayerList()),
        ],
      ),
    );
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
            child: viewModel.isLoading
                ? const CircularProgressIndicator()
                : const Text("Scegli File"),
          ),
        ],
      ),
    );
  }
}

class _FilterController extends ChangeNotifier {
  final Set<String> selectedPositions = {};
  bool isUpdating = false;

  void toggle(String pos) async {
    isUpdating = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000)); // mostra loader

    if (selectedPositions.contains(pos)) {
      selectedPositions.remove(pos);
    } else {
      selectedPositions.add(pos);
    }

    isUpdating = false;
    notifyListeners();
  }
}

class _PositionSelector extends StatelessWidget {
  const _PositionSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FilePickerViewModel>(context, listen: false);
    final controller = Provider.of<_FilterController>(context);

    return Wrap(
      spacing: 10,
      children: viewModel.playersByPosition.keys.map((pos) {
        final selected = controller.selectedPositions.contains(pos);
        return FilterChip(
          label: Text(
            _getLabel(pos),
            style: TextStyle(color: selected ? Colors.black : Colors.amber),
          ),
          selected: selected,
          selectedColor: Colors.amber,
          onSelected: (_) => controller.toggle(pos),
        );
      }).toList(),
    );
  }

  String _getLabel(String code) {
    switch (code) {
      case 'A': return 'Att';
      case 'C': return 'Cc';
      case 'D': return 'Dif';
      case 'P': return 'P';
      default: return code;
    }
  }
}

class _PositionedPlayerList extends StatelessWidget {
  const _PositionedPlayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<_FilterController>(context);
    final viewModel = Provider.of<FilePickerViewModel>(context);

    if (controller.isUpdating) {
      return const Center(child: CircularProgressIndicator());
    }

    final visible = controller.selectedPositions.isEmpty
        ? viewModel.playersByPosition.keys
        : controller.selectedPositions;

    return ListView(
      children: visible.map((pos) {
        final players = viewModel.playersByPosition[pos]!;
        final color = _color(pos);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  _label(pos),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ...players.map((p) => Card(
                  color: color.withOpacity(0.1),
                  elevation: 2,
                  child: ListTile(
                    title: Center(
                      child: Text(p.name, style: TextStyle(color: color)),
                    ),
                    subtitle: Center(
                      child: Text(p.team, style: const TextStyle(color: Colors.white70)),
                    ),
                  ),
                )),
                const Divider(color: Colors.amber),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(String code) {
    switch (code) {
      case 'A': return 'Attaccanti';
      case 'C': return 'Centrocampisti';
      case 'D': return 'Difensori';
      case 'P': return 'Portieri';
      default: return code;
    }
  }

  Color _color(String code) {
    switch (code) {
      case 'A': return Colors.red;
      case 'C': return Colors.lightBlue;
      case 'D': return Colors.green;
      case 'P': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
