import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthCodeSent) {
              _verificationId = state.verificationId;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP Sent!")));
            }
            if (state is AuthVerified) {
              context.go('/home');
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) return const Center(child: CircularProgressIndicator());
            if (state is AuthCodeSent) return _buildOtpInput(context);
            return _buildPhoneInput(context);
          },
        ),
      ),
    );
  }

  Widget _buildPhoneInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 80, color: Color(0xFFFF4081)),
          const SizedBox(height: 20),
          const Text("Start Dating", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              prefixText: "+91 ", 
              labelText: "Phone Number",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final phone = "+91${_phoneController.text.trim()}";
              context.read<AuthBloc>().add(SendOtpEvent(phone));
            },
            child: const Text("Send OTP"),
          )
        ],
      ),
    );
  }

  Widget _buildOtpInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Verify Number", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 30),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: "Enter OTP"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_verificationId != null) {
                context.read<AuthBloc>().add(VerifyOtpEvent(_otpController.text, _verificationId!));
              }
            },
            child: const Text("Verify & Login"),
          )
        ],
      ),
    );
  }
}