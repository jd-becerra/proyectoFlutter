// ESTO ES UNA PLANTILLA TEMPORAL, BORRAR CUANDO VAYAS A ESCRIBIR TU PROPIO CÓDIGO

import 'package:flutter/material.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/models/user.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.loggedInUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Name: ${user.name}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Email: ${user.email}', style: TextStyle(fontSize: 20)),
                ],
              )
            : Text('No user logged in', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}