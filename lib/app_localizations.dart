// بسيط AppLocalizations يدعم العربية والإنجليزية مع استبدال متغيرات
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isRTL => locale.languageCode == 'ar';

  String _tr(String key) {
    final lang =
        _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return lang[key] ?? key;
  }

  String t(String key, [Map<String, String>? args]) {
    var s = _tr(key);
    if (args != null) {
      args.forEach((k, v) {
        s = s.replaceAll('{$k}', v);
      });
    }
    return s;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Todo Flutter',
      'homeTitle': 'Tasks',
      'search': 'Search',
      'filter': 'Filter',
      'addTask': 'Add Task',
      'noTasksTitle': 'No tasks yet',
      'noTasksSubtitle': 'Tap "Add Task" to start organizing your tasks',
      'confirmDeleteTitle': 'Confirm delete',
      'confirmDeleteContent': 'Do you want to delete the task "{title}"?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'details': 'Details',
      'chooseDate': 'Choose Date & Time',
      'priorityLabel': 'Priority',
      'priorityHigh': 'High',
      'priorityNormal': 'Normal',
      'priorityLow': 'Low',
      'titleLabel': 'Title',
      'enterTitle': 'Enter a title',
      'descriptionLabel': 'Description (optional)',
      'tagsLabel': 'Tags (comma separated)',
      'saveChanges': 'Save Changes',
      'addButton': 'Add Task',
      'reminderPrefix': 'Reminder:',
      'todayPrefix': 'Today —',
      'tomorrowPrefix': 'Tomorrow —',
    },
    'ar': {
      'appTitle': 'قائمة المهام',
      'homeTitle': 'قائمة المهام',
      'search': 'بحث',
      'filter': 'فلتر',
      'addTask': 'أضف مهمة',
      'noTasksTitle': 'لا توجد مهام بعد',
      'noTasksSubtitle': 'اضغط على زر "أضف مهمة" للبدء بتنظيم مهامك',
      'confirmDeleteTitle': 'تأكيد الحذف',
      'confirmDeleteContent': 'هل تريد حذف المهمة "{title}"؟',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'details': 'تفاصيل',
      'chooseDate': 'اختر التاريخ/الوقت',
      'priorityLabel': 'الأولوية',
      'priorityHigh': 'عالية',
      'priorityNormal': 'عادية',
      'priorityLow': 'منخفضة',
      'titleLabel': 'العنوان',
      'enterTitle': 'أدخل عنواناً',
      'descriptionLabel': 'الوصف (اختياري)',
      'tagsLabel': 'الوسوم (افصل بفاصلة)',
      'saveChanges': 'حفظ التعديلات',
      'addButton': 'أضف المهمة',
      'reminderPrefix': 'تذكير:',
      'todayPrefix': 'اليوم —',
      'tomorrowPrefix': 'غداً —',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
