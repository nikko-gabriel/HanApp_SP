import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanapp/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

import 'verify_email_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

List reformatDate(String dateTime, DateTime dateTimeBday) {
  var dateParts = dateTime.split('-');
  var month = dateParts[1];
  if (int.parse(month) % 10 != 0) {
    month = month.replaceAll('0', '');
  }
  // switch case of shame
  switch (month) {
    case '1':
      month = 'January';
      break;
    case '2':
      month = 'February';
      break;
    case '3':
      month = 'March';
      break;
    case '4':
      month = 'April';
      break;
    case '5':
      month = 'May';
      break;
    case '6':
      month = 'June';
      break;
    case '7':
      month = 'July';
      break;
    case '8':
      month = 'August';
      break;
    case '9':
      month = 'September';
      break;
    case '10':
      month = 'October';
      break;
    case '11':
      month = 'November';
      break;
    case '12':
      month = 'December';
      break;
  }

  var day = dateParts[2];
  day = day.substring(0, day.indexOf(' '));
  if (int.parse(day) % 10 != 0) {
    day = day.replaceAll('0', '');
  }

  var year = dateParts[0];

  var age =
      (DateTime.now().difference(dateTimeBday).inDays / 365).floor().toString();
  var returnVal = '$month $day, $year';
  return [returnVal, age];
}

class _RegisterViewState extends State<RegisterView> {
  // variables
  // Controllers to contain the text in the text fields
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _firstName;
  late final TextEditingController _middleName;
  late final TextEditingController _lastName;
  late final TextEditingController _qualifiers;
  late final TextEditingController _phoneNumber;
  late final TextEditingController _birthDate;
  late final Future<FirebaseApp> _firebaseInit;
  String? ageFromBday;
  String? _selectedSex;
  // ignore: prefer_typing_uninitialized_variables
  DateTime? dateTimeBday;
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  // _formKey is used to validate the form
  final _formKey = GlobalKey<FormState>();
  // _obscured is used to obscure the password, and is set to true by default
  bool _obscured = true;
  // Firebase Realtime Database initialize
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference registrationRef =
      FirebaseDatabase.instance.ref("Main Users");

  // initialize the controllers
  @override
  void initState() {
    // binding?
    _email = TextEditingController();
    _password = TextEditingController();
    _firstName = TextEditingController();
    _middleName = TextEditingController();
    _lastName = TextEditingController();
    _qualifiers = TextEditingController();
    _phoneNumber = TextEditingController();
    _birthDate = TextEditingController();
    _firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    super.initState();
  }

  // dispose of the controllers
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _qualifiers.dispose();
    _phoneNumber.dispose();
    _firebaseInit.asStream().drain();
    super.dispose();
  }

  // build the view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar to be removed, preferably
      //appBar: AppBar(
      //  title: const Center(child: Text('Register')) ,),
      body: Center(
        // FutureBuilder's purpose is to wait for the Firebase initialization
        // to complete before proceeding the rest of the code
        child: FutureBuilder(
          // the future is the Firebase initialization, which is asynchronous
          // without future, the code will not wait for the Firebase initialization to complete
          future: _firebaseInit,
          // context and snapshot are required parameters because the builder is a function that returns a widget
          // what it does is it builds the widget based on the snapshot's connection state
          builder: (context, snapshot) {
            // switch statement to check the connection state
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text("No Connection!");
              case ConnectionState.waiting:
                return const Text('Loading . . .');
              case ConnectionState.active:
                return const Text('Connection is active!');
              case ConnectionState.done:
                // if the connection is done, then the code will proceed to the next step
                return Container(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autoValidate,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 40, top: 60),
                              child: Image.asset(
                                'assets/images/register.png',
                                height: MediaQuery.of(context).size.width * 0.7,
                                fit: BoxFit.fitWidth,
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Sign Up',
                                  style: GoogleFonts.inter(
                                    fontSize: 29,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),

                            TextFormField(
                              // email
                              controller: _email,
                              autocorrect: false,
                              enableSuggestions: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                                labelText: 'Email Address',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return 'Please enter a valid email';
                                } else {
                                  return null;
                                }
                              },
                            ), // email)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextFormField(
                                controller: _password,
                                obscureText: _obscured,
                                decoration: InputDecoration(
                                    prefixIcon:
                                        const Icon(Icons.lock_outline_rounded),
                                    labelText: 'Password',
                                    border: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                    // this button is used to toggle the password visibility
                                    suffixIcon: IconButton(
                                        // if the password is obscured, show the visibility icon
                                        // if the password is not obscured, show the visibility_off icon
                                        icon: Icon(_obscured
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () {
                                          setState(() {
                                            _obscured = !_obscured;
                                          });
                                        })),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  } else if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  } else {
                                    return null;
                                  }
                                },
                              ), // password),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextFormField(
                                // firstName
                                controller: _firstName,
                                textCapitalization: TextCapitalization.words,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.person_outline_rounded),
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextFormField(
                                // middle Name
                                controller: _middleName,
                                textCapitalization: TextCapitalization.words,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.person_outline_rounded),
                                  labelText: 'Middle Name',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextFormField(
                                // last name
                                controller: _lastName,
                                textCapitalization: TextCapitalization.words,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.person_outline_rounded),
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextFormField(
                                // qualifiers
                                controller: _qualifiers,
                                textCapitalization: TextCapitalization.words,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.person_outline_rounded),
                                  labelText: 'Qualifiers',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextFormField(
                                // phone number
                                controller: _phoneNumber,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.phone_outlined),
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  } else if (value.length < 10 ||
                                      value.length > 11) {
                                    return 'Please enter a valid phone number';
                                  } else if (isNumeric(value) == false) {
                                    return 'Please enter a valid phone number';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: DropdownButtonFormField<String>(
                                value: _selectedSex,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedSex = newValue;
                                  });
                                },
                                items: <String>[
                                  'Male',
                                  'Female'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.wc_outlined),
                                  labelText: 'Sex',
                                  hintText: 'Select Sex',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a value';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextFormField(
                                // birth day
                                controller: _birthDate,
                                showCursor: false,
                                autocorrect: false,
                                enableSuggestions: false,
                                keyboardType: TextInputType.datetime,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.calendar_today_outlined),
                                  labelText: 'Birth Date',
                                  hintText: 'Tap to select birth date',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  var results =
                                      await showCalendarDatePicker2Dialog(
                                    context: context,
                                    config:
                                        CalendarDatePicker2WithActionButtonsConfig(
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    ),
                                    dialogSize: const Size(325, 400),
                                    value: [DateTime.now()],
                                    borderRadius: BorderRadius.circular(15),
                                  );
                                  // get variable results type

                                  dateTimeBday = results![0];
                                  var stringBday = dateTimeBday.toString();
                                  List returnVals =
                                      reformatDate(stringBday, dateTimeBday!);
                                  String reformattedBday = returnVals[0];
                                  ageFromBday = returnVals[1];
                                  _birthDate.text = reformattedBday;
                                },

                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your birth date';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),

                            Container(
                              child: ageFromBday != null
                                  ? Text(
                                      'You are currently $ageFromBday years of age',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    )
                                  : const Text(''),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: FractionallySizedBox(
                                widthFactor: 1,
                                child: SizedBox(
                                  height: 40.0,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ))),
                                    // onPressed is an asynchronous function because it will wait for the Firebase to complete the registration
                                    // before proceeding to the next step
                                    onPressed: () async {
                                      // validate the form and if it is not valid, set the autovalidate mode to always
                                      // get the text from the text fields
                                      final email = _email.text;
                                      final password = _password.text;
                                      final firstName = _firstName.text;
                                      final lastName = _lastName.text;
                                      final qualifiers = _qualifiers.text == ''
                                          ? 'N/A'
                                          : _qualifiers.text;
                                      final middleName = _middleName.text == ''
                                          ? 'N/A'
                                          : _middleName.text;
                                      final phoneNumber = _phoneNumber.text;
                                      final birthDate = dateTimeBday.toString();
                                      // try to register the user
                                      try {
                                        // set the autovalidate mode to disabled so that the form will not show errors
                                        if (_formKey.currentState!.validate()) {
                                          // if the form is valid, set the autovalidate mode to disabled:
                                          setState(() => _autoValidate =
                                              AutovalidateMode.disabled);
                                          // if the form is valid, then proceed to the next step:
                                          // create the user
                                          final userCredential =
                                              await FirebaseAuth.instance
                                                  .createUserWithEmailAndPassword(
                                                      email: email,
                                                      password: password);
                                          User user = userCredential.user!;
                                          user.updateDisplayName(firstName);

                                          // Realtime Database User
                                          await registrationRef
                                              .child(userCredential.user!.uid)
                                              .set({
                                            'email': email,
                                            'firstName': firstName,
                                            'lastName': lastName,
                                            'qualifiers': qualifiers,
                                            'middleName': middleName,
                                            'phoneNumber': phoneNumber,
                                            'birthDate': birthDate,
                                            'sex': _selectedSex,
                                            'reportCount': '0'
                                          });

                                          if (kDebugMode) {
                                            print(
                                                '[REGISTERED] $userCredential');
                                          }

                                          // // navigate to the login page
                                          // if(mounted){
                                          //   Navigator.pop(context);
                                          // }
                                          if (mounted) {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const VerifyEmailView()));
                                          }
                                        } else {
                                          // if the form is not valid, set the autovalidate mode to always
                                          setState(() => _autoValidate =
                                              AutovalidateMode.always);
                                          // if the form is not valid, then show the error message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Please fill up the form correctly')));
                                        }
                                        // if the user is not created, then show the error message
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code == 'email-already-in-use') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Email already in use!'),
                                            ),
                                          );
                                        } else if (e.code == 'weak-password') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Weak Password!'),
                                            ),
                                          );
                                        } else if (e.code == 'invalid-email') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Invalid email!'),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Something Wrong Happened'),
                                            ),
                                          );
                                          if (kDebugMode) {
                                            print('[ERROR]: $e');
                                          }
                                        }
                                      }
                                    },
                                    onLongPress: () {
                                      if (kDebugMode) {
                                        // this will be removed later
                                        print(
                                            '[LONG PRESS] long press done, we can do something here');
                                      }
                                      //
                                      // show a snackbar
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Long Pressed'),
                                      ));
                                    },
                                    child: Text('Register',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: RichText(
                                textAlign: TextAlign.left,
                                text: const TextSpan(
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.black),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            'By signing up, you’re agreeing to our'),
                                    TextSpan(
                                        text: ' Terms & Conditions',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    TextSpan(text: ' or '),
                                    TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),

                            Center(
                              child: Container(
                                padding: const EdgeInsets.only(top: 10),
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Joined us before? Login',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ], // children
                        ),
                      ),
                    ),
                  ),
                );
              default:
                return const Center(child: Text('Loading . . . '));
            }
          },
        ),
      ),
    );
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }
}
