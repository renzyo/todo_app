import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/model/category.dart';
import 'package:todo_app/providers/async_category_provider.dart';
import 'package:todo_app/providers/async_task_provider.dart';
import 'package:todo_app/screens/add_task/add_task.dart';
import 'package:todo_app/screens/calendar/calendar.dart';
import 'package:todo_app/screens/donate/donate.dart';
import 'package:todo_app/screens/faq/faq.dart';
import 'package:todo_app/screens/manage_categories/manage_categories.dart';
import 'package:todo_app/screens/settings/settings.dart';
import 'package:todo_app/screens/starred_task/starred_task.dart';
import 'package:todo_app/screens/task_list/task_list.dart';
import 'package:todo_app/static/strings.dart';
import 'package:todo_app/widgets/category_setting_dialog.dart';
import 'package:todo_app/widgets/menu_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int index = 0;

  final List<Widget> _pages = [
    const TaskListScreen(),
    const CalendarScreen(),
  ];

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return const AddTaskScreen();
      },
    );
  }

  void _openCategorySetting({
    CategoryData? category,
    bool isEdit = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => CategorySettingDialog(
        category: category,
        isEdit: isEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncTasks = ref.watch(asyncTaskProvider);
    final asyncCategories = ref.watch(asyncCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(StaticStrings.appName),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton(
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 0,
                    child: Text("Manage Categories"),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ManageCategoriesScreen(),
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.settings, size: 28),
              ),
            ),
          ),
        ],
      ),
      drawer: asyncTasks.when(
        data: (tasks) => asyncCategories.when(
          data: (categories) => Drawer(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            StaticStrings.appName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Tasks: ${tasks.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StarredTaskScreen(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.star),
                    title: const Text('Starred Tasks'),
                  ),
                  ExpansionTile(
                    initiallyExpanded: true,
                    shape: ShapeBorder.lerp(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      1,
                    ),
                    leading: const Icon(Icons.category),
                    title: const Text('Categories'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ListTile(
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).selectCategory(null);
                            Navigator.of(context).pop();
                          },
                          leading: const Icon(Icons.category),
                          title: const Text("All"),
                          trailing: Text(
                            tasks.length.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      ...categories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: ListTile(
                            onTap: () {
                              ref.read(selectedCategoryProvider.notifier).selectCategory(category);
                              Navigator.of(context).pop();
                            },
                            leading: Icon(IconData(category.icon, fontFamily: 'MaterialIcons')),
                            title: Text(category.name),
                            trailing: Text(
                              tasks
                                  .where((element) => element.categoryId == category.catId)
                                  .length
                                  .toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ListTile(
                          onTap: _openCategorySetting,
                          leading: const Icon(Icons.add),
                          title: const Text('Add Category'),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DonateScreen(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.favorite),
                    title: const Text('Donate'),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FaqScreen(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.question_mark),
                    title: const Text('FAQ'),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              error.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            error.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      body: _pages[index],
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddTaskBottomSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        height: 96,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DrawerButton(
              style: ButtonStyle(
                iconColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.onSurface,
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(16),
                ),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  const CircleBorder(),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MenuButton(
                    icon: Icons.task_alt,
                    text: "Tasks",
                    isActive: index == 0,
                    onPressed: () {
                      setState(() {
                        index = 0;
                      });
                    },
                  ),
                  MenuButton(
                    icon: Icons.calendar_month_outlined,
                    text: "Calendar",
                    isActive: index == 1,
                    onPressed: () {
                      setState(() {
                        index = 1;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
