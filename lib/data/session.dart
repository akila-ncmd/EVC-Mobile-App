import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_store.dart';
import 'mock/mock_data.dart';
import 'models/models.dart';

enum AppRole { user, producer }

@immutable
class Session {
  const Session({
    this.signedIn = false,
    this.role = AppRole.user,
    this.profile,
    this.interests = const {},
  });

  final bool signedIn;
  final AppRole role;
  final UserProfile? profile;
  final Set<String> interests;

  Session copyWith({
    bool? signedIn,
    AppRole? role,
    UserProfile? profile,
    Set<String>? interests,
  }) => Session(
    signedIn: signedIn ?? this.signedIn,
    role: role ?? this.role,
    profile: profile ?? this.profile,
    interests: interests ?? this.interests,
  );
}

class SessionController extends Notifier<Session> {
  AppPersistence get _store => ref.read(persistenceProvider);

  @override
  Session build() {
    final signedIn = _store.signedIn;
    return Session(
      signedIn: signedIn,
      role: _store.role == 'producer' ? AppRole.producer : AppRole.user,
      profile: signedIn ? MockData.user : null,
      interests: _store.interests,
    );
  }

  void _persist() => _store.saveSession(
    signedIn: state.signedIn,
    role: state.role.name,
    interests: state.interests,
  );

  void chooseRole(AppRole role) {
    state = state.copyWith(role: role);
    _persist();
  }

  /// Mock sign-in. A real implementation swaps this for an auth call.
  Future<void> signIn({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(signedIn: true, profile: MockData.user);
    _persist();
  }

  Future<void> signUp({required String name, required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(signedIn: true, profile: MockData.user);
    _persist();
  }

  void toggleInterest(String interest) {
    final next = Set<String>.from(state.interests);
    next.contains(interest) ? next.remove(interest) : next.add(interest);
    state = state.copyWith(interests: next);
    _persist();
  }

  void signOut() {
    state = const Session();
    _store.clearSession();
  }
}

final sessionProvider = NotifierProvider<SessionController, Session>(
  SessionController.new,
);
