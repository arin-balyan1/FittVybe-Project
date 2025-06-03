import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(TrainerDashboardApp());
}

class TrainerDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trainer Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      ),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  bool isDarkMode = false;
  int selectedDateIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final List<Map<String, dynamic>> todaysBookings = [
    {'name': 'Arin Balyan', 'time': '10:00 AM', 'duration': '1 hour', 'day': 0, 'type': 'Weight Training', 'status': 'confirmed'},
    {'name': 'Soonam Kumari', 'time': '11:30 AM', 'duration': '45 mins', 'day': 0, 'type': 'Cardio Session', 'status': 'confirmed'},
    {'name': 'Prashasti', 'time': '02:00 PM', 'duration': '1 hour', 'day': 0, 'type': 'Personal Training', 'status': 'confirmed'},
    {'name': 'Aryan Singh', 'time': '04:30 PM', 'duration': '30 mins', 'day': 0, 'type': 'Yoga Session', 'status': 'confirmed'},
  ];

  List<Map<String, dynamic>> sessionRequests = [
    {
      'id': 1,
      'name': 'Vikash Kumar',
      'time': '06:00 PM',
      'date': 'Today',
      'day': 0,
      'duration': '1 hour',
      'type': 'Weight Training',
      'avatar': 3,
      'price': '₹800',
    },
    {
      'id': 2,
      'name': 'Ananya Sharma',
      'time': '07:30 PM',
      'date': 'Tomorrow',
      'day': 1,
      'duration': '45 mins',
      'type': 'Cardio Session',
      'avatar': 4,
      'price': '₹600',
    },
    {
      'id': 3,
      'name': 'Rohit Singh',
      'time': '08:00 AM',
      'date': 'Tomorrow',
      'day': 1,
      'duration': '30 mins',
      'type': 'Yoga Session',
      'avatar': 5,
      'price': '₹400',
    },
  ];

  final List<String> weekDates = [
    'Mon\n15',
    'Tue\n16',
    'Wed\n17',
    'Thu\n18',
    'Fri\n19',
    'Sat\n20',
    'Sun\n21',
  ];

  // Enhanced stats tracking
  Map<String, dynamic> weeklyStats = {
    'earnings': 12450,
    'sessions': 28,
    'clients': 15,
    'rating': 4.8,
  };

  List<int> slotsPerDay = [4, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationBottomSheet(
        sessionRequests: sessionRequests,
        onAccept: _acceptSessionRequest,
        onReject: _rejectSessionRequest,
        isDarkMode: isDarkMode,
      ),
    );
  }

  void _acceptSessionRequest(int requestId) {
    setState(() {
      final request = sessionRequests.firstWhere((req) => req['id'] == requestId);
      todaysBookings.add({
        'name': request['name'],
        'time': request['time'],
        'duration': request['duration'],
        'day': request['day'],
        'type': request['type'],
        'status': 'confirmed',
      });

      slotsPerDay[request['day']] = (slotsPerDay[request['day']] ?? 0) + 1;
      sessionRequests.removeWhere((req) => req['id'] == requestId);

      // Update earnings
      weeklyStats['earnings'] += int.parse(request['price'].replaceAll('₹', '').replaceAll(',', ''));
      weeklyStats['sessions'] += 1;
    });

    _showSnackBar('Session request accepted! 🎉', Colors.green);
  }

  void _rejectSessionRequest(int requestId) {
    setState(() {
      sessionRequests.removeWhere((req) => req['id'] == requestId);
    });
    _showSnackBar('Session request rejected', Colors.orange);
  }

  void _addNewSlot(Map<String, dynamic> newSlot) {
    setState(() {
      todaysBookings.add({
        'name': 'Available Slot',
        'time': newSlot['time'],
        'duration': newSlot['duration'],
        'day': newSlot['day'],
        'type': 'Open Slot',
        'status': 'available',
      });
      slotsPerDay[newSlot['day']] = (slotsPerDay[newSlot['day']] ?? 0) + 1;
    });
    _showSnackBar('New slot added successfully! 🕒', Colors.green);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark().copyWith(useMaterial3: true) : ThemeData.light().copyWith(useMaterial3: true),
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          title: Row(
            children: [
              Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${getGreeting()}, Ayush!',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Ready to train today? 💪',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(isDarkMode),
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onPressed: _showNotifications,
                ),
                if (sessionRequests.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${sessionRequests.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeController,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Profile Status Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.verified, color: Colors.white, size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Your profile is complete and verified',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Enhanced Stats Grid
                // Enhanced Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8, // Reduced spacing
                  mainAxisSpacing: 8, // Reduced spacing
                  childAspectRatio: 1, // More square aspect ratio
                  children: [
                    _buildStatCard(
                      'Weekly Earnings',
                      '₹${NumberFormat('#,##,###').format(weeklyStats['earnings'])}',
                      Icons.trending_up,
                      Colors.blue,
                      '+15%',
                    ),
                    _buildStatCard(
                      'Total Sessions',
                      '${weeklyStats['sessions']}',
                      Icons.fitness_center,
                      Colors.orange,
                      '+3',
                    ),
                    _buildStatCard(
                      'Active Clients',
                      '${weeklyStats['clients']}',
                      Icons.people,
                      Colors.purple,
                      '+2',
                    ),
                    _buildStatCard(
                      'Rating',
                      '${weeklyStats['rating']} ⭐',
                      Icons.star,
                      Colors.green,
                      '4.8/5',
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Enhanced Next Session Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.schedule, color: Colors.purple, size: 20),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Next Session',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Starting Soon',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (todaysBookings.isNotEmpty) ...[
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage('images/profile_1.png'),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    todaysBookings[0]['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${todaysBookings[0]['time']} • ${todaysBookings[0]['type']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Icon(Icons.access_time, color: Colors.purple, size: 20),
                                Text(
                                  todaysBookings[0]['duration'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ] else ... [
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.event_available, size: 40, color: Colors.grey[400]),
                              SizedBox(height: 8),
                              Text(
                                'No upcoming sessions',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Enhanced Calendar View
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _showSnackBar('Calendar view coming soon! 📅', Colors.blue);
                      },
                      icon: Icon(Icons.calendar_today, size: 16),
                      label: Text('View All'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekDates.length,
                    itemBuilder: (context, index) {
                      bool isSelected = index == selectedDateIndex;
                      int slotsCount = slotsPerDay[index] ?? 0;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDateIndex = index;
                          });
                          _slideController.forward().then((_) {
                            _slideController.reset();
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 70,
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue
                                : (isDarkMode ? Colors.grey[800] : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: isSelected ? 8 : 4,
                                offset: Offset(0, isSelected ? 4 : 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weekDates[index].split('\n')[0],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDarkMode ? Colors.white : Colors.black87),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                weekDates[index].split('\n')[1],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDarkMode ? Colors.white : Colors.black87),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (slotsCount > 0) ...[
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$slotsCount slot${slotsCount > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.blue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 24),

                // Enhanced Bookings Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDateIndex == 0 ? 'Today\'s Bookings' : '${weekDates[selectedDateIndex].split('\n')[0]} Bookings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showSnackBar('All bookings view coming soon! 📋', Colors.blue);
                      },
                      child: Text('View All'),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Filter and display bookings
                ...todaysBookings.where((booking) => booking['day'] == selectedDateIndex)
                    .map((booking) => SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutQuart,
                  )),
                  child: _buildBookingCard(booking),
                ))
                    .toList(),

                if (todaysBookings.where((booking) => booking['day'] == selectedDateIndex).isEmpty)
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text(
                            'No bookings scheduled',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Add some slots to get started!',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 24),

                // Enhanced Add Slot Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddSlotScreen(
                            onSlotAdded: _addNewSlot,
                            weekDates: weekDates,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Add New Slot',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: EdgeInsets.all(10), // Reduced padding
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Lighter shadow
            blurRadius: 4, // Smaller blur
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4), // Reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18), // Smaller icon
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4), // Reduced spacing
          Text(
            value,
            style: TextStyle(
              fontSize: 18, // Smaller font size
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 2), // Minimal spacing
          Text(
            title,
            style: TextStyle(
              fontSize: 11, // Smaller font size
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor = booking['status'] == 'available' ? Colors.blue : Colors.green;
    String statusText = booking['status'] == 'available' ? 'Available' : 'Confirmed';

    return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
          CircleAvatar(
          radius: 24,
          backgroundColor: statusColor.withOpacity(0.1),
            backgroundImage: booking['status'] != 'available'
                ? AssetImage('images/profile_${(booking['name'].hashCode % 5) + 1}.png')
                : null,
          child: booking['status'] == 'available'
              ? Icon(Icons.event_available, color: statusColor)
              : null,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking['name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    booking['time'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    booking['duration'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (booking['type'] != null) ...[
                SizedBox(height: 4),
                Text(
                  booking['type'],
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
    color: statusColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
    statusText,
    style: TextStyle(
    color: statusColor,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    ),
    ),
        ),
          ],
        ),
    );
  }
}

class NotificationBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> sessionRequests;
  final Function(int) onAccept;
  final Function(int) onReject;
  final bool isDarkMode;

  const NotificationBottomSheet({
    Key? key,
    required this.sessionRequests,
    required this.onAccept,
    required this.onReject,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Session Requests',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${sessionRequests.length} new',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: sessionRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All caught up! 🎉',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: sessionRequests.length,
              itemBuilder: (context, index) {
                final request = sessionRequests[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage('assets/images/profile_1.png'),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${request['type']} • ${request['price']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            '${request['date']} at ${request['time']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            request['duration'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                onAccept(request['id']);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 18),
                                  SizedBox(width: 8),
                                  Text('Accept'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                onReject(request['id']);
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close, size: 18),
                                  SizedBox(width: 8),
                                  Text('Reject'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddSlotScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSlotAdded;
  final List<String> weekDates;

  const AddSlotScreen({
    Key? key,
    required this.onSlotAdded,
    required this.weekDates,
  }) : super(key: key);

  @override
  _AddSlotScreenState createState() => _AddSlotScreenState();
}

class _AddSlotScreenState extends State<AddSlotScreen> {
  int _selectedDayIndex = 0;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedDuration = '30 mins';
  final List<String> _durationOptions = ['30 mins', '45 mins', '1 hour', '1.5 hours', '2 hours'];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addSlot() {
    final formattedTime = DateFormat('hh:mm a').format(
      DateTime(2023, 1, 1, _selectedTime.hour, _selectedTime.minute),
    );

    final newSlot = {
      'day': _selectedDayIndex,
      'time': formattedTime,
      'duration': _selectedDuration,
    };

    widget.onSlotAdded(newSlot);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Slot'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.weekDates.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                    child: Container(
                      width: 70,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: _selectedDayIndex == index
                            ? Colors.blue
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          widget.weekDates[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedDayIndex == index
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Select Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.blue),
                    SizedBox(width: 12),
                    Text(
                      _selectedTime.format(context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDuration,
              items: _durationOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedDuration = newValue!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _addSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Add Slot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}