import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {}

class WishlistReminderNotificationService {
  WishlistReminderNotificationService();

  static const int _notificationId = 1200;
  static const int _scheduledHour = 17;
  static const int _scheduledMinute = 42;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _notificationsEnabled = false;
  int _wishlistCount = 0;

  // ──────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    await _initPlugin();
    await _requestPermissions();
    await _configureTimezone();

    _initialized = true;
    await _syncSchedule();
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

  // ──────────────────────────────────────────────
  // Initialization helpers
  // ──────────────────────────────────────────────

  Future<void> _initPlugin() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false, // we request manually below
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitSettings,
          iOS: iosInitSettings,
        );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
  }

  Future<void> _requestPermissions() async {
    // Android
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    // iOS
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

  // ──────────────────────────────────────────────
  // Scheduling
  // ──────────────────────────────────────────────

  Future<void> _syncSchedule() async {
    if (!_initialized) return;

    // Cancel and bail if conditions are not met
    if (!_notificationsEnabled || _wishlistCount <= 0) {
      await _plugin.cancel(_notificationId);
      return;
    }

    final tz.TZDateTime nextTrigger = _nextScheduledTime();

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'wishlist_daily_reminder',
        'Wishlist Daily Reminder',
        channelDescription:
            'Pengingat harian untuk game yang ada di wishlist kamu.',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: false,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Cancel existing before rescheduling to avoid duplicates
    await _plugin.cancel(_notificationId);

    await _plugin.zonedSchedule(
      _notificationId,
      'Wishlist Reminder 🎮',
      'Kamu punya $_wishlistCount game di wishlist. Yuk cek sekarang!',
      nextTrigger,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'wishlist_daily_reminder',
    );
  }

  tz.TZDateTime _nextScheduledTime() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _scheduledHour,
      _scheduledMinute,
    );

    // If the time has already passed (or is exactly now), push to tomorrow
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }

  void _onNotificationResponse(NotificationResponse response) {
    // TODO: Navigate to wishlist screen based on payload
  }
}
