import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../viewmodels/auction_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/listone_display_viewmodel.dart';
import 'listone_import_page.dart';
import '../viewmodels/listone_import_viewmodel.dart';
import '../viewmodels/time_viewmodel.dart';
import 'auction_page.dart';
import 'calendar_page.dart';
import 'listone_display_page.dart';
import 'mark_page.dart';
import 'time_page.dart';

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  Widget? selectedPage;

  final List<_PageConfig> pages = [
    _PageConfig(title: 'Generatore Manuale', builder: (context) => const ManualViewWrapper(), icon: Icons.calendar_today,),
    _PageConfig(title: 'Visualizza Listone', builder: (_) => const ListoneDisplayWrapper(), icon: Icons.list),
    _PageConfig(title: 'Importa i voti', builder: (context) => const MarksGetterViewWrapper(), icon: Icons.upload_file,),
    _PageConfig(title: 'Asta del Fantacalcio', builder: (context) => const AuctionViewWrapper(), icon: Icons.sports_soccer,),
    _PageConfig(title: 'Imposta orario', builder: (context) => const TimeViewWrapper(), icon: Icons.access_time,),
    _PageConfig(title: 'Aggiorna Listone', builder: (_) => const ListoneImportWrapper(), icon: Icons.upload_file),
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<HomeViewModel>().isAdmin;

    final visiblePages = pages.where((page) {
      const publicPages = ['Visualizza listone', 'Asta del Fantacalcio'];
      return publicPages.contains(page.title) || isAdmin;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: selectedPage == null
          ? _buildPageSelector(visiblePages)
          : selectedPage!,
    );
  }

  Widget _buildPageSelector(List<_PageConfig> visiblePages) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: visiblePages.map((page) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedPage = Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.amber,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          selectedPage = null;
                        });
                      },
                    ),
                  ),
                  body: page.builder(context),
                );
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(page.icon, size: 48, color: Colors.amber),
                  const SizedBox(height: 12),
                  Text(
                    page.title,
                    style: const TextStyle(color: Colors.amber, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PageConfig {
  final String title;
  final WidgetBuilder builder;
  final IconData icon;

  _PageConfig({
    required this.title,
    required this.builder,
    required this.icon,
  });
}

// View Wrappers

class ManualViewWrapper extends StatelessWidget {
  const ManualViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(),
      child: Consumer<CalendarViewModel>(
        builder: (context, viewModel, child) =>
            CalendarView(viewModel: viewModel),
      ),
    );
  }
}

class ListoneImportWrapper extends StatelessWidget {
  const ListoneImportWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListoneImportViewModel(),
      child: const ListoneImportView(),
    );
  }
}

class ListoneDisplayWrapper extends StatelessWidget {
  const ListoneDisplayWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListoneDisplayViewModel()..loadPlayers(),
      child: const ListoneView(),
    );
  }
}


class MarksGetterViewWrapper extends StatelessWidget {
  const MarksGetterViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListoneDisplayViewModel(),
      child: const MarkView(),
    );
  }
}

class AuctionViewWrapper extends StatelessWidget {
  const AuctionViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuctionViewModel(),
      child: const AuctionPage(),
    );
  }
}

class TimeViewWrapper extends StatelessWidget {
  const TimeViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimeViewModel(),
      child: Consumer<TimeViewModel>(
        builder: (context, viewModel, child) =>
            TimeView(viewModel: viewModel),
      ),
    );
  }
}
