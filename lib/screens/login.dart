import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/screens/navigation.dart';
import 'package:proyecto_flutter/models/user.dart' as AppUser;

// Firebase
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          var clientId =
              '818985157187-0jt2i61e6fsk49c1mm208ea60idu8j32.apps.googleusercontent.com';
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: clientId),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/parking_header.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text(
                        'Bienvenido al Estacionamiento ITESO, por favor inicia sesión.',
                        textAlign: TextAlign.center,
                      )
                    : const Text(
                        'Crea una cuenta para acceder al Estacionamiento ITESO.',
                        textAlign: TextAlign.center,
                      ),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Al continuar, aceptas nuestros términos y condiciones.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) async {
                final user = state.user;
                if (user == null) return;

                final usersRef = FirebaseFirestore.instance.collection('users');
                final userDoc = usersRef.doc(user.uid);
                final docSnapshot = await userDoc.get();

                // Si el usuario no existe en Firestore, crearlo
                try {
                  if (!docSnapshot.exists) {
                    await userDoc.set({
                      // Si su nombre no existe, usar correo pero quitar todo despues de @
                      'name': user.displayName ?? user.email?.split('@').first ?? 'Usuario',
                      'email': user.email ?? '',
                      'photo_url': user.photoURL ?? '',
                      'preferred_zone': 'G1', // Zona por defecto
                      'preferred_theme': 'light',
                      'created_at': FieldValue.serverTimestamp(),
                    });
                  } 
                } catch (e) {
                  // Manejar error al crear usuario
                  print('Error al crear usuario en Firestore: $e');
                }
                
                final data = (await userDoc.get()).data();

                appProvider.updateUser(
                  AppUser.User(
                    id: user.uid,
                    name: data?['name'] ?? 'Usuario',
                    email: data?['email'] ?? '',
                    photoUrl: data?['photo_url'] ?? '',
                    preferredZone: data?['preferred_zone'] ?? 'G1',
                    preferredTheme: data?['preferred_theme'] ?? 'light',
                  ),
                );

                // Ir a main.dart
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Navigation()),
                );
              }),
            ],
          );
        }

        return const Navigation();
      },
    );
  }
}
