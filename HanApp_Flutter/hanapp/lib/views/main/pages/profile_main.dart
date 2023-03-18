import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hanapp/views/login_view.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../../firebase_options.dart';
import '../../../main.dart';
import '../../register_view.dart';

class ProfileMain extends StatefulWidget {
  const ProfileMain({super.key});

  @override
  State<ProfileMain> createState() => _ProfileMain();
}

class _ProfileMain extends State<ProfileMain> {
  String _usrFullName = 'Data Loading';
  String _usrEmail = ' ';
  String _usrNumber = ' ';
  // ignore: unused_field
  String _usrBirthDate = ' ';
  String _usrAge = ' ';
  String _birthDateFormatted = ' ';
  String _usrSex = ' ';
  DatabaseReference mainUsersRef = FirebaseDatabase.instance.ref('Main Users');
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    // user profile details from RTDB
    mainUsersRef.child(user!.uid).onValue.listen((event) {
      var usrProfileDict = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);
      String nameFromDB = usrProfileDict['fullName'];
      String numberFromDB = usrProfileDict['phoneNumber'];
      String emailFromDB = usrProfileDict['email'];
      String sexFromDB = usrProfileDict['sex'];

      String birthDate = usrProfileDict['birthDate'];
      List birthDateList = reformatDate(birthDate, DateTime.parse(birthDate));
      String birthDateFormatted = birthDateList[0];
      String age = birthDateList[1];

      if (kDebugMode) {
        print('[RETRIEVED] $usrProfileDict');
        print('$birthDateList');
      }

      setState(() {
        _usrFullName = nameFromDB;
        _usrNumber = numberFromDB;
        _usrEmail = emailFromDB;
        _usrSex = sexFromDB;
        _usrBirthDate = birthDate;
        _usrAge = age;
        _birthDateFormatted = birthDateFormatted;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _usrFullName != 'Data Loading'
        ? Scaffold(
            appBar: AppBar(
              title: const Text('profile'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_usrFullName),
                  Text(_usrEmail),
                  Text(_usrNumber),
                  Text(_birthDateFormatted),
                  Text(_usrAge),
                  Text(_usrSex),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ElevatedButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginView()));
                        },
                        child: const Text('Sign Out')),
                  ),
                ],
              ),
            ),
          )
        : const Scaffold(
            body: Center(
              child: SpinKitCubeGrid(
                color: Colors.blue,
                size: 50.0,
              ),
            ),
          );
  }
}
