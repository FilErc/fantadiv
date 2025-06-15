import 'package:fantadiv/view/squad_maker_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import 'profile_page.dart';
import 'hub_page.dart';
import 'match_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            );
          }

          List<Widget> defaultPages = [
            HomeContent(),
            HubPage(),
            ProfilePage(),
          ];
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "FANTADIV",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.amber,
              elevation: 5,
            ),
            body: Container(
              color: Colors.black,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(viewModel.selectedIndex),
                  child: defaultPages[viewModel.selectedIndex],
                ),
              ),
            ),
            bottomNavigationBar: _buildNavBar(viewModel),
          );
        },
      ),
    );
  }

  BottomNavigationBar _buildNavBar(HomeViewModel viewModel) {
    List<BottomNavigationBarItem> userItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home, size: 28),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_view_day, size: 28),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person, size: 28),
        label: '',
      ),
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: userItems,
      currentIndex: viewModel.selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[600],
      backgroundColor: Colors.amber,
      elevation: 10,
      onTap: (index) => viewModel.updateSelectedIndex(index),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController(viewportFraction: 0.7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<HomeViewModel>(context, listen: false);
      final index = vm.firstIncompleteIndex;
      if (index != -1) {
        _pageController.jumpToPage(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.black],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: !viewModel.isCountdownReady
              ? const CircularProgressIndicator(color: Colors.amber)
              : viewModel.allRounds.isNotEmpty
              ? Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: viewModel.allRounds.length,
                  itemBuilder: (context, index) {
                    final round = viewModel.allRounds[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: 230,
                        height: 180,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Giornata ${round.day}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: round.matches.length,
                                itemBuilder: (context, matchIndex) {
                                  final match = round.matches[matchIndex];

                                  String backgroundImage;
                                  if (match.gT1 < match.gT2) {
                                    backgroundImage = "images/WvL.png";
                                  } else if (match.gT1 > match.gT2) {
                                    backgroundImage = "images/LvW.png";
                                  } else {
                                    backgroundImage = "images/Draw.png";
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MatchDetailsPage(),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.black, width: 1.5),
                                          image: DecorationImage(
                                            image: AssetImage(backgroundImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${match.team1} vs ${match.team2}",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SquadMakerPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Inserisci formazione',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                viewModel.countdown,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
              : const Center(
            child: Text(
              'No rounds available yet!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
