import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class PhoneNumberVerified extends AuthEvent {
  final String phoneNumber;

  const PhoneNumberVerified(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerificationCompleted extends AuthEvent {
  final PhoneAuthCredential credential;

  const VerificationCompleted(this.credential);

  @override
  List<Object?> get props => [credential];
}

class VerificationFailed extends AuthEvent {
  final FirebaseAuthException exception;

  const VerificationFailed(this.exception);

  @override
  List<Object?> get props => [exception];
}

class CodeSent extends AuthEvent {
  final String verificationId;
  final int? resendToken;

  const CodeSent(this.verificationId, this.resendToken);

  @override
  List<Object?> get props => [verificationId, resendToken];
}

class CodeAutoRetrievalTimeout extends AuthEvent {
  final String verificationId;

  const CodeAutoRetrievalTimeout(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class VerifyOTP extends AuthEvent {
  final String otp;
  final String verificationId;

  const VerifyOTP(this.otp, this.verificationId);

  @override
  List<Object?> get props => [otp, verificationId];
}

class SignOutRequested extends AuthEvent {}

