import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/widgets/app_text_field.dart';

import '../../../../app/di/injection.dart';
import '../../../../features/home/presentation/helpers/contants.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../router/route_names.dart';
import '../../../home/domain/entities/dictation_entity.dart';
import '../bloc/dictation_play_bloc.dart';
import '../widgets/dictation_card.dart';
import '../widgets/dictation_result_view.dart';

/// Main screen for the Dictation game play.
///
/// Layout (during play):
///   - AppBar (style giống Vua Tiếng Việt)
///   - Header: timer (đếm số phút đã trôi qua) + nút "Bài khác"
///   - "TIÊU ĐỀ" — card hiển thị tên bài
///   - "NỘI DUNG" — card hiển thị đoạn cần chép (scroll bên trong card nếu dài)
///   - "Chép chính tả *" — multiline TextField
///   - Nút "Kiểm tra" góc phải dưới
class DictationPlayScreen extends StatelessWidget {
  const DictationPlayScreen({required this.entity, super.key});

  final DictationEntity entity;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DictationPlayBloc>()..add(StartDictation(entity: entity)),
      child: _DictationPlayView(
        initialLevel: entity.level,
        initialLanguage: entity.language,
      ),
    );
  }
}

class _DictationPlayView extends StatelessWidget {
  const _DictationPlayView({
    required this.initialLevel,
    required this.initialLanguage,
  });

  final String initialLevel;
  final String initialLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AppBar(level: initialLevel, language: initialLanguage),
      body: SafeArea(
        child: BlocConsumer<DictationPlayBloc, DictationPlayState>(
          listenWhen: (prev, curr) {
            final prevError = _errorOf(prev);
            final currError = _errorOf(curr);
            return currError != null && currError != prevError;
          },
          listener: (context, state) {
            final error = _errorOf(state);
            if (error != null) AppToast.error(context, error);
          },
          builder: (context, state) => switch (state) {
            DictationPlayInProgress() => _InProgressBody(state: state),
            DictationPlayFinished() => DictationResultView(
              entity: state.entity,
              result: state.result,
              wordComparisons: state.wordComparisons,
              userInput: state.userInput,
              elapsedSeconds: state.elapsedSeconds,
              isLoadingNew: state.isLoadingNew,
              onTryAgain: () =>
                  context.read<DictationPlayBloc>().add(const PlayAgain()),
              onLoadNew: () => context
                  .read<DictationPlayBloc>()
                  .add(const LoadNewDictation()),
            ),
            _ => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          },
        ),
      ),
    );
  }
}

/// Trả về `errorMessage` hiện tại của state (nếu có).
String? _errorOf(DictationPlayState state) {
  if (state is DictationPlayInProgress) return state.errorMessage;
  if (state is DictationPlayFinished) return state.errorMessage;
  return null;
}

// ── AppBar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.level, required this.language});

  final String level;
  final String language;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final levelConfig = levels.firstWhere((config) => config.value == level);
    final languageLabel = language == 'vi'
        ? '🇻🇳 Tiếng Việt'
        : language == 'en'
        ? '🇺🇸 Tiếng Anh'
        : '🇯🇵 Tiếng Nhật';
    return AppBar(
      leading: BackButton(onPressed: () => context.go(RoutePaths.home)),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.book, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chép chính tả', style: AppTypography.textBase.bold),
                Row(
                  spacing: AppSpacing.xs,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: levelConfig.bg,
                          border: Border.all(color: levelConfig.border),
                          borderRadius: AppBorders.borderRadiusSm,
                        ),
                        child: Text(
                          levelConfig.label,
                          style: AppTypography.text2Xs.semiBold.withColor(
                            levelConfig.text,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      languageLabel,
                      style: AppTypography.textXs.semiBold.withColor(
                        AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── In-progress body ────────────────────────────────────────────────────────

class _InProgressBody extends StatefulWidget {
  const _InProgressBody({required this.state});

  final DictationPlayInProgress state;

  @override
  State<_InProgressBody> createState() => _InProgressBodyState();
}

class _InProgressBodyState extends State<_InProgressBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.userInput);
  }

  @override
  void didUpdateWidget(covariant _InProgressBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync khi state bên ngoài thay đổi (vd: PlayAgain reset, đổi bài).
    if (widget.state.userInput != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.state.userInput,
        selection: TextSelection.collapsed(
          offset: widget.state.userInput.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<DictationPlayBloc>().add(const SubmitAnswer());
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final entity = s.entity;
    final canSubmit = _controller.text.trim().isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.mdLg,
            AppSpacing.md,
            AppSpacing.mdLg,
            AppSpacing.sm,
          ),
          child: _Header(
            elapsedSeconds: s.elapsedSeconds,
            isLoadingNew: s.isLoadingNew,
            onLoadNew: () =>
                context.read<DictationPlayBloc>().add(const LoadNewDictation()),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.mdLg,
              AppSpacing.sm,
              AppSpacing.mdLg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── TIÊU ĐỀ ───
                const DictationSectionLabel(label: 'TIÊU ĐỀ'),
                const SizedBox(height: AppSpacing.sm),
                DictationCard(
                  child: Text(
                    entity.title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ─── NỘI DUNG ───
                const DictationSectionLabel(label: 'NỘI DUNG'),
                const SizedBox(height: AppSpacing.sm),
                DictationCard(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Text(
                          entity.content,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.foreground,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ─── Chép chính tả * ───
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Chép chính tả ',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                      TextSpan(
                        text: '*',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.destructive,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _controller,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  hintText: 'Nhập lại đoạn văn ở trên...',
                  onChanged: (text) {
                    context.read<DictationPlayBloc>().add(
                      UpdateUserInput(text: text),
                    );
                    setState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ─── "Kiểm tra" pill button (góc phải) ───
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: canSubmit ? _handleSubmit : null,
                    icon: const Icon(LucideIcons.checkCircle, size: 18),
                    label: const Text('Kiểm tra'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                      textStyle: AppTypography.buttonLarge,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.smMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.elapsedSeconds,
    required this.isLoadingNew,
    required this.onLoadNew,
  });

  final int elapsedSeconds;
  final bool isLoadingNew;
  final VoidCallback onLoadNew;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Timer pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            borderRadius: AppBorders.borderRadiusFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.clock, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                formatElapsed(elapsedSeconds),
                style: AppTypography.textXl.bold.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: OutlinedButton.icon(
            onPressed: isLoadingNew ? null : onLoadNew,
            icon: isLoadingNew
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    LucideIcons.refreshCcw,
                    size: 18,
                    color: AppColors.primary,
                  ),
            label: Text(
              'Bài khác',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.smMd,
              ),
              textStyle: AppTypography.buttonMedium,
            ),
          ),
        ),
      ],
    );
  }
}

