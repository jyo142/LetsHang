import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letshang/blocs/hang_event_overview/hang_event_overview_bloc.dart';
import 'package:letshang/models/hang_event_model.dart';
import 'package:letshang/repositories/hang_event/hang_event_repository.dart';
import 'package:letshang/screens/edit_event_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letshang/screens/edit_groups_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 20.0, top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Groups',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      'No upcoming events',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.redAccent,
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditGroupsScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Create New Group',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}
