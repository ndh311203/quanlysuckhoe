import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/profile_screen.dart';
import 'screens/charts_screen.dart';
import 'screens/health_input_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/debug_screen.dart';
import 'services/health_metric_service.dart';
import 'models/health_metric.dart';
import 'services/reminder_service.dart';

Future<void> _seedFakeData() async {
  final service = HealthMetricService();
  await service.initialize();

  // Kiểm tra xem đã có dữ liệu chưa
  if (service.getAll().isNotEmpty) return;

  // Thêm dữ liệu mẫu
  final now = DateTime.now();
  final metrics = [
    // Cân nặng - giảm dần từ 75kg xuống 70kg trong 7 ngày
    HealthMetric(id: '1', type: MetricType.weight, value: 75.0, timestamp: now.subtract(const Duration(days: 6))),
    HealthMetric(id: '2', type: MetricType.weight, value: 74.2, timestamp: now.subtract(const Duration(days: 5))),
    HealthMetric(id: '3', type: MetricType.weight, value: 73.5, timestamp: now.subtract(const Duration(days: 4))),
    HealthMetric(id: '4', type: MetricType.weight, value: 72.8, timestamp: now.subtract(const Duration(days: 3))),
    HealthMetric(id: '5', type: MetricType.weight, value: 72.1, timestamp: now.subtract(const Duration(days: 2))),
    HealthMetric(id: '6', type: MetricType.weight, value: 71.5, timestamp: now.subtract(const Duration(days: 1))),
    HealthMetric(id: '7', type: MetricType.weight, value: 70.8, timestamp: now),

    // Chiều cao - cố định
    HealthMetric(id: '8', type: MetricType.height, value: 170.0, timestamp: now.subtract(const Duration(days: 30))),

    // Huyết áp - dao động bình thường
    HealthMetric(id: '9', type: MetricType.bloodPressure, systolic: 120, diastolic: 80, timestamp: now.subtract(const Duration(days: 3))),
    HealthMetric(id: '10', type: MetricType.bloodPressure, systolic: 118, diastolic: 78, timestamp: now.subtract(const Duration(days: 1))),
    HealthMetric(id: '11', type: MetricType.bloodPressure, systolic: 122, diastolic: 82, timestamp: now),

    // Nhịp tim - 70-85 bpm
    HealthMetric(id: '12', type: MetricType.heartRate, value: 72.0, timestamp: now.subtract(const Duration(days: 2))),
    HealthMetric(id: '13', type: MetricType.heartRate, value: 78.0, timestamp: now.subtract(const Duration(days: 1))),
    HealthMetric(id: '14', type: MetricType.heartRate, value: 75.0, timestamp: now),

    // Số bước chân - 8000-12000 bước/ngày
    HealthMetric(id: '15', type: MetricType.steps, value: 8500, timestamp: now.subtract(const Duration(days: 6))),
    HealthMetric(id: '16', type: MetricType.steps, value: 9200, timestamp: now.subtract(const Duration(days: 5))),
    HealthMetric(id: '17', type: MetricType.steps, value: 7800, timestamp: now.subtract(const Duration(days: 4))),
    HealthMetric(id: '18', type: MetricType.steps, value: 10500, timestamp: now.subtract(const Duration(days: 3))),
    HealthMetric(id: '19', type: MetricType.steps, value: 8800, timestamp: now.subtract(const Duration(days: 2))),
    HealthMetric(id: '20', type: MetricType.steps, value: 9600, timestamp: now.subtract(const Duration(days: 1))),
    HealthMetric(id: '21', type: MetricType.steps, value: 11200, timestamp: now),

    // Nước uống - 1500-2000ml/ngày
    HealthMetric(id: '22', type: MetricType.water, value: 500, timestamp: now.subtract(const Duration(hours: 8))),
    HealthMetric(id: '23', type: MetricType.water, value: 300, timestamp: now.subtract(const Duration(hours: 6))),
    HealthMetric(id: '24', type: MetricType.water, value: 400, timestamp: now.subtract(const Duration(hours: 4))),
    HealthMetric(id: '25', type: MetricType.water, value: 300, timestamp: now.subtract(const Duration(hours: 2))),

    // Đường huyết - 70-140 mg/dL
    HealthMetric(id: '26', type: MetricType.glucose, value: 95.0, timestamp: now.subtract(const Duration(days: 2))),
    HealthMetric(id: '27', type: MetricType.glucose, value: 102.0, timestamp: now.subtract(const Duration(days: 1))),
    HealthMetric(id: '28', type: MetricType.glucose, value: 98.0, timestamp: now),
  ];

  for (final metric in metrics) {
    await service.addMetric(metric);
  }

  // ignore: avoid_print
  print('Debug: Seeded ${metrics.length} fake health metrics');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    try {
      // Seed demo data in debug mode but do NOT clear existing preferences.
      await _seedFakeData();
    } catch (e) {
      // ignore: avoid_print
      print('Debug: failed to seed fake data: $e');
    }
  }
  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('logged_in') ?? false;
  // For testing: start on debug screen to inspect prefs/metrics
  final initialRoute = '/debug';
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rebuilt Health Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const HomeNavigator(),
        '/login': (context) => const LoginScreen(),
        '/debug': (context) => const DebugScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/charts': (context) => const ChartsScreen(),
        '/input': (context) => const HealthInputScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      initialRoute: initialRoute,
    );
  }
}

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});
  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _selectedIndex = 0;
  final _healthService = HealthMetricService();
  bool _isLoading = true;
  final _reminderService = ReminderService();

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
    } else if (index == 2) {
      Navigator.pushNamed(context, '/charts');
    } else if (index == 4) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân', style: TextStyle(color: Colors.black)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHealthCards(),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _pillButton(context, 'Mở Hồ sơ cá nhân', () => Navigator.pushNamed(context, '/profile')),
                      const SizedBox(height: 12),
                      _pillButton(context, 'Mở Biểu đồ thống kê', () => Navigator.pushNamed(context, '/charts')),
                      const SizedBox(height: 12),
                      _pillButton(context, 'Cài đặt', () => Navigator.pushNamed(context, '/settings')),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddModal,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.blue.shade700,
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                tooltip: 'Trang chủ',
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                tooltip: 'Thêm',
                icon: const Icon(Icons.add_box, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/input'),
              ),
              const SizedBox(width: 48), // space for FAB
              IconButton(
                tooltip: 'Biểu đồ',
                icon: const Icon(Icons.show_chart, color: Colors.white),
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                tooltip: 'Cá nhân',
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () => _onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          elevation: 2,
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.purple,
        ),
        child: Text(label),
      ),
    );
  }
 
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _healthService.initialize();
    await _reminderService.initialize();
    setState(() => _isLoading = false);
  }

  Widget _buildHealthCards() {
    final latestWeight = _healthService.getLatest(MetricType.weight);
    final latestHeight = _healthService.getLatest(MetricType.height);
    final latestBp = _healthService.getLatest(MetricType.bloodPressure);
    final latestHr = _healthService.getLatest(MetricType.heartRate);

    double? bmi;
    if (latestWeight?.value != null && latestHeight?.value != null && latestHeight!.value! > 0) {
      final h = latestHeight.value! / 100.0;
      bmi = latestWeight!.value! / (h * h);
    }

    Widget card(String title, String subtitle, {IconData? icon}) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (icon != null) Icon(icon, size: 28),
              if (icon != null) const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(subtitle),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: card('Cân nặng', latestWeight?.value != null ? '${latestWeight!.value!.toStringAsFixed(1)} kg' : 'Chưa có', icon: Icons.monitor_weight)),
            const SizedBox(width: 8),
            Expanded(child: card('Chiều cao', latestHeight?.value != null ? '${latestHeight!.value!.toStringAsFixed(1)} cm' : 'Chưa có', icon: Icons.height)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: card('BMI', bmi != null ? bmi.toStringAsFixed(1) : 'Chưa có', icon: Icons.square_foot)),
            const SizedBox(width: 8),
            Expanded(child: card('Huyết áp', latestBp != null && latestBp.systolic != null ? '${latestBp.systolic}/${latestBp.diastolic} mmHg' : 'Chưa có', icon: Icons.favorite)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: card('Nhịp tim', latestHr?.value != null ? '${latestHr!.value!.toInt()} bpm' : 'Chưa có', icon: Icons.favorite_border)),
            const SizedBox(width: 8),
            Expanded(child: card('Nước hôm nay', '${_sumWater().toInt()} ml', icon: Icons.local_drink)),
          ],
        ),
      ],
    );
  }

  double _sumWater() {
    final list = _healthService.getForType(MetricType.water);
    double sum = 0;
    for (var m in list) {
      if (m.value != null) sum += m.value!;
    }
    return sum;
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(leading: const Icon(Icons.monitor_weight), title: const Text('Thêm cân nặng hôm nay'), onTap: () { Navigator.pop(ctx); _showAddValueDialog(MetricType.weight); }),
              ListTile(leading: const Icon(Icons.height), title: const Text('Thêm chiều cao (cm)'), onTap: () { Navigator.pop(ctx); _showAddValueDialog(MetricType.height); }),
              ListTile(leading: const Icon(Icons.favorite), title: const Text('Thêm huyết áp'), onTap: () { Navigator.pop(ctx); _showAddBpDialog(); }),
              ListTile(leading: const Icon(Icons.favorite_border), title: const Text('Thêm nhịp tim'), onTap: () { Navigator.pop(ctx); _showAddValueDialog(MetricType.heartRate); }),
              ListTile(leading: const Icon(Icons.directions_walk), title: const Text('Thêm số bước chân'), onTap: () { Navigator.pop(ctx); _showAddValueDialog(MetricType.steps); }),
              ListTile(leading: const Icon(Icons.local_drink), title: const Text('Thêm lượng nước (ml)'), onTap: () { Navigator.pop(ctx); _showAddValueDialog(MetricType.water); }),
            ],
          ),
        );
      },
    );
  }

  void _showAddValueDialog(MetricType type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nhập ${type.name}'),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Nhập giá trị')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(onPressed: () async {
            final text = controller.text.trim();
            final val = double.tryParse(text);
            if (val != null) {
              final metric = HealthMetric(id: DateTime.now().millisecondsSinceEpoch.toString(), type: type, value: val, timestamp: DateTime.now());
              await _healthService.addMetric(metric);
              setState(() {});
            }
            Navigator.pop(ctx);
          }, child: const Text('Lưu')),
        ],
      ),
    );
  }

  void _showAddBpDialog() {
    final sCtrl = TextEditingController();
    final dCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập huyết áp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: sCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tâm thu (systolic)')),
            TextField(controller: dCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tâm trương (diastolic)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(onPressed: () async {
            final s = int.tryParse(sCtrl.text.trim());
            final d = int.tryParse(dCtrl.text.trim());
            if (s != null && d != null) {
              final metric = HealthMetric(id: DateTime.now().millisecondsSinceEpoch.toString(), type: MetricType.bloodPressure, systolic: s, diastolic: d, timestamp: DateTime.now());
              await _healthService.addMetric(metric);
              setState(() {});
            }
            Navigator.pop(ctx);
          }, child: const Text('Lưu')),
        ],
      ),
    );
  }

  void _showRemindersDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        bool water = false;
        bool bp = false;
        bool exercise = false;
        TimeOfDay waterTime = const TimeOfDay(hour: 10, minute: 0);
        TimeOfDay bpTime = const TimeOfDay(hour: 18, minute: 0);
        TimeOfDay exerciseTime = const TimeOfDay(hour: 7, minute: 0);

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickTime(TimeOfDay initial, void Function(TimeOfDay) onPicked) async {
              final t = await showTimePicker(context: context, initialTime: initial);
              if (t != null) onPicked(t);
            }

            return AlertDialog(
              title: const Text('Nhắc nhở sức khỏe'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: water,
                    onChanged: (v) => setState(() => water = v),
                    title: const Text('Nhắc uống nước'),
                    subtitle: Text('Giờ: ${waterTime.format(context)}'),
                    secondary: IconButton(icon: const Icon(Icons.schedule), onPressed: () => pickTime(waterTime, (t) => setState(() => waterTime = t))),
                  ),
                  SwitchListTile(
                    value: bp,
                    onChanged: (v) => setState(() => bp = v),
                    title: const Text('Nhắc đo huyết áp'),
                    subtitle: Text('Giờ: ${bpTime.format(context)}'),
                    secondary: IconButton(icon: const Icon(Icons.schedule), onPressed: () => pickTime(bpTime, (t) => setState(() => bpTime = t))),
                  ),
                  SwitchListTile(
                    value: exercise,
                    onChanged: (v) => setState(() => exercise = v),
                    title: const Text('Nhắc tập thể dục'),
                    subtitle: Text('Giờ: ${exerciseTime.format(context)}'),
                    secondary: IconButton(icon: const Icon(Icons.schedule), onPressed: () => pickTime(exerciseTime, (t) => setState(() => exerciseTime = t))),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                TextButton(onPressed: () async {
                  if (water) await _reminderService.scheduleDaily(1, 'Nhắc uống nước', 'Uống 1 cốc nước ngay', waterTime.hour, waterTime.minute);
                  if (bp) await _reminderService.scheduleDaily(2, 'Nhắc đo huyết áp', 'Đo huyết áp ngay', bpTime.hour, bpTime.minute);
                  if (exercise) await _reminderService.scheduleDaily(3, 'Nhắc tập thể dục', 'Thực hiện 10 phút tập', exerciseTime.hour, exerciseTime.minute);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhắc nhở đã được lên lịch')));
                  Navigator.pop(ctx);
                }, child: const Text('Lưu')),
              ],
            );
          },
        );
      },
    );
  }
}
