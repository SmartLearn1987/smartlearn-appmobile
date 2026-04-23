import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/features/home/presentation/bloc/home_bloc.dart';
import 'package:smart_learn/features/home/presentation/widgets/focus_tab.dart';
import 'package:smart_learn/features/home/presentation/widgets/games/game_tab.dart';
import 'package:smart_learn/features/home/presentation/widgets/home_category_tabs.dart';
import 'package:smart_learn/features/home/presentation/widgets/home_hero_section.dart';
import 'package:smart_learn/features/home/presentation/widgets/subject_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeLoadSubjects()),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeroSection(),
            HomeCategoryTabs(
              selectedIndex: _selectedTabIndex,
              onChanged: (index) =>
                  setState(() => _selectedTabIndex = index),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildTabContent(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
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
}
