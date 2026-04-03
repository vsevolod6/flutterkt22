import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (DefaultFirebaseOptions.useAuthEmulator) {
    await FirebaseAuth.instance.useAuthEmulator(
      DefaultFirebaseOptions.authEmulatorHost,
      DefaultFirebaseOptions.authEmulatorPort,
    );
  }

  runApp(const MyApp(firebaseEnabled: true));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.firebaseEnabled = false});

  final bool firebaseEnabled;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(firebaseEnabled: firebaseEnabled);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Email Auth Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: AuthShell(authService: authService),
    );
  }
}

class AuthService {
  const AuthService({required this.firebaseEnabled});

  final bool firebaseEnabled;

  bool get isAvailable => firebaseEnabled;

  bool get usesEmulator =>
      firebaseEnabled && DefaultFirebaseOptions.useAuthEmulator;

  User? get currentUser =>
      firebaseEnabled ? FirebaseAuth.instance.currentUser : null;

  Stream<User?> authStateChanges() {
    if (!firebaseEnabled) {
      return Stream<User?>.value(null);
    }

    return FirebaseAuth.instance.authStateChanges();
  }

  Future<void> signIn({required String email, required String password}) async {
    _ensureEnabled();

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    _ensureEnabled();

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> signOut() async {
    _ensureEnabled();
    await FirebaseAuth.instance.signOut();
  }

  void _ensureEnabled() {
    if (!firebaseEnabled) {
      throw StateError('Authentication service is unavailable.');
    }
  }
}

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      initialData: authService.currentUser,
      builder: (context, snapshot) {
        return HomePage(authService: authService, user: snapshot.data);
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.authService, required this.user});

  final AuthService authService;
  final User? user;

  bool get isAuthorized => user != null;

  Future<void> _openAuthPage(BuildContext context) async {
    if (!authService.isAvailable) {
      _showMessage(
        context,
        'Authentication is unavailable in the current app mode.',
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(authService: authService),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = user?.email ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAuthorized ? 'Signed in: $email' : 'Guest mode'),
        actions: [
          if (isAuthorized)
            TextButton(
              onPressed: () async {
                await authService.signOut();
              },
              child: const Text('Log out'),
            )
          else
            TextButton(
              onPressed: () => _openAuthPage(context),
              child: const Text('Sign in'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final featureWidth = constraints.maxWidth < 700
                    ? constraints.maxWidth
                    : 320.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (authService.usesEmulator) const _EmulatorBanner(),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAuthorized
                                  ? 'Full functionality is available.'
                                  : 'The app works without authorization, but with limits.',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isAuthorized
                                  ? 'You can open protected features, keep personal data, and sign out at any time.'
                                  : 'Guests can browse the public part of the app. Protected actions require email and password sign-in through Firebase.',
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    _showMessage(
                                      context,
                                      'Public catalog opened. This feature works for everyone.',
                                    );
                                  },
                                  child: const Text('Open public feature'),
                                ),
                                if (!isAuthorized)
                                  OutlinedButton(
                                    onPressed: () => _openAuthPage(context),
                                    child: const Text('Sign in / Register'),
                                  ),
                                if (isAuthorized)
                                  OutlinedButton(
                                    onPressed: () async {
                                      await authService.signOut();
                                    },
                                    child: const Text('Log out'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Available to all users',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: featureWidth,
                          child: FeatureCard(
                            title: 'Browse lessons',
                            description:
                                'Open the training catalog and study public materials.',
                            buttonLabel: 'Open',
                            icon: Icons.menu_book_outlined,
                            onPressed: () {
                              _showMessage(
                                context,
                                'Public lessons are available in guest mode.',
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: featureWidth,
                          child: FeatureCard(
                            title: 'Contact support',
                            description:
                                'Read public contact information and send a question.',
                            buttonLabel: 'View contacts',
                            icon: Icons.support_agent_outlined,
                            onPressed: () {
                              _showMessage(
                                context,
                                'Contacts opened. This is public functionality.',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Available after authorization',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: featureWidth,
                          child: FeatureCard(
                            title: 'Personal favorites',
                            description:
                                'Save materials to your personal list in the cloud.',
                            buttonLabel: isAuthorized
                                ? 'Open favorites'
                                : 'Unlock with sign-in',
                            icon: Icons.favorite_border,
                            isLocked: !isAuthorized,
                            onPressed: () {
                              if (isAuthorized) {
                                _showMessage(
                                  context,
                                  'Favorites opened. Protected feature is available.',
                                );
                                return;
                              }

                              _openAuthPage(context);
                            },
                          ),
                        ),
                        SizedBox(
                          width: featureWidth,
                          child: FeatureCard(
                            title: 'Export progress report',
                            description:
                                'Generate a private report with your personal activity.',
                            buttonLabel: isAuthorized
                                ? 'Export report'
                                : 'Sign in required',
                            icon: Icons.lock_outline,
                            isLocked: !isAuthorized,
                            onPressed: () {
                              if (isAuthorized) {
                                _showMessage(
                                  context,
                                  'Private report generated for the authorized user.',
                                );
                                return;
                              }

                              _openAuthPage(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.icon,
    required this.onPressed,
    this.isLocked = false,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 22, child: Icon(icon)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                if (isLocked) const Icon(Icons.lock, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await widget.authService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await widget.authService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mapFirebaseError(error.code))));
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected authentication error.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password must contain at least 6 characters.';
      case 'network-request-failed':
        return widget.authService.usesEmulator
            ? 'Auth emulator is unavailable. Start it with: npm run auth:emulator'
            : 'Network error while contacting Firebase.';
      default:
        return 'Authentication failed: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Sign in' : 'Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLogin
                            ? 'Email and password authorization'
                            : 'Create a new account',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (widget.authService.usesEmulator)
                        Text(
                          'Connected to the local Firebase Auth emulator.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your email.';
                          }

                          if (!value.contains('@')) {
                            return 'Enter a valid email.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your password.';
                          }

                          if (value.length < 6) {
                            return 'Minimum length is 6 characters.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_isLogin ? 'Sign in' : 'Register'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() => _isLogin = !_isLogin);
                              },
                        child: Text(
                          _isLogin
                              ? 'No account yet? Create one'
                              : 'Already have an account? Sign in',
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('Continue as guest'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmulatorBanner extends StatelessWidget {
  const _EmulatorBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.developer_mode_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Local Firebase Auth emulator mode is enabled. Start it with: npm run auth:emulator',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
