import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fantadiv/viewmodels/mark_viewmodel.dart';
import 'package:fantadiv/view/player_linking_view.dart';

import '../models/players.dart';
import '../viewmodels/file_picker_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

class MarkView extends StatelessWidget {
  const MarkView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MarkViewModel(context.read<FilePickerViewModel>()),
        ),
        ChangeNotifierProvider.value(value: context.read<HomeViewModel>()),
      ],
      child: const _MarkView(),
    );
  }
}

class _MarkView extends StatelessWidget {
  const _MarkView();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MarkViewModel>(context);
    final homeVM = Provider.of<HomeViewModel>(context);
    final rounds = homeVM.allRounds;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (vm.missingPlayerName != null &&
          vm.onResolvePlayer != null &&
          vm.isResolvingPlayer) {
        vm.isResolvingPlayer = false;
        final selected = await Navigator.push<Players>(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerLinkingView(
              searchName: vm.missingPlayerName!,
              allPlayers: vm.allPlayers,
            ),
          ),
        );
        vm.onResolvePlayer?.call(selected);
      }
    });


    return Scaffold(
      backgroundColor: Colors.black,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: rounds.length,
        itemBuilder: (context, index) {
          final round = rounds[index];
          final giornata = index + 1;
          final isCompleted = round.boolean;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 120),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.green : Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                onPressed: () async {
                  await vm.startAutoImport(
                    giornata: giornata,
                    onPlayerNotFound: (_) async => null, // ora ignorato
                  );
                },
                child: Text(
                  'Importa Giornata $giornata',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
