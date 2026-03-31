import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_flutter/models/task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskProvider extends ChangeNotifier {
  static const String boxName = 'tasks';
  late Box<Task> _box;
  final _uuid = Uuid();
  final FlutterLocalNotificationsPlugin notifications;

  TaskProvider({required this.notifications});

  Future<void> init() async {
    _box = Hive.box<Task>(boxName);
    notifyListeners();
  }

  List<Task> get tasks {
    final list = _box.values.toList().cast<Task>();
    list.sort((a, b) {
      final ad = a.dueDate ?? DateTime(2100);
      final bd = b.dueDate ?? DateTime(2100);
      return ad.compareTo(bd);
    });
    return list;
  }

  Future<void> addTask(Task t, {bool scheduleNotification = true}) async {
    t.id = _uuid.v4();
    t.createdAt = DateTime.now();
    t.updatedAt = DateTime.now();
    await _box.put(t.id, t);
    if (scheduleNotification && t.dueDate != null) {
      await _scheduleNotificationForTask(t);
    }
    notifyListeners();
  }

  Future<void> updateTask(Task t, {bool rescheduleNotification = true}) async {
    t.updatedAt = DateTime.now();
    await _box.put(t.id, t);
    if (rescheduleNotification) {
      await _cancelNotification(t.id);
      if (t.dueDate != null && !t.completed) {
        await _scheduleNotificationForTask(t);
      }
    }
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _cancelNotification(id);
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> toggleComplete(Task t) async {
    t.completed = !t.completed;
    t.updatedAt = DateTime.now();
    await _box.put(t.id, t);
    if (t.completed) {
      await _cancelNotification(t.id);
    } else if (t.dueDate != null) {
      await _scheduleNotificationForTask(t);
    }
    notifyListeners();
  }

  Future<void> _scheduleNotificationForTask(Task t) async {
    final scheduled = t.dueDate;
    if (scheduled == null) return;
    if (scheduled.isBefore(DateTime.now())) return;

    final android = AndroidNotificationDetails('todo_channel', 'Todo Reminders',
        channelDescription: 'Reminders for TODO tasks',
        importance: Importance.max,
        priority: Priority.high);
    final detail = NotificationDetails(android: android);

    await notifications.zonedSchedule(
      _hashId(t.id),
      'تذكير: ${t.title}',
      t.description ?? '',
      tz.TZDateTime.from(scheduled, tz.local),
      detail,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  int _hashId(String id) => id.hashCode;

  Future<void> _cancelNotification(String id) async {
    await notifications.cancel(_hashId(id));
  }
}
