import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/core/widgets/app_cached_image.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/home/presentation/bloc/home_bloc.dart';
import 'package:smart_learn/features/home/presentation/widgets/focus_tab.dart';
import 'package:smart_learn/features/home/presentation/widgets/games/game_tab.dart';
import 'package:smart_learn/features/home/presentation/widgets/home_category_tabs.dart';
import 'package:smart_learn/features/home/presentation/widgets/home_hero_section.dart';
import 'package:smart_learn/features/home/presentation/widgets/subject_tab.dart';

import '../../../../core/theme/theme.dart';
import '../../../../router/route_names.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<HomeBloc>().add(const HomeRefreshSubjects());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar (scrolls away with content) ──────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            // title: Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     const SizedBox(width: 56),
            //     const Icon(
            //       LucideIcons.library,
            //       size: 24,
            //       color: AppColors.brandBrown,
            //     ),
            //     const SizedBox(width: AppSpacing.sm),
            //     Text(
            //       'Smart Learn',
            //       style: AppTypography.h3.copyWith(color: AppColors.primary),
            //     ),
            //   ],
            // ),
            actions: [
              GestureDetector(
                onTap: () => context.pushNamed(RouteNames.profile),
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppBorders.widthThin,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: user?.avatarUrl != null
                      ? AppCachedImage(
                          imageUrl: user!.avatarUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: Center(
                            child: Text(
                              _initials(user?.displayName ?? user?.username),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),

          // ── Hero section ─────────────────────────────────────────────────
          const SliverToBoxAdapter(child: HomeHeroSection()),

          // ── Category tabs (sticky) ────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabsDelegate(
              child: HomeCategoryTabs(
                selectedIndex: _selectedTabIndex,
                onChanged: (index) => setState(() => _selectedTabIndex = index),
              ),
            ),
          ),

          // ── Tab content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: AppSpacing.xl,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildTabContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_selectedTabIndex) {
      0 => const SubjectTab(key: ValueKey('subject')),
      1 => const GameTab(key: ValueKey('game')),
      2 => const FocusTab(key: ValueKey('focus')),
      _ => const SubjectTab(key: ValueKey('subject')),
    };
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

// ── Sticky tabs delegate ──────────────────────────────────────────────────────

class _StickyTabsDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabsDelegate({required this.child});

  final Widget child;

  // Height = tab bar padding (xs * 2) + icon (18) + spacing (sm) + text (~20) + smMd padding * 2
  static const double _height = 76;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyTabsDelegate oldDelegate) =>
      oldDelegate.child != child;
}
