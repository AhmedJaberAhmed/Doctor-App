import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

 import 'Admin/create_doctor_usecase.dart';
import 'Admin/data/doctor_remote_datasource_impl.dart';
import 'Admin/data/doctor_repository_impl.dart';
import 'Admin/presentation/Cubits/admin_add_doctor/admin_add_doctor_cubit.dart';
import 'Admin/presentation/admin_add_doctor_page.dart';

 import 'Auth/data/auth_remote_datasource_impl.dart';
import 'Auth/data/auth_repository_impl.dart';
import 'Auth/get_session_user.dart';
import 'Auth/presentaion/auth_gate.dart';
import 'Auth/presentaion/bloc/auth_cubit.dart';
import 'Auth/sign_in.dart';
import 'Auth/sign_up.dart';

 import 'Home/data/home_remote_datasource_impl.dart';
import 'Home/data/home_repository_impl.dart';
import 'Home/domain/book_appointment.dart';
import 'Home/domain/get_categories.dart';
import 'Home/domain/get_doctor_availability.dart';
import 'Home/domain/get_doctor_details.dart';
import 'Home/domain/get_doctors_by_category.dart';
import 'Home/favourites/presentaion/favourites_cubit.dart';
 import 'Home/presentaion/MainNavigationPage.dart';
import 'Home/presentaion/cubits/booking_cubit.dart';
import 'Home/presentaion/cubits/categories_cubit.dart';
import 'Home/presentaion/cubits/doctor_details_cubit.dart';
import 'Home/presentaion/cubits/doctors_cubit.dart';
import 'Home/presentaion/cubits/get_doctor_booked_appointments.dart';
 import 'orders/data/AppointmentRepositoryImpl.dart';
import 'orders/data/appointment UseCase.dart';
import 'orders/presentaion/BookingsCubit.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tbqhtauqcltofhnxphbw.supabase.co',
    anonKey: 'sb_publishable_1lbQCDtP5reTCLOsinFPkA_GZElo6cp',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

     final doctorRemote = DoctorRemoteDataSourceImpl(supabase: supabase);
    final doctorRepo = DoctorRepositoryImpl(doctorRemote);
    final createDoctorUsecase = CreateDoctorUseCase(doctorRepo);


    final authRemote = AuthRemoteDataSourceImpl(supabase: supabase);
    final authRepo = AuthRepositoryImpl(authRemote);

    final signUp = SignUp(authRepo);
    final signIn = SignIn(authRepo);
    final signOut = SignOut(authRepo);
    final getCurrent = GetSessionUser(authRepo);

     final homeRemote = HomeRemoteDataSourceImpl(supabase: supabase);
    final homeRepo = HomeRepositoryImpl(homeRemote);

    final getCategories = GetCategories(homeRepo);
    final getDoctorsByCategory = GetDoctorsByCategory(homeRepo);
    final getDoctorDetails = GetDoctorDetails(homeRepo);
    final getDoctorAvailability = GetDoctorAvailability(homeRepo);
    final getDoctorBookedAppointments = GetDoctorBookedAppointments(homeRepo);
    final bookAppointment = BookAppointment(homeRepo);

     final appointmentRepo = AppointmentRepositoryImpl(supabase);
    final getAppointments = GetUserAppointmentsUseCase(appointmentRepo);
    final cancelAppointment = CancelAppointmentUseCase(appointmentRepo);

    return MultiBlocProvider(
      providers: [
         BlocProvider(
          create: (_) => AuthCubit(
            signUpUc: signUp,
            signInUc: signIn,
            signOutUc: signOut,
            getCurrentUc: getCurrent,
          ),
        ),

         BlocProvider(
          create: (_) => AdminAddDoctorCubit(createDoctor: createDoctorUsecase),
        ),

         BlocProvider(
          create: (_) => CategoriesCubit(getCategories: getCategories),
        ),
        BlocProvider(
          create: (_) => DoctorsCubit(getDoctorsByCategory: getDoctorsByCategory),
        ),
        BlocProvider(
          create: (_) => DoctorDetailsCubit(
            getDoctorDetails: getDoctorDetails,
            getDoctorAvailability: getDoctorAvailability,
            getDoctorBookedAppointments: getDoctorBookedAppointments,
          ),
        ),
        BlocProvider(
          create: (_) => BookingCubit(bookAppointment: bookAppointment),
        ),

         BlocProvider(
          create: (_) => FavouritesCubit(),
        ),

         BlocProvider(
          create: (_) => BookingsCubit(
            getAppointments: getAppointments,
            cancelAppointment: cancelAppointment,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2DAAE1),
            primary: const Color(0xFF2DAAE1),
            secondary: const Color(0xFF1DA1F2),
            error: const Color(0xFFE53935),
            background: const Color(0xFFF7F9FC),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DAAE1),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        home: AuthGate(
          userHome: const MainNavigationPage(),
          adminHome: const AdminAddDoctorPage(),
        ),
      ),
    );
  }
}