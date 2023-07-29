import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CountryInfoScreen(),
    );
  }
}

class CountryInfoScreen extends StatefulWidget {
  @override
  _CountryInfoScreenState createState() => _CountryInfoScreenState();
}

class _CountryInfoScreenState extends State<CountryInfoScreen> {
  TextEditingController _countryNameController = TextEditingController();
  List<University> _universities = [];

  Future<void> _fetchUniversities(String countryName) async {
    final url = Uri.parse('http://universities.hipolabs.com/search?country=$countryName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _universities = List<University>.from(jsonData.map((x) => University.fromJson(x)));
      });
    } else {
      setState(() {
        _universities.clear();
      });
      throw Exception('Failed to fetch universities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country Information App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _countryNameController,
              decoration: InputDecoration(labelText: 'Enter Country Name'),
            ),
            ElevatedButton(
              onPressed: () {
                final countryName = _countryNameController.text;
                if (countryName.isNotEmpty) {
                  _fetchUniversities(countryName);
                }
              },
              child: Text('Fetch Information'),
            ),
            Expanded(
              child: _universities.isNotEmpty
                  ? ListView.builder(
                itemCount: _universities.length,
                itemBuilder: (context, index) {
                  final university = _universities[index];
                  return ListTile(
                    title: GestureDetector(
                      onTap: () {
                        if (university.url.isNotEmpty) {
                          _launchURL(university.url);
                        }
                      },
                      child: Text(
                        university.name,
                        style: TextStyle(
                          color: university.url.isNotEmpty ? Colors.blue : Colors.black,
                          decoration: university.url.isNotEmpty ? TextDecoration.underline : TextDecoration.none,
                        ),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Country: ${university.country}"),
                        if (university.state.isNotEmpty) Text("State: ${university.state}"),
                        if (university.city.isNotEmpty) Text("City: ${university.city}"),
                      ],
                    ),
                  );
                },
              )
                  : Center(
                child: Text('No Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch URL');
    }
  }
}

class University {
  final String name;
  final String country;
  final String state;
  final String city;
  final String url;

  University({required this.name, required this.country, this.state = '', this.city = '', this.url = ''});

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      url: json['web_pages'] != null && json['web_pages'].isNotEmpty ? json['web_pages'][0] : '',
    );
  }
}
