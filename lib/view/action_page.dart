import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auction_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

class AuctionPage extends StatelessWidget {
  const AuctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<HomeViewModel>().isAdmin;

    return ChangeNotifierProvider(
      create: (_) => AuctionViewModel(),
      child: AuctionPageContent(isAdmin: isAdmin),
    );
  }
}

class AuctionPageContent extends StatelessWidget {
  final bool isAdmin;
  const AuctionPageContent({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuctionViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(8, (colIndex) {
            final totalUsed = viewModel.getTotalSpent(colIndex);
            final freeSlots = viewModel.getEmptySlots(colIndex);
            final remaining = 500 - totalUsed;
            final minimumRequired = freeSlots;
            final spendable = (remaining - minimumRequired).clamp(0, 999);

            return Container(
              width: 260,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (!isAdmin)
                      const Text(
                        "Solo gli admin possono modificare",
                        style: TextStyle(color: Colors.amber),
                      ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: viewModel.selectedSquads[colIndex],
                      dropdownColor: Colors.grey[900],
                      hint: const Text("Seleziona squadra", style: TextStyle(color: Colors.amber)),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                      items: viewModel.allSquads.map((squad) => DropdownMenuItem(
                        value: squad,
                        child: Text(squad, style: const TextStyle(color: Colors.white)),
                      )).toList(),
                      onChanged: isAdmin
                          ? (value) => viewModel.selectSquad(colIndex, value)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    ..._buildRoleSection("P", 3, colIndex, viewModel, isAdmin),
                    ..._buildRoleSection("D", 8, colIndex, viewModel, isAdmin),
                    ..._buildRoleSection("C", 8, colIndex, viewModel, isAdmin),
                    ..._buildRoleSection("A", 6, colIndex, viewModel, isAdmin),
                    const SizedBox(height: 10),
                    Text(
                      "Crediti residui: $spendable",
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<Widget> _buildRoleSection(
      String role,
      int count,
      int colIndex,
      AuctionViewModel viewModel,
      bool isAdmin,
      ) {
    return List.generate(count, (rowIndex) {
      final controller = viewModel.controllers[colIndex][role]![rowIndex];
      final priceController = viewModel.prices[colIndex][role]![rowIndex];
      final focusNode = viewModel.focusNodes[colIndex][role]![rowIndex];
      final priceFocusNode = viewModel.priceFocusNodes[colIndex][role]![rowIndex];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: !isAdmin,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: role,
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: _color(role).withOpacity(0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: TextField(
                controller: priceController,
                focusNode: priceFocusNode,
                keyboardType: TextInputType.number,
                readOnly: !isAdmin,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "€",
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[700],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      );
    });
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
