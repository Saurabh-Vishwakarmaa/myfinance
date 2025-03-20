import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:myfinance/config.dart';
import 'package:flutter/material.dart';

class AuthApp extends StatefulWidget {
  final Account account;
  const AuthApp({super.key, required this.account});

  @override
  State<AuthApp> createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> {
  late Account account;
  models.User? loggedInUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize Appwrite client
    final client = Client()
      .setEndpoint(Config.endpoint)
      .setProject(Config.projectId);

    account = Account(client);
    
    // Check if user is already logged in
    checkSession();
  }

  Future<void> checkSession() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final user = await account.get();
      setState(() {
        loggedInUser = user;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        loggedInUser = null;
        isLoading = false;
      });
      print("Session check error: $e");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await account.createEmailPasswordSession(email: email, password: password);
      final user = await account.get();
      setState(() {
        loggedInUser = user;
      });
    } catch (e) {
      print("Login Error: $e");
      rethrow; // Rethrow to handle in the login page
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      await account.create(userId: ID.unique(), email: email, password: password, name: name);
      await login(email, password);
    } catch (e) {
      print("Registration Error: $e");
      rethrow; // Rethrow to handle in the register page
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
      setState(() {
        loggedInUser = null;
      });
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (loggedInUser == null) {
      return LoginRegisterNavigator(
        login: login,
        register: register,
      );
    } else {
      return MainPage(
        user: loggedInUser!,
        logout: logout,
      );
    }
  }
}

class LoginRegisterNavigator extends StatefulWidget {
  final Future<void> Function(String email, String password) login;
  final Future<void> Function(String email, String password, String name) register;

  const LoginRegisterNavigator({
    Key? key,
    required this.login,
    required this.register,
  }) : super(key: key);

  @override
  State<LoginRegisterNavigator> createState() => _LoginRegisterNavigatorState();
}

class _LoginRegisterNavigatorState extends State<LoginRegisterNavigator> {
  bool showLogin = true;

  void toggleView() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return LoginPage(
        login: widget.login,
        onRegisterTap: toggleView,
      );
    } else {
      return RegisterPage(
        register: widget.register,
        onLoginTap: toggleView,
      );
    }
  }
}

class LoginPage extends StatefulWidget {
  final Future<void> Function(String email, String password) login;
  final VoidCallback onRegisterTap;

  const LoginPage({
    Key? key,
    required this.login,
    required this.onRegisterTap,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Email and password are required";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await widget.login(emailController.text, passwordController.text);
    } catch (e) {
      setState(() {
        errorMessage = "Failed to login: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 8.0),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isLoading ? null : handleLogin,
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(
                  onPressed: widget.onRegisterTap,
                  child: Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  final Future<void> Function(String email, String password, String name) register;
  final VoidCallback onLoginTap;

  const RegisterPage({
    Key? key,
    required this.register,
    required this.onLoginTap,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> handleRegister() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty) {
      setState(() {
        errorMessage = "All fields are required";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await widget.register(
        emailController.text,
        passwordController.text,
        nameController.text,
      );
    } catch (e) {
      setState(() {
        errorMessage = "Failed to register: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 8.0),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isLoading ? null : handleRegister,
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Register'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(
                  onPressed: widget.onLoginTap,
                  child: Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final models.User user;
  final VoidCallback logout;

  const MainPage({
    Key? key,
    required this.user,
    required this.logout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                        style: TextStyle(fontSize: 32, color: Colors.blue.shade800),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Welcome, ${user.name}!",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Email: ${user.email}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "User ID: ${user.$id}",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Your Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile Settings"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to profile settings
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.security),
              title: Text("Security"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to security settings
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notifications"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to notification settings
              },
            ),
            Divider(),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout),
                label: Text("Logout"),
                onPressed: logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}