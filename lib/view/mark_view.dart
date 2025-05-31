import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mark_viewmodel.dart';

class MarkView extends StatelessWidget {
  const MarkView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarkViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Importa Voti Fantapazz'),
        ),
        body: Consumer<MarkViewModel>(
          builder: (context, vm, _) {
            return Center(
              child: vm.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: () {
                  vm.fetchAndStoreAllPages();
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text('Avvia Importazione'),
              ),
            );
          },
        ),
      ),
    );
  }
}
