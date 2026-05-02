import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    required this.url,
    required this.title,
  });

  final String url;
  final String title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _controller;
  double _progress = 0;
  bool _hasError = false;
  String? _errorMessage;

  Future<bool> _onWillPop() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          router.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            color: AppColors.foreground,
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
          ),
          title: Text(
            widget.title,
            style: AppTypography.h4.copyWith(color: AppColors.foreground),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.refreshCw),
              color: AppColors.foreground,
              onPressed: () => _controller?.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: false,
                mediaPlaybackRequiresUserGesture: false,
                transparentBackground: true,
                supportZoom: true,
              ),
              onWebViewCreated: (controller) => _controller = controller,
              onProgressChanged: (_, progress) {
                setState(() => _progress = progress / 100.0);
              },
              onLoadStart: (_, _) {
                setState(() {
                  _hasError = false;
                  _errorMessage = null;
                });
              },
              onLoadStop: (_, _) {
                setState(() => _progress = 1);
              },
              onReceivedError: (_, _, error) {
                setState(() {
                  _hasError = true;
                  _errorMessage = error.description;
                  _progress = 1;
                });
              },
            ),
            if (_progress < 1)
              LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                minHeight: 3,
                backgroundColor: AppColors.muted,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            if (_hasError)
              Positioned.fill(
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.wifiOff,
                        size: 48,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Không tải được trang',
                        style: AppTypography.h4.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _errorMessage ?? 'Vui lòng kiểm tra kết nối mạng và thử lại.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _errorMessage = null;
                            _progress = 0;
                          });
                          _controller?.reload();
                        },
                        icon: const Icon(LucideIcons.refreshCw, size: 16),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryForeground,
                          shape: AppBorders.shapeSm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
