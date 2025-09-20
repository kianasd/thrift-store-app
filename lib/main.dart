import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/supabase_service.dart';
import 'pages/auth/sign_in_page.dart';
import 'pages/auth/sign_up_page.dart';
import 'pages/item/items_page.dart';
import 'pages/item/add_item_page.dart';
import 'pages/item/item_detail_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vvnlifnfzcobjbxjfede.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2bmxpZm5memNvYmpieGpmZWRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzMzYxNzcsImV4cCI6MjA3MzkxMjE3N30._hhxP9Nf8zi9pasLp3b3NzdPR8IzEKFlYU-IqWlgmSw',
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupabaseService(),
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thrift Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
      routes: {
        '/signin': (_) => SignInPage(),
        '/signup': (_) => SignUpPage(),
        '/items': (_) => const ItemsPage(),
        '/add': (_)   => AddItemPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final itemId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => ItemDetailPage(itemId: itemId),
          );
        }
        return null;
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null ? const ItemsPage() : SignInPage();
  }
}
