import 'package:bookmywod_admin/bloc/auth_bloc.dart';
import 'package:bookmywod_admin/bloc/events/auth_event_logout.dart';
import 'package:bookmywod_admin/services/auth/auth_user.dart';
import 'package:bookmywod_admin/services/database/models/trainer_model.dart';
import 'package:bookmywod_admin/services/database/supabase_storage/supabase_db.dart';
import 'package:bookmywod_admin/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SideNavbar extends StatelessWidget {
  final TrainerModel userModel;
  final AuthUser authUser;
  final SupabaseDb supabaseDb;
  const SideNavbar({
    super.key,
    required this.userModel,
    required this.authUser,
    required this.supabaseDb,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userModel.fullName,
              style: GoogleFonts.barlow(),
            ),
            accountEmail: Text(
              authUser.email,
              style: GoogleFonts.barlow(),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                userModel.avatarUrl ?? 'assets/home/default_profile.png',
              ),
            ),
            decoration: BoxDecoration(
              color: customBlue,
            ),
          ),
          ListTile(
            leading: SvgPicture.asset('assets/icons/run.svg'),
            title: Text('Activity'),
          ),
          ListTile(
            leading: SvgPicture.asset('assets/icons/membership.svg'),
            title: Text('Membership'),
          ),
          ListTile(
            leading: SvgPicture.asset('assets/icons/report.svg'),
            title: Text('Report'),
          ),
          ListTile(
            leading: SvgPicture.asset('assets/icons/contact.svg'),
            title: Text('Contact Book My  WOD Team'),
          ),
          ListTile(
            leading: SvgPicture.asset('assets/icons/logout.svg'),
            title: Text('Logout'),
            onTap: () {
              context.read<AuthBloc>().add(
                    AuthEventLogout(),
                  );
            },
          ),
          const SizedBox(
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(),
              onPressed: () {
                GoRouter.of(context).push('/add-admin', extra: {
                  'authUser': authUser,
                  'userModel': userModel,
                  'supabaseDb': supabaseDb,
                });
              },
              child: Row(
                children: [
                  Icon(
                    size: 23,
                    Icons.add,
                    color: Colors.white,
                  ),
                  Spacer(),
                  Text(
                    'Add Admin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
