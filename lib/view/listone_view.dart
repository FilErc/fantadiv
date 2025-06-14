import 'package:fantadiv/view/player_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/file_picker_viewmodel.dart';
import '../../models/players.dart';

class ListoneView extends StatelessWidget {
  const ListoneView({super.key});

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
          _SearchBar(),
          SizedBox(height: 10),
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
    await Future.delayed(const Duration(milliseconds: 1000));
    if (selectedPositions.contains(pos)) {
      selectedPositions.remove(pos);
    } else {
      selectedPositions.add(pos);
    }
    isUpdating = false;
    notifyListeners();
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FilePickerViewModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Cerca giocatore...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _controller.clear();
                    viewModel.searchPlayersByFragment('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber, width: 2),
                ),
              ),
              onChanged: (value) async {
                if (value.trim().isEmpty) {
                  await viewModel.searchPlayersByFragment('');
                }
              },
              onSubmitted: (value) async {
                await viewModel.searchPlayersByFragment(value);
              },
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              final text = _controller.text.trim();
              await viewModel.searchPlayersByFragment(text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Cerca"),
          ),
        ],
      ),
    );
  }
}

class _PositionSelector extends StatelessWidget {
  const _PositionSelector();

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
      case 'A':
        return 'Att';
      case 'C':
        return 'Cc';
      case 'D':
        return 'Dif';
      case 'P':
        return 'P';
      default:
        return code;
    }
  }
}

class _PositionedPlayerList extends StatelessWidget {
  const _PositionedPlayerList();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<_FilterController>(context);
    final viewModel = Provider.of<FilePickerViewModel>(context);

    if (controller.isUpdating || viewModel.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.searchResults.isNotEmpty) {
      return _buildPlayerCards(context, viewModel.searchResults);
    }

    if (viewModel.searchResults.isEmpty &&
        viewModel.searchedPlayer == null &&
        viewModel.matchingPlayers.isEmpty &&
        viewModel.isSearching == false &&
        controller.selectedPositions.isEmpty) {
      return const Center(
        child: Text(
          'Nessun risultato trovato',
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
      );
    }

    if (controller.selectedPositions.isNotEmpty) {
      final filtered = Map.fromEntries(
        viewModel.playersByPosition.entries.where(
              (entry) => controller.selectedPositions.contains(entry.key),
        ),
      );
      return _buildGroupedPlayers(context, filtered);
    }

    return _buildGroupedPlayers(context, viewModel.playersByPosition);
  }

  Widget _buildPlayerCards(BuildContext context, List<Players> players) {
    return ListView(
      children: players.map((p) {
        final color = _color(p.position);
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              color: color.withOpacity(0.1),
              elevation: 2,
              child: ListTile(
                title: Center(child: Text(p.name, style: TextStyle(color: color))),
                subtitle: Center(child: Text(p.team, style: const TextStyle(color: Colors.white70))),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerDetailPage(player: p),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupedPlayers(BuildContext context, Map<String, List<Players>> grouped) {
    return ListView(
      children: grouped.entries.map((entry) {
        final pos = entry.key;
        final color = _color(pos);
        final players = entry.value;

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
                    title: Center(child: Text(p.name, style: TextStyle(color: color))),
                    subtitle: Center(child: Text(p.team, style: const TextStyle(color: Colors.white70))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerDetailPage(player: p),
                        ),
                      );
                    },
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
      case 'A':
        return 'Attaccanti';
      case 'C':
        return 'Centrocampisti';
      case 'D':
        return 'Difensori';
      case 'P':
        return 'Portieri';
      default:
        return code;
    }
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
