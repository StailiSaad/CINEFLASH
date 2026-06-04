import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../data/database/app_database.dart';
import '../../../presentation/blocs/app/app_bloc.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/datasources/supabase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final database = getIt<AppDatabase>();
    final currentUser = Supabase.instance.client.auth.currentUser;
    final email = currentUser?.email ?? 'No Active Session';

    return Scaffold(
      backgroundColor: context.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, email),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(context, database),
                  const SizedBox(height: 32),
                  _buildMenuSection(context),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String email) {
    return SliverAppBar(
      expandedHeight: 280,
      backgroundColor: context.background,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    context.background,
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: context.surface,
                    child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  email.split('@')[0].toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AppDatabase database) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Activity',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FutureBuilder<List<WatchedMovy>>(
                future: database.getWatchedMovies(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _buildStatCard(
                    context,
                    'Archive',
                    count.toString(),
                    'Items Seen',
                    Icons.check_circle_outline_rounded,
                    AppColors.accent,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FutureBuilder<List<WatchlistMovy>>(
                future: database.getWatchlist(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _buildStatCard(
                    context,
                    'Vault',
                    count.toString(),
                    'To Watch',
                    Icons.bookmark_outline_rounded,
                    AppColors.primary,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, String sublabel, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.textMuted.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          Text(
            sublabel,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            final isDark = state is AppReady ? state.isDarkMode : true;
            return _buildSwitchItem(
              context,
              Icons.color_lens_outlined,
              'Theme',
              isDark ? 'Dark Mode' : 'Light Mode',
              isDark,
              (value) => context.read<AppBloc>().add(ToggleTheme()),
            );
          },
        ),
        _buildMenuItem(
          context,
          Icons.info_outline_rounded,
          'About CineFlash',
          'Version 1.0.0',
          onTap: () async {
            final url = Uri.parse('https://github.com/StailiSaad/CINEFLASH');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
        _buildMenuItem(
          context,
          Icons.logout_rounded,
          'Logout',
          'Sign out of your account',
          onTap: () async {
            final supabaseService = getIt<SupabaseService>();
            await supabaseService.signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: GoogleFonts.outfit(color: context.textPrimary, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(color: context.textMuted, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchItem(BuildContext context, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: GoogleFonts.outfit(color: context.textPrimary, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(color: context.textMuted, fontSize: 12),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }
}
