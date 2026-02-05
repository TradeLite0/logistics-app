import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';

/// Admin Dashboard - لوحة تحكم المشرف
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _screens = [
    const DriversTab(),
    const ComplaintsTab(),
    const UsersTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المشرف'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF667eea),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'السائقين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'الشكاوي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'المستخدمين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف',
          ),
        ],
      ),
    );
  }
}

/// Drivers Tab - عرض السائقين على الخريطة
class DriversTab extends StatefulWidget {
  const DriversTab({Key? key}) : super(key: key);

  @override
  State<DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends State<DriversTab> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  List<DriverLocation> _drivers = [];

  // Cairo default location
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
    _loadDriverLocations();
  }

  Future<void> _loadDriverLocations() async {
    setState(() => _isLoading = true);
    
    // TODO: Replace with actual API call
    // Mock data for demonstration
    await Future.delayed(const Duration(seconds: 1));
    
    _drivers = [
      DriverLocation(
        id: '1',
        name: 'أحمد محمد',
        phone: '01012345678',
        lat: 30.0444,
        lng: 31.2357,
        status: 'online',
        lastUpdated: DateTime.now(),
      ),
      DriverLocation(
        id: '2',
        name: 'محمد علي',
        phone: '01098765432',
        lat: 30.0500,
        lng: 31.2400,
        status: 'busy',
        lastUpdated: DateTime.now(),
      ),
      DriverLocation(
        id: '3',
        name: 'محمود حسن',
        phone: '01055556666',
        lat: 30.0380,
        lng: 31.2200,
        status: 'offline',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    _updateMarkers();
    setState(() => _isLoading = false);
  }

  void _updateMarkers() {
    _markers = _drivers.map((driver) {
      return Marker(
        markerId: MarkerId(driver.id),
        position: LatLng(driver.lat, driver.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          driver.status == 'online' 
              ? BitmapDescriptor.hueGreen 
              : driver.status == 'busy' 
                  ? BitmapDescriptor.hueOrange 
                  : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: driver.name,
          snippet: '${driver.phone} - ${_getStatusText(driver.status)}',
        ),
        onTap: () => _showDriverDetails(driver),
      );
    }).toSet();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'online':
        return 'متاح';
      case 'busy':
        return 'مشغول';
      case 'offline':
        return 'غير متصل';
      default:
        return 'غير معروف';
    }
  }

  void _showDriverDetails(DriverLocation driver) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF667eea),
                  child: Text(
                    driver.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        driver.phone,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(driver.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(driver.status),
                    style: TextStyle(
                      color: _getStatusColor(driver.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text(
                  'آخر تحديث: ${_formatTime(driver.lastUpdated)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Track driver
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('تتبع'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Call driver
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('اتصال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'offline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _defaultLocation,
            zoom: 13,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapToolbarEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (controller) => _mapController = controller,
        ),
        // Legend
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('متاح', Colors.green),
                const SizedBox(height: 8),
                _buildLegendItem('مشغول', Colors.orange),
                const SizedBox(height: 8),
                _buildLegendItem('غير متصل', Colors.red),
              ],
            ),
          ),
        ),
        // Refresh button
        Positioned(
          bottom: 100,
          right: 16,
          child: FloatingActionButton(
            onPressed: _loadDriverLocations,
            backgroundColor: const Color(0xFF667eea),
            child: const Icon(Icons.refresh),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

/// Complaints Tab - إدارة الشكاوى
class ComplaintsTab extends StatefulWidget {
  const ComplaintsTab({Key? key}) : super(key: key);

  @override
  State<ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<ComplaintsTab> {
  bool _isLoading = true;
  List<Complaint> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    _complaints = [
      Complaint(
        id: '1',
        title: 'تأخير في التوصيل',
        description: 'الشحنة متأخرة لمدة 3 أيام عن الموعد المحدد',
        type: 'delay',
        priority: 'high',
        status: 'pending',
        userName: 'أحمد محمد',
        userPhone: '01012345678',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Complaint(
        id: '2',
        title: 'تلف في البضاعة',
        description: 'وصلت البضاعة تالفة وغير صالحة للاستخدام',
        type: 'damage',
        priority: 'urgent',
        status: 'in_progress',
        userName: 'محمد علي',
        userPhone: '01098765432',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Complaint(
        id: '3',
        title: 'سلوك السائق',
        description: 'السائق كان غير محترم في التعامل',
        type: 'behavior',
        priority: 'medium',
        status: 'resolved',
        userName: 'سارة أحمد',
        userPhone: '01055556666',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    
    setState(() => _isLoading = false);
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.grey;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'منخفض';
      case 'medium':
        return 'متوسط';
      case 'high':
        return 'عالي';
      case 'urgent':
        return 'عاجل';
      default:
        return 'غير معروف';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلقة';
      case 'in_progress':
        return 'قيد المعالجة';
      case 'resolved':
        return 'تم الحل';
      case 'closed':
        return 'مغلقة';
      default:
        return 'غير معروف';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'delay':
        return Icons.timer_off;
      case 'damage':
        return Icons.broken_image;
      case 'lost':
        return Icons.search_off;
      case 'behavior':
        return Icons.person_off;
      default:
        return Icons.report_problem;
    }
  }

  Future<void> _updateStatus(String complaintId, String newStatus) async {
    // TODO: Call API to update status
    setState(() {
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        _complaints[index] = Complaint(
          id: _complaints[index].id,
          title: _complaints[index].title,
          description: _complaints[index].description,
          type: _complaints[index].type,
          priority: _complaints[index].priority,
          status: newStatus,
          userName: _complaints[index].userName,
          userPhone: _complaints[index].userPhone,
          createdAt: _complaints[index].createdAt,
        );
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث الحالة بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _complaints.length,
        itemBuilder: (context, index) {
          final complaint = _complaints[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getPriorityColor(complaint.priority).withOpacity(0.1),
                child: Icon(
                  _getTypeIcon(complaint.type),
                  color: _getPriorityColor(complaint.priority),
                ),
              ),
              title: Text(
                complaint.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${complaint.userName} - ${_formatDate(complaint.createdAt)}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPriorityColor(complaint.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPriorityText(complaint.priority),
                  style: TextStyle(
                    color: _getPriorityColor(complaint.priority),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 18),
                          const SizedBox(width: 8),
                          Text(complaint.userPhone),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(complaint.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(complaint.status),
                              style: TextStyle(
                                color: _getStatusColor(complaint.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: complaint.status != 'in_progress'
                                  ? () => _updateStatus(complaint.id, 'in_progress')
                                  : null,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('بدء المعالجة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: complaint.status != 'resolved'
                                  ? () => _updateStatus(complaint.id, 'resolved')
                                  : null,
                              icon: const Icon(Icons.check),
                              label: const Text('تم الحل'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: complaint.status != 'closed'
                                  ? () => _updateStatus(complaint.id, 'closed')
                                  : null,
                              icon: const Icon(Icons.close),
                              label: const Text('إغلاق'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Users Tab - إدارة المستخدمين
class UsersTab extends StatefulWidget {
  const UsersTab({Key? key}) : super(key: key);

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  bool _isLoading = true;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    _users = [
      User(
        id: '1',
        name: 'أحمد محمد',
        phone: '01012345678',
        email: 'ahmed@example.com',
        type: 'driver',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: '2',
        name: 'محمد علي',
        phone: '01098765432',
        email: 'mohamed@example.com',
        type: 'driver',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      User(
        id: '3',
        name: 'سارة أحمد',
        phone: '01055556666',
        email: 'sara@example.com',
        type: 'client',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      User(
        id: '4',
        name: 'محمود حسن',
        phone: '01077778888',
        email: 'mahmoud@example.com',
        type: 'driver',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
    
    setState(() => _isLoading = false);
  }

  String _getUserTypeText(String type) {
    switch (type) {
      case 'driver':
        return 'سائق';
      case 'client':
        return 'عميل';
      case 'admin':
        return 'مشرف';
      default:
        return 'غير معروف';
    }
  }

  Color _getUserTypeColor(String type) {
    switch (type) {
      case 'driver':
        return Colors.blue;
      case 'client':
        return Colors.green;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _toggleUserStatus(String userId) async {
    // TODO: Call API to toggle status
    setState(() {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = User(
          id: _users[index].id,
          name: _users[index].name,
          phone: _users[index].phone,
          email: _users[index].email,
          type: _users[index].type,
          isActive: !_users[index].isActive,
          createdAt: _users[index].createdAt,
        );
      }
    });
    
    final user = _users.firstWhere((u) => u.id == userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(user.isActive ? 'تم تفعيل المستخدم' : 'تم تعطيل المستخدم'),
      ),
    );
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المستخدم؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Call API to delete user
      setState(() {
        _users.removeWhere((u) => u.id == userId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المستخدم بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: _getUserTypeColor(user.type).withOpacity(0.1),
                child: Icon(
                  user.type == 'driver' 
                      ? Icons.local_shipping 
                      : user.type == 'admin' 
                          ? Icons.admin_panel_settings 
                          : Icons.person,
                  color: _getUserTypeColor(user.type),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.isActive 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.isActive ? 'مفعل' : 'معطل',
                      style: TextStyle(
                        color: user.isActive ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(user.phone),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getUserTypeColor(user.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getUserTypeText(user.type),
                      style: TextStyle(
                        color: _getUserTypeColor(user.type),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _toggleUserStatus(user.id),
                    icon: Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      color: user.isActive ? Colors.red : Colors.green,
                    ),
                    tooltip: user.isActive ? 'تعطيل' : 'تفعيل',
                  ),
                  IconButton(
                    onPressed: () => _deleteUser(user.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'حذف',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Profile Tab - الملف الشخصي
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 50,
                    color: Color(0xFF667eea),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'المشرف',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_shipping,
                  label: 'السائقين',
                  value: '12',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  label: 'العملاء',
                  value: '150',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.report_problem,
                  label: 'الشكاوى',
                  value: '5',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Settings
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: 'الإشعارات',
                  subtitle: 'إعدادات الإشعارات',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.security,
                  title: 'تغيير كلمة المرور',
                  subtitle: 'تحديث كلمة المرور الخاصة بك',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.help,
                  title: 'المساعدة',
                  subtitle: 'مركز المساعدة والدعم',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.logout,
                  title: 'تسجيل الخروج',
                  subtitle: 'الخروج من الحساب',
                  onTap: () {},
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF667eea), size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF667eea)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFF667eea),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// Models
class DriverLocation {
  final String id;
  final String name;
  final String phone;
  final double lat;
  final double lng;
  final String status;
  final DateTime lastUpdated;

  DriverLocation({
    required this.id,
    required this.name,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.status,
    required this.lastUpdated,
  });
}

class Complaint {
  final String id;
  final String title;
  final String description;
  final String type;
  final String priority;
  final String status;
  final String userName;
  final String userPhone;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    required this.userName,
    required this.userPhone,
    required this.createdAt,
  });
}

class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String type;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.type,
    required this.isActive,
    required this.createdAt,
  });
}
