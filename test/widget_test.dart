import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:todo_flutter/main.dart';
import 'package:todo_flutter/models/task.dart';
import 'package:todo_flutter/providers/task_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>(TaskProvider.boxName);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('renders home screen title', (WidgetTester tester) async {
    final notifications = FlutterLocalNotificationsPlugin();
    final taskProvider = TaskProvider(notifications: notifications);
    await taskProvider.init();

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.text('قائمة المهام'), findsOneWidget);
  });
}
