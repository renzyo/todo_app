import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/helper/available_color.dart';
import 'package:todo_app/helper/available_icon.dart';
import 'package:todo_app/model/category.dart';

part 'async_category_provider.g.dart';

@riverpod
class AsyncCategory extends _$AsyncCategory {
  Isar? isar = Isar.getInstance('todo_app');

  Future<List<CategoryData>> _fetchCategories() async {
    final categories = await isar!.categoryDatas.where().findAll();

    if (categories.isEmpty) {
      return [
        CategoryData(
          name: "Work",
          icon: AvailableIcon.work,
          color: AvailableColor.green,
        ),
        CategoryData(
          name: "Personal",
          icon: AvailableIcon.person,
          color: AvailableColor.yellow,
        ),
        CategoryData(
          name: "Shopping",
          icon: AvailableIcon.shoppingBag,
          color: AvailableColor.red,
        ),
      ];
    }

    return categories;
  }

  @override
  FutureOr<List<CategoryData>> build() async {
    return await _fetchCategories();
  }

  Future<void> addCategory(CategoryData newCategory) async {
    state = const AsyncValue.loading();
    final category = CategoryData(
      name: newCategory.name,
      icon: newCategory.icon,
      color: newCategory.color,
    );
    state = await AsyncValue.guard(() async {
      await isar!.writeTxn(() async {
        await isar!.categoryDatas.put(category);
      });
      return _fetchCategories();
    });
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    state = const AsyncValue.loading();
    final categories = await _fetchCategories();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);

    state = await AsyncValue.guard(() async {
      await isar!.writeTxn(() async {
        await isar!.categoryDatas.putAll(categories);
      });
      return _fetchCategories();
    });
  }

  Future<void> updateCategory(CategoryData newCategory) async {
    state = const AsyncValue.loading();
    final category = await isar!.categoryDatas.get(newCategory.id);
    category!.name = newCategory.name;
    category.icon = newCategory.icon;
    category.color = newCategory.color;
    state = await AsyncValue.guard(() async {
      await isar!.writeTxn(() async {
        await isar!.categoryDatas.put(category);
      });
      return _fetchCategories();
    });
  }

  Future<void> removeCategory(CategoryData category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await isar!.writeTxn(() async {
        await isar!.categoryDatas.delete(category.id);
      });
      return _fetchCategories();
    });
  }
}

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  CategoryData? build() {
    return null;
  }

  void selectCategory(CategoryData? newCategory) {
    state = newCategory;
  }
}

// import 'package:riverpod/riverpod.dart';
// import 'package:todo_app/helper/available_color.dart';
// import 'package:todo_app/helper/available_icon.dart';
// import 'package:todo_app/model/category.dart';

// class CategoriesClass extends StateNotifier<List<CategoryData>> {
//   CategoriesClass([List<CategoryData>? initialCategories])
//       : super(
//           initialCategories ??
//               [
//                 CategoryData(
//                   name: "Work",
//                   icon: AvailableIcon.work,
//                   color: AvailableColor.green,
//                 ),
//                 CategoryData(
//                   name: "Personal",
//                   icon: AvailableIcon.person,
//                   color: AvailableColor.yellow,
//                 ),
//                 CategoryData(
//                   name: "Shopping",
//                   icon: AvailableIcon.shoppingBag,
//                   color: AvailableColor.red,
//                 ),
//               ],
//         );

//   void addCategory(CategoryData newCategory) {
//     state = [...state, newCategory];
//   }

//   void reorderCategory(int oldIndex, int newIndex) {
//     if (oldIndex < newIndex) {
//       newIndex -= 1;
//     }

//     final tempCategories = state;

//     final item = tempCategories.removeAt(oldIndex);
//     tempCategories.insert(newIndex, item);

//     state = [...tempCategories];
//   }

//   void updateCategory(CategoryData category) {
//     state = state.map((element) => element.id == category.id ? category : element).toList();
//   }

//   void removeCategory(CategoryData category) {
//     state = state.where((element) => element != category).toList();
//   }
// }

// final categoriesProvider = StateNotifierProvider<CategoriesClass, List<CategoryData>>((ref) {
//   return CategoriesClass();
// });

// class SelectedCategory extends StateNotifier<CategoryData?> {
//   SelectedCategory([CategoryData? initialCategory]) : super(initialCategory);

//   void selectCategory(CategoryData? category) {
//     state = category;
//   }
// }

// final selectedCategoryProvider = StateNotifierProvider<SelectedCategory, CategoryData?>((ref) {
//   return SelectedCategory();
// });