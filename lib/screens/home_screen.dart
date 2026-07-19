import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cdegad_kp/screens/downloads/downloads_screen.dart';
import 'package:cdegad_kp/screens/alerts/alerts_screen.dart';
import 'package:cdegad_kp/screens/profile/profile_screen.dart';
import 'package:cdegad_kp/screens/records/records_view_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _show35MonthAlert = false;

  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _loadingController;
  late AnimationController _headerAnimationController;
  late List<AnimationController> _cardControllers;

  late Animation<double> _fabAnimation;
  late Animation<double> _searchAnimation;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late List<Animation<double>> _cardAnimations;

  final List<Map<String, dynamic>> features = [
    {
      "icon": Icons.folder,
      "title": "CD",
      "subtitle": "Community Development",
      "color": Colors.teal,
      "gradient": const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      "description": "Manage community development initiatives"
    },
    {
      "icon": Icons.extension,
      "title": "Extension",
      "subtitle": "Forest Extension",
      "color": Colors.blue,
      "gradient": const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF0D47A1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      "description": "Forest extension activities and programs"
    },
    {
      "icon": Icons.business,
      "title": "GAD",
      "subtitle": "Gender and Community",
      "color": Colors.purple,
      "gradient": const LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      "description": "Gender and community development"
    },
    {
      "icon": Icons.people,
      "title": "HR",
      "subtitle": "Human Resources",
      "color": Colors.orange,
      "gradient": const LinearGradient(colors: [Color(0xFFF57C00), Color(0xFFE65100)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      "description": "Manage HR and personnel"
    },
    {
      "icon": Icons.download,
      "title": "Downloads",
      "subtitle": "All Department Records",
      "color": Colors.green,
      "gradient": const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      "description": "All department records & files"
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _fabAnimationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _searchAnimationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _headerAnimationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOutBack));
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _searchAnimationController, curve: Curves.easeOutCubic));
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
    _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutBack));

    _cardControllers = List.generate(features.length, (index) => AnimationController(duration: const Duration(milliseconds: 400), vsync: this));
    _cardAnimations = _cardControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    }).toList();

    _startInitialLoadSequence();
  }

  void _startInitialLoadSequence() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    await _check35MonthAlert();
    
    setState(() => _isLoading = false);
    _loadingController.forward();
    _headerAnimationController.forward();
    _searchAnimationController.forward();
    _startStaggeredCardAnimations();
    _fabAnimationController.forward();
  }

  Future<void> _check35MonthAlert() async {
    final prefs = await SharedPreferences.getInstance();
    final installDateStr = prefs.getString('install_date');
    
    if (installDateStr == null) {
      await prefs.setString('install_date', DateTime.now().toIso8601String());
    } else {
      final installDate = DateTime.parse(installDateStr);
      final now = DateTime.now();
      final monthsDifference = (now.year - installDate.year) * 12 + now.month - installDate.month;
      
      if (monthsDifference >= 35) {
        setState(() => _show35MonthAlert = true);
      }
    }
  }

  void _startStaggeredCardAnimations() {
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 100)), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _loadingController.dispose();
    _headerAnimationController.dispose();
    _searchAnimationController.dispose();
    _fabAnimationController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFeatures = features.where((feature) =>
    feature["title"].toLowerCase().contains(searchQuery.toLowerCase()) ||
        feature["subtitle"].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white, Colors.grey.shade50],
          ),
        ),
        child: _isLoading ? _buildLoadingScreen() : _buildMainContent(filteredFeatures),
      ),
      drawer: _buildNavigationDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }


  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
            child: Icon(Icons.forest, color: Colors.green, size: 30),
          ),
          const SizedBox(height: 20),
          Text("Loading...", style: TextStyle(color: Colors.green.shade700, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMainContent(List<Map<String, dynamic>> filteredFeatures) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _showSnackBar("Content refreshed");
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight - 16),
            _buildUserGreeting(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 16),
            if (_show35MonthAlert) _build35MonthAlertCard(),
            const SizedBox(height: 24),
            _buildFeatureGrid(filteredFeatures),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGreeting() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerAnimation,
          child: SlideTransition(
            position: _headerSlideAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Welcome back!", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                            const Text("CDEGAD Directorate", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            const Text("Explore services and resources", style: TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                      Builder(
                        builder: (ctx) => GestureDetector(
                          onTap: () => Scaffold.of(ctx).openDrawer(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.menu, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white.withValues(alpha: 0.9), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text("Tap on any service to get started", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        final clamped = _searchAnimation.value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clamped,
          child: Opacity(opacity: clamped, child: child),
        );
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => searchQuery = v),
          decoration: InputDecoration(
            hintText: "Search services...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            suffixIcon: searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => searchQuery = ""); }) : null,
          ),
        ),
      ),
    );
  }

  Widget _build35MonthAlertCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "35 Months Alert!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Department review period completed. Please submit reports.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _show35MonthAlert = false),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(List<Map<String, dynamic>> filteredFeatures) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemCount: filteredFeatures.length,
      itemBuilder: (context, index) {
        final feature = filteredFeatures[index];
        final originalIndex = features.indexOf(feature);
        return AnimatedBuilder(
          animation: _cardAnimations[originalIndex],
          builder: (context, child) {
            return Transform.scale(scale: _cardAnimations[originalIndex].value, child: child);
          },
          child: _buildFeatureCard(feature),
        );
      },
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return GestureDetector(
      onTap: () {
        final title = feature["title"] as String;
        switch (title) {
          case "CD":
            Navigator.pushNamed(context, '/cd');
            break;
          case "Extension":
            Navigator.pushNamed(context, '/extension');
            break;
          case "GAD":
            Navigator.pushNamed(context, '/gad');
            break;
          case "HR":
            _showSnackBar("HR feature coming soon!");
            break;
          case "Downloads":
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DownloadsScreen()));
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: feature["gradient"] as LinearGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: (feature["color"] as Color).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(feature["icon"] as IconData, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                feature["title"] as String,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                feature["subtitle"] as String,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text("Recent Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
          child: Column(children: [
            _buildActivityItem(Icons.check_circle, "CD Form Submitted", "Community Development form", Colors.green),
            const Divider(),
            _buildActivityItem(Icons.edit, "GAD Form Updated", "Gender and Community form", Colors.blue),
            const Divider(),
            _buildActivityItem(Icons.upload, "Extension Data Uploaded", "Forest extension report", Colors.orange),
          ]),
        ),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String subtitle, Color color) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w600)), Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12))])),
    ]);
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.green.shade50])),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF43A047)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(30)), child: const Icon(Icons.account_circle, color: Colors.white, size: 40)),
                    const SizedBox(width: 16),
                    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("User Name", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("user@forest.gov", style: TextStyle(color: Colors.white, fontSize: 14)),
                    ]),
                  ]),
                ),
              ]),
            ),
            ListTile(leading: const Icon(Icons.home, color: Colors.green), title: const Text("Home"), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.folder, color: Colors.green), title: const Text("CD Forms"), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/cd'); }),
            ListTile(leading: const Icon(Icons.extension, color: Colors.green), title: const Text("Extension Forms"), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/extension'); }),
            ListTile(leading: const Icon(Icons.business, color: Colors.green), title: const Text("GAD Forms"), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/gad'); }),
            ListTile(leading: const Icon(Icons.people, color: Colors.green), title: const Text("Records"), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordsViewPage(formType: "All", gradient: [Colors.green, Colors.teal]))); }),
            ListTile(leading: const Icon(Icons.person, color: Colors.green), title: const Text("Profile"), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); }),
            ListTile(leading: const Icon(Icons.settings, color: Colors.green), title: const Text("Settings"), onTap: () { Navigator.pop(context); _showSnackBar("Settings Page - Coming Soon!"); }),
            const Divider(),
            ListTile(leading: Icon(Icons.logout, color: Colors.red.shade400), title: Text("Logout", style: TextStyle(color: Colors.red.shade400)), onTap: () { Navigator.pop(context); _showSnackBar("Logging Out..."); }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordsViewPage(formType: "All", gradient: [Colors.green, Colors.teal])));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertsScreen()));
            break;
          case 3:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Records"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton(
        onPressed: () => _showSnackBar("Add new form"),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green.shade600, behavior: SnackBarBehavior.floating));
  }
}