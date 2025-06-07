import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fantadiv/viewmodels/mark_viewmodel.dart';

class MarkView extends StatelessWidget {
  const MarkView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarkViewModel(),
      child: const _MarkView(),
    );
  }
}

class _MarkView extends StatelessWidget {
  const _MarkView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MarkViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Importazione Automatica')),
      body: Center(
        child: vm.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: () => vm.startAutoImport(),
          child: const Text('Avvia Importazione'),
        ),
      ),
    );
  }
}
