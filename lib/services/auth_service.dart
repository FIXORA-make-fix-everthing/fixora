import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserModel? userModel;

  AuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.userModel,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Realtime Database reference
  DatabaseReference get _usersRef => _database.ref('users');

  // Get current Firebase Auth user
  User? get currentAuthUser => _auth.currentUser;

  /// Sign Up a new user with Email, Password, and User Profile Details
  Future<AuthResult> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String location,
    required UserRole role,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      // 1. Create account in Firebase Authentication
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Network request timed out during authentication.');
      });

      final String uid = userCredential.user!.uid;

      // 2. Prepare UserModel
      final userModel = UserModel(
        uid: uid,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        location: location.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      // 3. Write profile to Realtime Database with fallback rollback
      try {
        await _usersRef.child(uid).set(userModel.toMap()).timeout(const Duration(seconds: 15), onTimeout: () {
          throw Exception('Network request timed out while saving profile.');
        });
      } catch (databaseError) {
        // Rollback: Delete the Firebase Auth user if Database write fails
        await userCredential.user?.delete();
        
        String errStr = databaseError.toString();
        if (errStr.contains('permission-denied') || errStr.contains('PERMISSION_DENIED')) {
          return AuthResult(
            isSuccess: false,
            errorMessage: 'Database Permission Denied. Please ensure Database Security Rules permit writes.',
          );
        }
        return AuthResult(
          isSuccess: false,
          errorMessage: 'Failed to create user profile: ${databaseError.toString()}',
        );
      }

      return AuthResult(
        isSuccess: true,
        userModel: userModel,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _handleFirebaseAuthError(e),
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _formatGenericError(e),
      );
    }
  }

  /// Sign In an existing user with Email and Password
  Future<AuthResult> signIn({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) async {
    try {
      // 1. Authenticate with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Network request timed out during authentication.');
      });

      final String uid = userCredential.user!.uid;

      // 2. Fetch user profile from Database
      DataSnapshot userSnap = await _usersRef.child(uid).get().timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Network request timed out while fetching profile.');
      });

      UserModel userModel;

      if (userSnap.exists && userSnap.value != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(userSnap.value as Map);
        userModel = UserModel.fromMap(data, uid);
      } else {
        // Fallback: If user doc is missing in Database, auto-create a default document
        userModel = UserModel(
          uid: uid,
          firstName: email.split('@')[0],
          lastName: '',
          email: email.trim(),
          phone: '',
          location: '',
          role: selectedRole != UserRole.none ? selectedRole : UserRole.customer,
          createdAt: DateTime.now(),
        );
        await _usersRef.child(uid).set(userModel.toMap()).timeout(const Duration(seconds: 15), onTimeout: () {
          throw Exception('Network request timed out while saving default profile.');
        });
      }

      return AuthResult(
        isSuccess: true,
        userModel: userModel,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _handleFirebaseAuthError(e),
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _formatGenericError(e),
      );
    }
  }

  /// Send Password Reset Email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(isSuccess: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _handleFirebaseAuthError(e),
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _formatGenericError(e),
      );
    }
  }

  /// Sign Out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Helper to convert Firebase Auth exceptions into clean user-facing error messages
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email address already exists. Please sign in instead.';
      case 'invalid-email':
        return 'The email address is not valid. Please check and try again.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in your Firebase Console.';
      default:
        String msg = e.message ?? 'Authentication failed.';
        if (msg.contains('okhttp') || msg.contains('unexpected end of stream')) {
          return 'Network connection interrupted. Please check your internet/VPN connection and try again.';
        }
        return msg;
    }
  }

  /// Format generic errors cleanly
  String _formatGenericError(dynamic e) {
    String msg = e.toString();
    if (msg.contains('permission-denied') || msg.contains('PERMISSION_DENIED')) {
      return 'Database Permission Denied. Please ensure your Database Security Rules allow read/write.';
    }
    if (msg.contains('okhttp') || msg.contains('unexpected end of stream')) {
      return 'Network connection interrupted. Please check your internet/VPN connection and try again.';
    }
    return 'An unexpected error occurred: $msg';
  }
}
