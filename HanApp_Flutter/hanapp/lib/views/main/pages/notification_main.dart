import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

class NotificationMain extends StatefulWidget {
  final Map<dynamic, dynamic> reports;
  const NotificationMain({super.key, required this.reports});

  @override
  State<NotificationMain> createState() => _NotificationMain();
}

class _NotificationMain extends State<NotificationMain> {
  final dbRef2 = FirebaseDatabase.instance.ref().child('Reports');

  @override
  void initState() {
    super.initState();
  }

  List<double> extractDoubles(String input) {
    RegExp regExp = RegExp(r"[-+]?\d*\.?\d+");
    List<double> doubles = [];
    Iterable<RegExpMatch> matches = regExp.allMatches(input);
    for (RegExpMatch match in matches) {
      doubles.add(double.parse(match.group(0)!));
    }
    return doubles;
  }

  // optionStyle is for the text, we can remove this when actualy doing menu contents
  static const TextStyle optionStyle = TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54);
  @override
  Widget build(BuildContext context) {
    return widget.reports.isNotEmpty
        ? Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              margin: const EdgeInsets.only(top: 100.0),
              child: ListView.builder(
                itemCount: widget.reports.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: const Text('Missing persons last seen in your area'),
                    subtitle:
                        const Text('Check Nearby Reports for more details'),
                    onTap: () {
                      // Handle tap event here
                    },
                  );
                },
              ),
            ),
          )
        : const Text(
            'No missing persons last seen in your area',
            style: optionStyle,
          );
  }
}
