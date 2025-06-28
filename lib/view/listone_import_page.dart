import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/listone_import_viewmodel.dart';

class ListoneImportView extends StatelessWidget {
  const ListoneImportView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ListoneImportViewModel>(context);

    return Center(
      child: viewModel.isLoading
          ? const CircularProgressIndicator(color: Colors.amber)
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Importa un file Excel", style: TextStyle(fontSize: 22, color: Colors.amber)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: viewModel.pickAndProcessFile,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: const Text("Scegli File"),
          ),
        ],
      ),
    );
  }
}
