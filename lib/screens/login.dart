import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/provider.dart';
import 'package:proyecto_flutter/screens/navigation.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // IMPORTANTE: sin const, para poder usar este valor abajo
    final clientId =
        '818985157187-0jt2i61e6fsk49c1mm208ea60idu8j32.apps.googleusercontent.com';

    // Función común para cuando ya tenemos un usuario autenticado
    Future<void> _handleAuthUser(
      BuildContext ctx,
      User user, {
      required bool isNewUser,
    }) async {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final userDoc = usersRef.doc(user.uid);
      final docSnapshot = await userDoc.get();

      // Si el usuario no existe en Firestore, crearlo
      try {
        if (!docSnapshot.exists) {
          await userDoc.set({
            'name': user.displayName ??
                user.email?.split('@').first ??
                'Usuario',
            'email': user.email ?? '',
            'photo_url': user.photoURL ?? '',
            'preferred_zone':
                'Estacionamiento externo y profesores Norte',
            'preferred_theme': 'light',
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('Error al crear usuario en Firestore: $e');
      }

      // Sincronizar provider con Firestore/FirebaseAuth
      await appProvider.syncUserFromFirebase();

      if (!ctx.mounted) return;

      // Si es un registro nuevo, mostramos un mensajito
      if (isNewUser) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada, iniciando sesión...'),
          ),
        );
      }

      // Ir a la navegación principal
      Navigator.pushReplacement(
        ctx,
        MaterialPageRoute(builder: (_) => const Navigation()),
      );
    }

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
        // 1) Usuario ya autenticado (login normal o Google)
        AuthStateChangeAction<SignedIn>((context, state) async {
          final user = state.user;
          if (user == null) return;

          await _handleAuthUser(
            context,
            user,
            isNewUser: false,
          );
        }),

        // 2) Usuario recién creado (registro con email/password)
        AuthStateChangeAction<UserCreated>((context, state) async {
          final user = state.credential.user;
          if (user == null) return;

          await _handleAuthUser(
            context,
            user,
            isNewUser: true,
          );
        }),
      ],
    );
  }
}
