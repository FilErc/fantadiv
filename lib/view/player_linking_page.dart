import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/players.dart';
import '../viewmodels/player_linking_viewmodel.dart';

class PlayerLinkingView extends StatefulWidget {
  final String searchName;
  final List<Players> allPlayers;

  const PlayerLinkingView({
    required this.searchName,
    required this.allPlayers,
    super.key,
  });

  @override
  State<PlayerLinkingView> createState() => _PlayerLinkingViewState();
}

class _PlayerLinkingViewState extends State<PlayerLinkingView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.searchName;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerLinkingViewModel(widget.searchName, widget.allPlayers),
      child: Consumer<PlayerLinkingViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(title: Text('Collega "${widget.searchName}"')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Cerca giocatore...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: vm.search,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => vm.search(_controller.text),
                      )
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: vm.filteredPlayers.length,
                    itemBuilder: (_, index) {
                      final player = vm.filteredPlayers[index];
                      return ListTile(
                        title: Text(player.name),
                        subtitle: Text(player.team),
                        onTap: () {
                          vm.selectPlayer(player);
                          Navigator.pop(context, player);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
