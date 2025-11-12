import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/screens/navigation.dart';
import 'package:proyecto_flutter/models/user.dart' as AppUser;
import 'package:proyecto_flutter/screens/register.dart';
import 'package:proyecto_flutter/widgets/title.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider()
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/login.jpg'),
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
                if (user != null) {
                  appProvider.updateUser(
                    AppUser.User(
                      id: 1,
                      name: user.displayName ?? 'Usuario',
                      email: user.email ?? '',
                      password: '',
                    ),
                  );

                  // Ir a main.dart
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Navigation()),
                  );
                }
              }),
            ],
          );
        }

        return const Navigation();
      },
    );
  }
}
