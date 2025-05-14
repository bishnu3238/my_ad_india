import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/features/home/core/home_navigator.dart';

class WhatsNewPage extends StatefulWidget {
  const WhatsNewPage({super.key});

  @override
  State<WhatsNewPage> createState() => _WhatsNewPageState();
}

class _WhatsNewPageState extends State<WhatsNewPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WhatsNewItem> _whatsNewItems = [
    WhatsNewItem(
      title: "Redesigned Interface",
      description:
          "We've completely revamped our app with a fresh, modern design for an even better user experience.",
      icon: Icons.design_services,
      color: Colors.blue,
    ),
    WhatsNewItem(
      title: "New Features",
      description:
          "Enjoy powerful new tools and capabilities to help you get more done with less effort.",
      icon: Icons.auto_awesome,
      color: Colors.purple,
    ),
    WhatsNewItem(
      title: "Performance Improvements",
      description:
          "Experience faster load times and smoother animations throughout the app.",
      icon: Icons.speed,
      color: Colors.green,
    ),
    WhatsNewItem(
      title: "Dark Mode",
      description:
          "New dark theme option to reduce eye strain and save battery life.",
      icon: Icons.dark_mode,
      color: Colors.indigo,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "What's New",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to home screen or close the what's new page
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const DummyHomePage(),
                        ),
                      );
                    },
                    child: const Text("Skip"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _whatsNewItems.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildFeaturePage(_whatsNewItems[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _whatsNewItems.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 8,
                        width: index == _currentPage ? 24 : 8,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color:
                              index == _currentPage
                                  ? _whatsNewItems[_currentPage].color
                                  : Colors.grey.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // Next/Done button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _whatsNewItems.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      } else {
                        // Last page, navigate to home screen
                        context.go(HomeRoute.home);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _whatsNewItems[_currentPage].color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _currentPage < _whatsNewItems.length - 1
                          ? "Next"
                          : "Get Started",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePage(WhatsNewItem item) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Feature illustration or icon
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 100, color: item.color),
          ),
          const SizedBox(height: 40),
          // Feature title
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: item.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Feature description
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Model class for What's New items
class WhatsNewItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  WhatsNewItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// Dummy Home Page to navigate to after What's New
class DummyHomePage extends StatelessWidget {
  const DummyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to your app!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show What's New page again for demo purposes
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const WhatsNewPage()),
                );
              },
              child: const Text('Show What\'s New Again'),
            ),
          ],
        ),
      ),
    );
  }
}
