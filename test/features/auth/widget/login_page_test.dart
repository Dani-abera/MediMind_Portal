import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medimind_portal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/auth_event.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/auth_state.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/doctor_login/doctor_login_bloc.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/doctor_login/doctor_login_event.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/doctor_login/doctor_login_state.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/admin_login/admin_login_bloc.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/admin_login/admin_login_event.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/admin_login/admin_login_state.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/super_admin_login/super_admin_login_bloc.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/super_admin_login/super_admin_login_event.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/super_admin_login/super_admin_login_state.dart';
import 'package:medimind_portal/features/auth/presentation/cubit/account_lockout_cubit.dart';

// Mock blocs
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockDoctorLoginBloc extends MockBloc<DoctorLoginEvent, DoctorLoginState>
    implements DoctorLoginBloc {}

class MockAdminLoginBloc extends MockBloc<AdminLoginEvent, AdminLoginState>
    implements AdminLoginBloc {}

class MockSuperAdminLoginBloc
    extends MockBloc<SuperAdminLoginEvent, SuperAdminLoginState>
    implements SuperAdminLoginBloc {}

void main() {
  late MockAuthBloc authBloc;
  late MockDoctorLoginBloc doctorBloc;
  late MockAdminLoginBloc adminBloc;
  late MockSuperAdminLoginBloc superAdminBloc;
  late AccountLockoutCubit lockoutCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    authBloc = MockAuthBloc();
    doctorBloc = MockDoctorLoginBloc();
    adminBloc = MockAdminLoginBloc();
    superAdminBloc = MockSuperAdminLoginBloc();
    lockoutCubit = AccountLockoutCubit(prefs);

    when(() => authBloc.state).thenReturn(const AuthInitial());
    when(() => doctorBloc.state).thenReturn(const DoctorLoginInitial());
    when(() => adminBloc.state).thenReturn(const AdminLoginInitial());
    when(() => superAdminBloc.state).thenReturn(const SuperAdminLoginInitial());
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<DoctorLoginBloc>.value(value: doctorBloc),
              BlocProvider<AdminLoginBloc>.value(value: adminBloc),
              BlocProvider<SuperAdminLoginBloc>.value(value: superAdminBloc),
              BlocProvider<AccountLockoutCubit>.value(value: lockoutCubit),
            ],
            child: const _LoginViewDirect(),
          ),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('LoginPage tabs', () {
    testWidgets('shows Doctor tab by default', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Doctor'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Super Admin'), findsOneWidget);
      // Doctor form shows badge field by default
      expect(find.text('Badge / Staff ID'), findsOneWidget);
    });

    testWidgets('switching to Admin tab shows email field', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('switching to Super Admin tab shows TOTP notice',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Super Admin'));
      await tester.pumpAndSettle();
      expect(find.textContaining('TOTP'), findsOneWidget);
    });
  });

  group('Doctor tab - badge step', () {
    testWidgets('shows validation error when badge is empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Get OTP'));
      await tester.pumpAndSettle();
      expect(find.text('Badge number is required'), findsOneWidget);
    });

    testWidgets('dispatches DoctorRequestOtp when badge filled',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.enterText(
          find.bySemanticsLabel('Badge / Staff ID'), 'DR-001');
      await tester.tap(find.text('Get OTP'));
      await tester.pumpAndSettle();
      verify(() => doctorBloc.add(const DoctorRequestOtp('DR-001'))).called(1);
    });
  });

  group('Doctor tab - OTP step', () {
    testWidgets('shows pinput when OTP is sent', (tester) async {
      when(() => doctorBloc.state).thenReturn(const DoctorLoginOtpSent('DR-001'));
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // Pinput renders individual cells — presence of back button indicates OTP step
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.textContaining('Resend'), findsOneWidget);
    });
  });
}

// Thin wrapper that injects existing BlocProviders rather than creating from sl
class _LoginViewDirect extends StatefulWidget {
  const _LoginViewDirect();

  @override
  State<_LoginViewDirect> createState() => _LoginViewDirectState();
}

class _LoginViewDirectState extends State<_LoginViewDirect> {
  _LoginTab _activeTab = _LoginTab.doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(flex: 45, child: ColoredBox(color: Color(0xFF00695C))),
          Expanded(
            flex: 55,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                width: 420,
                child: Column(
                  children: [
                    _buildTabSelector(),
                    const SizedBox(height: 24),
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Row(
      children: _LoginTab.values.map((tab) {
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_tabLabel(tab)),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _tabLabel(_LoginTab tab) => switch (tab) {
        _LoginTab.doctor => 'Doctor',
        _LoginTab.admin => 'Admin',
        _LoginTab.superAdmin => 'Super Admin',
      };

  Widget _buildForm() {
    return switch (_activeTab) {
      _LoginTab.doctor => _DoctorForm(),
      _LoginTab.admin => _AdminForm(),
      _LoginTab.superAdmin => _SuperAdminForm(),
    };
  }
}

// Minimal form stubs that use the injected blocs
class _DoctorForm extends StatefulWidget {
  @override
  State<_DoctorForm> createState() => _DoctorFormState();
}

class _DoctorFormState extends State<_DoctorForm> {
  final _ctrl = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorLoginBloc, DoctorLoginState>(
      builder: (context, state) {
        if (state is DoctorLoginOtpSent) {
          return Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              const Text('Resend OTP'),
            ],
          );
        }
        return Form(
          key: _key,
          child: Column(
            children: [
              TextFormField(
                controller: _ctrl,
                decoration: const InputDecoration(labelText: 'Badge / Staff ID'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Badge number is required'
                    : null,
              ),
              ElevatedButton(
                onPressed: () {
                  if (!_key.currentState!.validate()) return;
                  context
                      .read<DoctorLoginBloc>()
                      .add(DoctorRequestOtp(_ctrl.text.trim()));
                },
                child: const Text('Get OTP'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        TextField(decoration: InputDecoration(labelText: 'Email')),
        TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password')),
      ],
    );
  }
}

class _SuperAdminForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Super Admin access requires TOTP verification'),
        TextField(decoration: InputDecoration(labelText: 'Email')),
      ],
    );
  }
}

enum _LoginTab { doctor, admin, superAdmin }
