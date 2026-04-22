import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class WishlistReminderNotificationService {
  WishlistReminderNotificationService();

  static const int _notificationId = 1200;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _notificationsEnabled = false;
  int _wishlistCount = 0;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitSettings,
          iOS: iosInitSettings,
        );

    await _plugin.initialize(initializationSettings);
    await _requestPermissions();
    await _configureTimezone();

    _initialized = true;
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _syncSchedule();
  }

  Future<void> updateWishlistCount(int count) async {
    _wishlistCount = count;
    await _syncSchedule();
  }

  Future<void> resetState() async {
    _notificationsEnabled = false;
    _wishlistCount = 0;
    await _plugin.cancel(_notificationId);
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    final String timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));
  }

  Future<void> _syncSchedule() async {
    if (!_initialized) return;

    if (!_notificationsEnabled || _wishlistCount <= 0) {
      await _plugin.cancel(_notificationId);
      return;
    }

    final tz.TZDateTime nextNoon = _nextNoon();

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'wishlist_daily_reminder',
        'Wishlist Daily Reminder',
        channelDescription: 'Daily noon reminder for wishlist items.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      _notificationId,
      'Wishlist Reminder',
      'Kamu punya $_wishlistCount game di wishlist.',
      nextNoon,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextNoon() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      12,
    );
    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
