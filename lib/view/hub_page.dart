import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../viewmodels/file_picker_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import 'listone_view.dart';
import 'mark_view.dart';
import 'calendar_page.dart';

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  Widget? selectedPage;

  final List<_PageConfig> pages = [
    _PageConfig(title: 'Generatore Manuale', builder: (context) => const ManualViewWrapper()),
    _PageConfig(title: 'Visualizza listone', builder: (context) => const AlternativeViewWrapper()),
    _PageConfig(title: 'Importa i voti', builder: (context) => const MarksGetterViewWrapper()),
    // Aggiungi qui nuove pagine:
    // _PageConfig(title: 'NomePagina', builder: (context) => NomeView()),
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<HomeViewModel>().isAdmin;

    // Mostra solo "Visualizza listone" per i non-admin
    final visiblePages = pages.where((page) {
      if (page.title == 'Visualizza listone') return true;
      return isAdmin;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: selectedPage == null
          ? _buildPageSelector(visiblePages)
          : selectedPage!,
    );
  }

  Widget _buildPageSelector(List<_PageConfig> visiblePages) {
    return Column(
      children: visiblePages.map((page) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedPage = page.builder(context);
              });
            },
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                page.title,
                style: const TextStyle(color: Colors.amber, fontSize: 24),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PageConfig {
  final String title;
  final WidgetBuilder builder;

  _PageConfig({required this.title, required this.builder});
}

// Wrappers per includere i Provider

class ManualViewWrapper extends StatelessWidget {
  const ManualViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(),
      child: Consumer<CalendarViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          backgroundColor: Colors.black,
          body: CalendarView(viewModel: viewModel),
        ),
      ),
    );
  }
}

class AlternativeViewWrapper extends StatelessWidget {
  const AlternativeViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FilePickerViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: const ListoneView(),
      ),
    );
  }
}

class MarksGetterViewWrapper extends StatelessWidget {
  const MarksGetterViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FilePickerViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Importa i voti'),
          backgroundColor: Colors.grey[900],
        ),
        body: const MarkView(),
      ),
    );
  }
}
