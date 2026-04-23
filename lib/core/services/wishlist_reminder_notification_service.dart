import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  debugPrint(
    '[WishlistReminder] background notification response '
    '| id=${response.id} | actionId=${response.actionId} '
    '| payload=${response.payload}',
  );
}

class WishlistReminderNotificationService {
  WishlistReminderNotificationService();

  static const int _notificationId = 1200;
  static const int _scheduledHour = 17;
  static const int _scheduledMinute = 0;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _notificationsEnabled = false;
  int _wishlistCount = 0;
  static const String _logTag = '[WishlistReminder]';

  // ──────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _log('initialize() start');

    await _initPlugin();
    _log('plugin initialized');

    await _handleLaunchDetails();
    await _requestPermissions();
    await _configureTimezone();

    // Mark initialized BEFORE syncing so _syncSchedule() doesn't early-return
    _initialized = true;
    _log('initialize() complete; syncing schedule');
    await _syncSchedule();
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    _log('updateNotificationsEnabled -> $enabled');
    await _syncSchedule();
  }

  Future<void> updateWishlistCount(int count) async {
    _wishlistCount = count;
    _log('updateWishlistCount -> $count');
    await _syncSchedule();
  }

  Future<void> resetState() async {
    _log('resetState(): cancelling notification and clearing state');
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

  Future<void> _handleLaunchDetails() async {
    final NotificationAppLaunchDetails? launchDetails = await _plugin
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _log(
        'app launched from notification '
        '| payload=${launchDetails?.notificationResponse?.payload}',
      );
    }
  }

  Future<void> _requestPermissions() async {
    // Android
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final bool? notifGranted = await androidPlugin
          .requestNotificationsPermission();
      _log('Android notification permission: $notifGranted');

      final bool? exactAlarmGranted = await androidPlugin
          .requestExactAlarmsPermission();
      _log('Android exact alarm permission: $exactAlarmGranted');
    }

    // iOS
    final bool? iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _log('iOS notification permission: $iosGranted');
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    final String timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));
    _log('timezone configured: $timezoneName');
  }

  // ──────────────────────────────────────────────
  // Scheduling
  // ──────────────────────────────────────────────

  Future<void> _syncSchedule() async {
    _log(
      '_syncSchedule() | initialized=$_initialized, '
      'enabled=$_notificationsEnabled, wishlistCount=$_wishlistCount',
    );

    if (!_initialized) {
      _log('skip: service not yet initialized');
      return;
    }

    // Cancel and bail if conditions are not met
    if (!_notificationsEnabled || _wishlistCount <= 0) {
      await _plugin.cancel(_notificationId);
      _log(
        'notification cancelled '
        '(enabled=$_notificationsEnabled, count=$_wishlistCount)',
      );
      return;
    }

    // Log Android runtime permission state for debugging
    await _logAndroidPermissionState();

    final tz.TZDateTime nextTrigger = _nextScheduledTime();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'wishlist_daily_reminder',
        'Wishlist Daily Reminder',
        channelDescription:
            'Pengingat harian untuk game yang ada di wishlist kamu.',
        importance: Importance.max,
        priority: Priority.high,
        // Ensures heads-up on Android 8+
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
      // time = repeat daily at the same HH:mm
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'wishlist_daily_reminder',
    );

    _log('zonedSchedule success | now=$now | nextTrigger=$nextTrigger');

    await _verifyPendingNotification();
  }

  /// Returns the next occurrence of [_scheduledHour]:[_scheduledMinute]
  /// in local timezone. If that time has already passed today, returns tomorrow.
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

    _log('_nextScheduledTime() | now=$now | candidate=$candidate');
    return candidate;
  }

  // ──────────────────────────────────────────────
  // Debug helpers
  // ──────────────────────────────────────────────

  Future<void> _logAndroidPermissionState() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    final bool? notificationsAllowed = await androidPlugin
        .areNotificationsEnabled();
    final bool? exactAlarmAllowed = await androidPlugin
        .canScheduleExactNotifications();

    _log(
      'Android permissions | notificationsEnabled=$notificationsAllowed, '
      'canScheduleExact=$exactAlarmAllowed',
    );

    if (exactAlarmAllowed == false) {
      _log(
        'WARNING: Exact alarm permission denied. '
        'Notification may be delayed or not fire on time. '
        'Direct user to Settings > Apps > Special app access > Alarms & reminders.',
      );
    }
  }

  Future<void> _verifyPendingNotification() async {
    final List<PendingNotificationRequest> pending = await _plugin
        .pendingNotificationRequests();
    final bool registered = pending.any(
      (PendingNotificationRequest r) => r.id == _notificationId,
    );
    _log(
      'pending notifications | total=${pending.length}, '
      'wishlistReminderRegistered=$registered',
    );
    if (!registered) {
      _log('WARNING: wishlist reminder is NOT in pending list after schedule!');
    }
  }

  void _log(String message) => debugPrint('$_logTag $message');

  void _onNotificationResponse(NotificationResponse response) {
    _log(
      'notification tapped '
      '| id=${response.id} | actionId=${response.actionId} '
      '| payload=${response.payload}',
    );
    // TODO: Navigate to wishlist screen based on payload
  }
}
