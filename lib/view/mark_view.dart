import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fantadiv/viewmodels/mark_viewmodel.dart';
import 'package:fantadiv/view/player_linking_view.dart';

import '../viewmodels/file_picker_viewmodel.dart';

class MarkView extends StatelessWidget {
  const MarkView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarkViewModel(context.read<FilePickerViewModel>()),
      child: const _MarkView(),
    );
  }
}

class _MarkView extends StatelessWidget {
  const _MarkView();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MarkViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Importazione Automatica')),
      body: Center(
        child: vm.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: () async {
            await vm.startAutoImport(
              onPlayerNotFound: (name) async {
                final selected = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerLinkingView(
                      searchName: name,
                      allPlayers: vm.allPlayers,
                    ),
                  ),
                );
                return selected;
              },
            );
          },
          child: const Text('Avvia Importazione'),
        ),
      ),
    );
  }
}
