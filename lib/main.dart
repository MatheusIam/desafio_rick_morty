import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      brightness: MediaQuery.platformBrightnessOf(context),
      seedColor: Colors.indigo,
    );
    return MaterialApp(
      title: 'teste',
      theme: ThemeData(
        colorScheme: colorScheme,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String teste = "Sem nada";
  String imageUrl = "";
  List<dynamic> characters = [];
  String nextUrl = "";
  bool isLoading = false;

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    if (characters.isEmpty) {
      final response = await http
          .get(Uri.parse('https://rickandmortyapi.com/api/character'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nextUrl = data['info']['next'];
          characters = data['results'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      final response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          characters.addAll(data['results']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Fetch teste"),
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : characters.isEmpty
                  ? Text("Sem dados")
                  : ListView.builder(
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Image.network(characters[index]['image']),
                          title: Text(characters[index]['name']),
                          subtitle: Text(characters[index]['status']),
                        );
                      }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: fetchData,
          tooltip: 'Carregar mais',
          child: Icon(Icons.add),
        ));
  }
}
