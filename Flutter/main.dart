import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  runApp(const MyApp());
}
// ------------------- MY APP -------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AROGA",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashScreen(), // Show splash screen first
      routes: {
        '/login': (context) => LoginPage(),
        '/main': (context) => const MainLayout(),
      },
    );
  }
}

// ------------------- SPLASH SCREEN -------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _fadeController.forward();
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF76C893), // soft green
              Color(0xFFB9FBC0), // light mint
              Color(0xFFFFF3B0), // soft yellow
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circle Logo
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png', // your logo
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // App Name & Tagline
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: const [
                        Text(
                          'AROGA',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32), // dark green
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Healthy Plants, Happy Life',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1B5E20), // slightly darker green
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- LOGIN PAGE -------------------
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  String correctUser = "123";
  String correctPass = "123";

  void login() {
    if (userController.text == correctUser &&
        passController.text == correctPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Username or Password")),
      );
    }
  }

  void googleLogin() {
    // Placeholder for Google Sign-In
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF76C893), // soft green
              Color(0xFFB9FBC0), // light mint
              Color(0xFFFFF3B0), // soft yellow
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/logo.png"),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 20),
                const Text(
                  "AROGA",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green, // changed to green
                  ),
                ),
                const SizedBox(height: 40),

                // Username
                TextField(
                  controller: userController,
                  decoration: InputDecoration(
                    hintText: "Email id / Phone no.",
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Password
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // OR Divider
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                // Continue with Google Button
                OutlinedButton.icon(
                  onPressed: googleLogin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black26),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white.withOpacity(0.9),
                  ),
                  icon: Image.network(
                    'https://img.icons8.com/color/48/google-logo.png',
                    height: 24,
                    width: 24,
                  ),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- MAIN LAYOUT WITH NAVIGATION -------------------
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    StatusPage(),
    Placeholder(), // Camera placeholder
    MorePage(), // More page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.check_circle), label: "Status"),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.camera), label: "Camera"),
            BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz), label: "More"),
          ],
        ),
      ),
    );
  }
}

// ------------------- HOME PAGE -------------------

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example user name
    final String userName = "P"; // you can pass this dynamically later

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade600,
        title: Row(
          children: [
            // App Logo
            ClipOval(
              child: Image.asset(
                "assets/logo.png", // replace with your logo
                fit: BoxFit.cover,
                height: 44,
                width: 44,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "AROGA Dashboard",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------- Welcome Section -------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Welcome Back 👋",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "\"Healthy soil, healthy plants, healthy life.\"",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                  // Avatar with letter P
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF63C5DA), // professional teal color
                    child: Text(
                      "P", // letter P for Pankaj
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),

              // ------------------- Sensor Section -------------------
              const Text(
                "🌡 Sensor Data",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildSensorCard(
                          "Humidity", "74%", Colors.blueAccent, Icons.water_drop)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildSensorCard(
                          "Temperature", "32°C", Colors.redAccent, Icons.thermostat)),
                ],
              ),
              const SizedBox(height: 12),
              _buildSensorCard("Light Intensity", "323 lx", Colors.orangeAccent,
                  Icons.light_mode,
                  fullWidth: true),
              const SizedBox(height: 25),
              const Divider(),

              // ------------------- Weather Section -------------------
              const Text(
                "☁ Weather Forecast",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 12),
              _buildWeatherCard(),
              const SizedBox(height: 25),
              const Divider(),

              // ------------------- Tips Section -------------------
              const Text(
                "🌱 Tip",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient:
                  const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF76C893)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "🌱 Regular monitoring of soil moisture can boost crop yield!",
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 25),
              const Divider(),

              // ------------------- Alerts Section -------------------
              const Text(
                "⚠ Alerts",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 5,
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: const [
                      Icon(Icons.pest_control, color: Colors.red, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text("Pesticide spray required soon!",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- Sensor Card -------------------
  Widget _buildSensorCard(String title, String value, Color color, IconData icon,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54)),
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------- Weather Card -------------------
  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF76C893), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cloud_queue, size: 40, color: Colors.white),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("34°",
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 2),
                  Text("Overcast Clouds",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 2),
                  Text("Jaipur",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildWeatherDay("Mon", "30°", Icons.wb_sunny, Colors.orange),
                _buildWeatherDay("Tue", "32°", Icons.cloud, Colors.white),
                _buildWeatherDay("Wed", "29°", Icons.cloud_queue, Colors.white70),
                _buildWeatherDay("Thu", "34°", Icons.wb_sunny, Colors.orange),
                _buildWeatherDay("Fri", "28°", Icons.grain, Colors.lightBlueAccent),
                _buildWeatherDay("Sat", "31°", Icons.cloud, Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- Weather Day Tile -------------------
  Widget _buildWeatherDay(String day, String temp, IconData icon, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(temp,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}


// ------------------- STATUS PAGE -------------------
class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  Widget _buildConfidenceCircle(double confidence, Color color) {
    return CircularPercentIndicator(
      radius: 38.0,
      lineWidth: 6.0,
      percent: confidence / 100,
      center: Text(
        "${confidence.toInt()}%",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      progressColor: color,
      backgroundColor: Colors.grey.shade200,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Row(
          children: [
            // ✅ App Logo in Circle
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage("assets/logo.png"), // <-- Add your logo here
            ),
            const SizedBox(width: 10),
            const Text(
              "Plant Status",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, // ✅ Changed text color to white
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.settings, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Current Section
            const Text("Current Condition",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 12),
            _buildStatusCard("🌿 Virus Detected: Tungro", 90,
                "assets/plant1.jpg", Colors.blue),

            const SizedBox(height: 12),

            // ✅ Last Scan Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: const [
                  Icon(Icons.access_time, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    "Latest Scan: 29 Sept 2025, 10:45 AM",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.green),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ✅ Quick Overview Section (All in one row, compact size)
            const Text("Quick Overview",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTinyOverviewCard(
                    "Healthy", "60%", Icons.eco, Colors.teal),
                _buildTinyOverviewCard(
                    "Infected", "40%", Icons.warning, Colors.red),
                _buildTinyOverviewCard(
                    "Scans", "25", Icons.qr_code_scanner, Colors.blue),
                _buildTinyOverviewCard(
                    "Alerts", "3", Icons.error, Colors.orange),
              ],
            ),

            const SizedBox(height: 25),

            // ✅ History Section
            const Text("History",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 15),
            _buildTimelineTile("Today", "Virus: Hispa", 75, "29 Sept 2025, 10:45 AM",
                "assets/plant2.jpg", Colors.orange),
            _buildTimelineTile("Yesterday", "Virus: Tungro", 80,
                "28 Sept 2025, 5:20 PM", "assets/plant3.jpg", Colors.teal),
          ],
        ),
      ),
    );
  }

  // ✅ Status Card
  Widget _buildStatusCard(
      String title, double confidence, String imagePath, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath,
                  height: 70, width: 70, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          _buildConfidenceCircle(confidence, color),
        ],
      ),
    );
  }

  // ✅ Tiny Quick Overview Card (smaller & fits in one line)
  Widget _buildTinyOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // ✅ Timeline Tile (Full width history card with date)
  Widget _buildTimelineTile(String day, String virus, double confidence,
      String date, String imagePath, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
            ),
            Container(width: 2, height: 80, color: Colors.green),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(imagePath,
                        height: 65, width: 65, fit: BoxFit.cover)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      const SizedBox(height: 4),
                      Text(virus, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(date,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ),
                _buildConfidenceCircle(confidence, color),
              ],
            ),
          ),
        )
      ],
    );
  }
}
// ------------------- MORE PAGE -------------------
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("More Options"),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ------------------- User Profile Section -------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF63C5DA), // same as HomePage
                    child: Text(
                      "P", // letter P for Pankaj
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Pankaj Kumar",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Pankajkumar2734@gmail.com",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, color: Colors.white))
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ------------------- Options Section -------------------
            _buildOptionCard(
              context,
              icon: Icons.settings,
              iconColor: Colors.green,
              title: "Settings",
              subtitle: "Manage app preferences",
              onTap: () {
                // Navigate to Settings page
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.language,
              iconColor: Colors.purple,
              title: "Language",
              subtitle: "Select your preferred language",
              onTap: () {
                // Handle language selection
                _showLanguageDialog(context);
              },
            ),
            _buildOptionCard(
              context,
              icon: Icons.info,
              iconColor: Colors.blue,
              title: "About",
              subtitle: "Learn more about this app",
              onTap: () {},
            ),
            _buildOptionCard(
              context,
              icon: Icons.help,
              iconColor: Colors.orange,
              title: "Help & Support",
              subtitle: "Get assistance and support",
              onTap: () {},
            ),
            _buildOptionCard(
              context,
              icon: Icons.logout,
              iconColor: Colors.red,
              title: "Logout",
              subtitle: "Sign out of your account",
              onTap: () {
                // Navigate to your existing LoginPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // replace with your LoginPage
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon,
        required Color iconColor,
        required String title,
        String? subtitle,
        required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [iconColor.withOpacity(0.2), iconColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        )
            : null,
        trailing:
        const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ------------------- Language Dialog -------------------
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English"),
                onTap: () {
                  Navigator.pop(ctx);
                  // Handle English selection
                },
              ),
              ListTile(
                title: const Text("Hindi"),
                onTap: () {
                  Navigator.pop(ctx);
                  // Handle Hindi selection
                },
              ),
              ListTile(
                title: const Text("Punjabi"),
                onTap: () {
                  Navigator.pop(ctx);
                  // Handle Punjabi selection
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
