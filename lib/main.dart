import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/inventory_list_screen.dart';
import 'screens/add_edit_item_screen.dart';
import 'services/inventory_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await InventoryStorage().init();

  runApp(const ShelfLifeCheckerApp());
}

class ShelfLifeCheckerApp extends StatelessWidget {
  const ShelfLifeCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shelf Life Checker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: InventoryListScreen.routeName,
      routes: {
        InventoryListScreen.routeName: (_) => const InventoryListScreen(),
        AddEditItemScreen.routeName: (_) => const AddEditItemScreen(),
      },
    );
  }
}
