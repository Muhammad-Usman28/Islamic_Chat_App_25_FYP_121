import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    final url =
                        Uri.parse('http://127.0.0.1:8000/get_similar_hadees');
                    final headers = {"Content-Type": "application/json"};
                    final body = jsonEncode(
                        {"query": "ammar killed"}); // Replace with your payload

                    try {
                      final response =
                          await http.post(url, headers: headers, body: body);
                      if (response.statusCode == 200) {
                        print("Response: ${response.body}");
                      } else {
                        print(
                            "Error: ${response.statusCode} - ${response.body}");
                      }
                    } catch (e) {
                      print("Exception: $e");
                    }
                  },
                  child: Text("Get"))
            ],
          ),
        ),
      ),
    );
  }
}
