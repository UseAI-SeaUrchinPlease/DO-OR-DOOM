import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/widgets.dart';
import '../../core/services/task_storage.dart';
import '../../core/services/daily_diary_storage.dart';

class NotificationService with WidgetsBindingObserver {
		NotificationService._();
		static final NotificationService instance = NotificationService._();

		final FlutterLocalNotificationsPlugin _plugin =
						FlutterLocalNotificationsPlugin();

		/// 初期化: タイムゾーン設定、プラグイン初期化、ライフサイクル監視開始
		Future<void> init() async {
				// timezone
				final String tzName = await FlutterNativeTimezone.getLocalTimezone();
				tz.initializeTimeZones();
				tz.setLocalLocation(tz.getLocation(tzName));

				// Darwin (iOS/macOS) 初期設定
				final darwinSettings = DarwinInitializationSettings(
					requestAlertPermission: true,
					requestBadgePermission: true,
					requestSoundPermission: true,
				);

				// plugin の InitializationSettings はプラットフォーム名を使う
				final settings = InitializationSettings(
					iOS: darwinSettings,
					macOS: darwinSettings,
				);

			await _plugin.initialize(settings);
			print('[Notify] initialized');

			// ライフサイクル監視を開始
			WidgetsBinding.instance.addObserver(this);
			print('[Notify] lifecycle observer added');
		}

	Future<bool> requestPermission() async {
				final iosImpl = _plugin
						.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
				final result = await iosImpl?.requestPermissions(
					alert: true,
					badge: true,
					sound: true,
				);
			return result ?? false;
	}

	Future<void> show({
		required int id,
		required String title,
		required String body,
	}) async {
		final details = NotificationDetails(
		  iOS: DarwinNotificationDetails(),
		  macOS: DarwinNotificationDetails(),
		);
	print('[Notify] show -> id:$id title:$title body:$body');
	await _plugin.show(id, title, body, details);
	}

		Future<void> schedule({
				required int id,
				required String title,
				required String body,
				required DateTime scheduledDate,
				String? payload,
		}) async {
				final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
				final details = NotificationDetails(
					iOS: DarwinNotificationDetails(),
					macOS: DarwinNotificationDetails(),
				);
				await _plugin.zonedSchedule(
					id,
					title,
					body,
					tzDate,
					details,
					androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
					payload: payload,
				);
		}

		@override
		void didChangeAppLifecycleState(AppLifecycleState state) {
			// アプリがバックグラウンドになったらチェック
			if (state == AppLifecycleState.paused) {
		print('[Notify] didChangeAppLifecycleState: paused');
		_checkDueTodayAndNotify();
			}
		}

		/// 本日期限の未完了タスクがあれば通知を出す
		Future<void> _checkDueTodayAndNotify() async {
			try {
					final tasks = TaskStorage.getTasksDueToday();
					final incomplete = tasks.where((t) => !t.isCompleted).toList();
					print('[Notify] found ${tasks.length} tasks due today, ${incomplete.length} incomplete');
					if (incomplete.isEmpty) return;

					// まずキャッシュを確認し、なければ API から取得
					String? message;
					final diary = DailyDiaryStorage.getTodayDiaryData(incomplete);
					if (diary != null && diary.negativeText != null) {
						message = diary.negativeText;
						print('[Notify] diary cache hit: ${message}');
					} else {
						print('[Notify] diary cache miss, fetching...');
						try {
							final resp = await DailyDiaryStorage.fetchAndSaveTodayDiary(incomplete);
							message = resp.negative.text;
							print('[Notify] diary fetched: ${message}');
						} catch (e) {
							// フォールバック: 最初のタスクの sentence1 を使う
							message = incomplete.isNotEmpty ? incomplete.first.sentence1 ?? '今日のタスクがあります' : '今日のタスクがあります';
							print('[Notify] diary fetch failed, fallback message: ${message}');
						}
					}

					if (message != null) {
						// デバッガ接続下でも通知が配信されやすいように短い遅延でスケジュールする
						final scheduledDate = DateTime.now().add(const Duration(seconds: 2));
						print('[Notify] scheduling notification at $scheduledDate');
						await schedule(id: 1000, title: 'AI絵日記', body: message, scheduledDate: scheduledDate);
					}
			} catch (e) {
				// ログだけ出す
					print('Notification check failed: $e');
			}
		}

	Future<void> cancel(int id) async {
		await _plugin.cancel(id);
	}

	Future<void> cancelAll() async {
		await _plugin.cancelAll();
	}
}

// Small usage contract:
// - call NotificationService.instance.init() early (app start)
// - ask for permissions with requestPermission() on iOS
// - use show()/schedule() to post notifications
