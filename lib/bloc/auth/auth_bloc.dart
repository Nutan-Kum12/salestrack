import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<PhoneNumberVerified>(_onPhoneNumberVerified);
    on<VerificationCompleted>(_onVerificationCompleted);
    on<VerificationFailed>(_onVerificationFailed);
    on<CodeSent>(_onCodeSent);
    on<VerifyOTP>(_onVerifyOTP);
    on<SignOutRequested>(_onSignOutRequested);
  }

  void _onPhoneNumberVerified(PhoneNumberVerified event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          add(VerificationCompleted(credential));
        },
        verificationFailed: (FirebaseAuthException e) {
          add(VerificationFailed(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          add(CodeSent(verificationId, resendToken));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          add(CodeAutoRetrievalTimeout(verificationId));
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onVerificationCompleted(VerificationCompleted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await authRepository.signInWithCredential(event.credential);
      emit(AuthVerified(userCredential.user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onVerificationFailed(VerificationFailed event, Emitter<AuthState> emit) {
    emit(AuthError(event.exception.message ?? 'Verification failed'));
  }

  void _onCodeSent(CodeSent event, Emitter<AuthState> emit) {
    emit(AuthCodeSent(event.verificationId, event.resendToken));
  }

  void _onVerifyOTP(VerifyOTP event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.otp,
      );
      UserCredential userCredential = await authRepository.signInWithCredential(credential);
      emit(AuthVerified(userCredential.user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

