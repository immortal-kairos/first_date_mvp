import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';

// --- EVENTS ---
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;
  SendOtpEvent(this.phoneNumber);
}

class VerifyOtpEvent extends AuthEvent {
  final String otpCode;
  final String verificationId;
  VerifyOtpEvent(this.otpCode, this.verificationId);
}

// --- STATES ---
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthCodeSent extends AuthState {
  final String verificationId;
  AuthCodeSent(this.verificationId);
}
class AuthVerified extends AuthState {} 
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- BLOC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    
    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: event.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            emit(AuthVerified());
          },
          verificationFailed: (FirebaseAuthException e) {
            emit(AuthError(e.message ?? "Verification Failed"));
          },
          codeSent: (String verificationId, int? resendToken) {
            emit(AuthCodeSent(verificationId));
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: event.verificationId,
          smsCode: event.otpCode,
        );
        await _auth.signInWithCredential(credential);
        emit(AuthVerified());
      } catch (e) {
        emit(AuthError("Invalid OTP"));
      }
    });
  }
}
