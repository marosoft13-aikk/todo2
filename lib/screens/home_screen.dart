import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as fw; // alias لتفادي تصادم الأسماء
import 'package:provider/provider.dart';
import 'package:todo_flutter/providers/task_provider.dart';
import 'package:todo_flutter/models/task.dart';
import 'add_edit_task_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../app_localizations.dart';
import '../providers/locale_provider.dart';

/// دالة مساعدة لعرض أيقونات من assets بأمان:
Widget safeAssetIcon(
  String assetPath, {
  double size = 40,
  Color? color,
  IconData fallback = Icons.image,
}) {
  return Image.asset(
    assetPath,
    width: size,
    height: size,
    color: color,
    errorBuilder: (context, error, stackTrace) {
      return Icon(fallback, size: size, color: color ?? Colors.grey);
    },
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Color _priorityColor(int p) {
    switch (p) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orange;
      case 3:
      default:
        return Colors.green;
    }
  }

  String _dueText(DateTime due, AppLocalizations loc) {
    final now = DateTime.now();
    final local = due.toLocal();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final diffDays = local.difference(todayMidnight).inDays;
    if (diffDays == 0)
      return '${loc.t('todayPrefix')} ${DateFormat.Hm().format(local)}';
    if (diffDays == 1)
      return '${loc.t('tomorrowPrefix')} ${DateFormat.Hm().format(local)}';
    return DateFormat.yMMMd(loc.locale.languageCode).add_jm().format(local);
  }

  Future<bool?> _confirmDelete(BuildContext context, String title) {
    final loc = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.t('confirmDeleteTitle')),
        content: Text(loc.t('confirmDeleteContent', {'title': title})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.t('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final titleStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
    );
    final subtitleStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey[600],
      height: 1.4,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 110,
              color: Color(0xFFDDDDDD),
            ),
            const SizedBox(height: 28),
            Text(loc.t('noTasksTitle'), style: titleStyle),
            const SizedBox(height: 12),
            Text(
              loc.t('noTasksSubtitle'),
              textAlign: TextAlign.center,
              style: subtitleStyle,
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 6,
                backgroundColor: const Color(0xFFF6EFFB),
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Color(0xFF6B3DA3)),
                  const SizedBox(width: 10),
                  Text(loc.t('addTask'),
                      style: const TextStyle(color: Color(0xFF6B3DA3))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Directionality(
      textDirection: loc.isRTL ? fw.TextDirection.rtl : fw.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          centerTitle: false,
          toolbarHeight: 84,
          title: Text(loc.t('homeTitle')),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
              tooltip: loc.t('search'),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
              tooltip: loc.t('filter'),
            ),
            Consumer<LocaleProvider>(
              builder: (context, lp, _) {
                return IconButton(
                  onPressed: () => lp.toggle(),
                  icon: Icon(lp.locale.languageCode == 'ar'
                      ? Icons.language
                      : Icons.translate),
                  tooltip: lp.locale.languageCode == 'ar' ? 'EN' : 'ع',
                );
              },
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            final tasks = provider.tasks;
            if (tasks.isEmpty) return _emptyState(context);

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final t = tasks[i];
                return Slidable(
                  key: ValueKey(t.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => AddEditTaskScreen(task: t)),
                        ),
                        backgroundColor: Colors.orange,
                        icon: Icons.edit,
                        label: loc.t('edit'),
                      ),
                      SlidableAction(
                        onPressed: (context) async {
                          final confirmed =
                              await _confirmDelete(context, t.title);
                          if (confirmed == true) {
                            provider.deleteTask(t.id);
                          }
                        },
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: loc.t('delete'),
                      ),
                    ],
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () => provider.toggleComplete(t),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _priorityColor(t.priority),
                              child: Text(
                                t.priority.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: t.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: t.completed
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (t.dueDate != null)
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 6),
                                        Text(
                                          _dueText(t.dueDate!, loc),
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 6),
                                  if (t.tags.isNotEmpty)
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: t.tags
                                          .map((tag) => Chip(
                                                label: Text(tag,
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                backgroundColor:
                                                    Colors.blue.shade50,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ))
                                          .toList(),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => AddEditTaskScreen(task: t)),
                              ),
                              icon: const Icon(Icons.more_horiz),
                              tooltip: loc.t('details'),
                            ),
                            Checkbox(
                              value: t.completed,
                              onChanged: (_) => provider.toggleComplete(t),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(loc.t('addTask'),
              style: const TextStyle(color: Colors.white)),
          elevation: 12,
          backgroundColor: const Color(0xFF5D2FA6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}
