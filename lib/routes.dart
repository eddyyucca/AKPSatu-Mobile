import 'package:flutter/material.dart';
import 'screens/activity.dart';
import 'screens/approval.dart';
import 'screens/auth.dart';
import 'screens/camp.dart';
import 'screens/driver.dart';
import 'screens/fitness.dart';
import 'screens/ftw.dart';
import 'screens/learning.dart';
import 'screens/leave.dart';
import 'screens/mine_map.dart';
import 'screens/notif.dart';
import 'screens/p2h.dart';
import 'screens/ptw.dart';
import 'screens/requests.dart';
import 'screens/roster.dart';
import 'screens/shell.dart';
import 'screens/trip.dart';
import 'screens/itinerary.dart';
import 'screens/profile.dart';
import 'screens/splash.dart';

class R {
  static const splash = '/splash';
  static const login = '/';
  static const token = '/token';
  static const home = '/home';
  static const absensi = '/absensi';
  static const roster = '/roster';
  static const cuti = '/cuti';
  static const ftw = '/ftw';
  static const makan = '/makan';
  static const profil = '/profil';
  static const detailProfil = '/profil/detail';
  static const ubahPassword = '/profil/password';
  static const privasi = '/profil/privasi';
  static const fitness = '/fitness';
  static const fitnessRecord = '/fitness/rekam';
  static const camp = '/camp';
  static const perjalanan = '/perjalanan';
  static const notifikasi = '/notifikasi';
  static const notifPush = '/notifikasi/push';
  static const pengajuanCuti = '/pengajuan/cuti';
  static const pengajuanLembur = '/pengajuan/lembur';
  static const itinerary = '/itinerary';
  static const approval = '/approval';
  static const approvalDetail = '/approval/detail';
  static const driver = '/driver';
  static const myActivity = '/activity';
  static const formKerja = '/activity/form';
  static const p2h = '/p2h';
  static const ptw = '/ptw';
  static const ptwForm = '/ptw/buat';
  static const learning = '/learning';
  static const peta = '/peta';
}

final Map<String, WidgetBuilder> routes = {
  R.splash: (_) => const SplashScreen(),
  R.login: (_) => const LoginScreen(),
  R.token: (_) => const TokenScreen(),
  R.home: (_) => const MainShell(),
  R.absensi: (_) => const MainShell(initialIndex: 1),
  R.makan: (_) => const MainShell(initialIndex: 2),
  R.profil: (_) => const MainShell(initialIndex: 3),
  R.detailProfil: (_) => const DetailProfileScreen(),
  R.ubahPassword: (_) => const ChangePasswordScreen(),
  R.privasi: (_) => const PrivacyScreen(),
  R.roster: (_) => const RosterScreen(),
  R.cuti: (_) => const LeaveScreen(),
  R.ftw: (_) => const FtwScreen(),
  R.fitness: (_) => const FitnessScreen(),
  R.fitnessRecord: (_) => const FitnessRecordScreen(),
  R.camp: (_) => const CampScreen(),
  R.perjalanan: (_) => const TripScreen(),
  R.notifikasi: (_) => const NotifScreen(),
  R.notifPush: (_) => const NotifPushScreen(),
  R.pengajuanCuti: (_) => const LeaveRequestScreen(),
  R.pengajuanLembur: (_) => const OvertimeScreen(),
  R.itinerary: (_) => const ItineraryScreen(),
  R.approval: (_) => const ApprovalInboxScreen(),
  R.approvalDetail: (_) => const ApprovalDetailScreen(),
  R.driver: (_) => const DriverScreen(),
  R.myActivity: (_) => const MyActivityScreen(),
  R.formKerja: (_) => const FormKerjaScreen(),
  R.p2h: (_) => const P2hScreen(),
  R.ptw: (_) => const PtwScreen(),
  R.ptwForm: (_) => const PtwFormScreen(),
  R.learning: (_) => const LearningScreen(),
  R.peta: (_) => const MineMapScreen(),
};
