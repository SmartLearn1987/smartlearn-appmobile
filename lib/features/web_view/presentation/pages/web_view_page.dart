import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';
import 'package:smart_learn/features/web_view/presentation/helpers/hvui_web_session.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    required this.url,
    required this.title,
    this.hvuiSessionPayload,
  });

  final String url;
  final String title;

  /// Đồng bộ session web SPA (hvui-session-v1 như Smart Learn Web)
  /// để trang ví dụ /premium coi như đã đăng nhập.
  final Map<String, dynamic>? hvuiSessionPayload;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _controller;
  double _progress = 0;
  bool _hasError = false;
  String? _errorMessage;

  UnmodifiableListView<UserScript>? get _initialUserScripts {
    final p = widget.hvuiSessionPayload;
    if (p == null) return null;
    return UnmodifiableListView<UserScript>([
      UserScript(
        source: buildHvuiSessionInjectUserScript(p),
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      ),
    ]);
  }

  Future<void> _dumpSessionStorageToConsole(
    InAppWebViewController controller,
  ) async {
    if (!kDebugMode) return;
    try {
      // Parse và mở rộng mọi chuỗi JSON trong sessionStorage ngay trong WebView — tránh Dart nhận
      // kiểu lạ và in "[object Object]"; sau đó Dart chỉ cần in chuỗi hoặc pretty Map.
      final result = await controller.evaluateJavascript(
        source: '''
(function(){
  try {
    function parseIfJsonString(val) {
      if (typeof val !== 'string') return val;
      var t = val.trim();
      if (!t.length) return val;
      if (t.charCodeAt(0) !== 0x7B && t.charCodeAt(0) !== 0x5B) return val;
      try { return JSON.parse(val); } catch (e) { return val; }
    }
    function deepExpand(x) {
      if (typeof x !== 'object' || x === null)
        return parseIfJsonString(x);
      if (Array.isArray(x)) return x.map(deepExpand);
      var o = {}, k;
      for (k in x) {
        if (Object.prototype.hasOwnProperty.call(x, k))
          o[k] = deepExpand(x[k]);
      }
      return o;
    }
    var out = {}, i, k, v;
    for (i = 0; i < sessionStorage.length; i++) {
      k = sessionStorage.key(i);
      if (k === null) continue;
      v = sessionStorage.getItem(k);
      out[k] = deepExpand(parseIfJsonString(v));
    }
    return JSON.stringify(out, null, 2);
  } catch (err) {
    return String(err);
  }
})()
''',
      );
      debugPrint('[WebView sessionStorage] url=${widget.url}');
      final text = _formatSessionEvaluateResult(result);
      for (final line in text.split('\n')) {
        debugPrint('[WebView sessionStorage] $line');
      }
    } catch (e, st) {
      debugPrint('[WebView sessionStorage] evaluate error: $e');
      debugPrint('$st');
    }
  }

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
              initialUserScripts: _initialUserScripts,
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
              onLoadStop: (controller, _) async {
                setState(() => _progress = 1);
                await _dumpSessionStorageToConsole(controller);
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
                        _errorMessage ??
                            'Vui lòng kiểm tra kết nối mạng và thử lại.',
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

/// Chuỗi dài và [debugPrint]: có thể tách nhiều dòng trong [_dumpSessionStorageToConsole].

/// Kết quả [evaluateJavascript]: String JSON, Map/List đã parse — ép về JSON có thụt dòng;
/// tiếp tục mọi **chuỗi JSON** con (vd. đã stringify lồng).
String _formatSessionEvaluateResult(dynamic raw) {
  if (raw == null) {
    return 'null';
  }
  dynamic root;
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        root = jsonDecode(raw);
      } catch (_) {
        return raw;
      }
    } else {
      return raw;
    }
  } else {
    root = raw;
  }
  final expanded = _recursiveExpandDecodedJsonStrings(root);
  try {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(expanded);
  } catch (_) {
    return expanded.toString();
  }
}

dynamic _recursiveExpandDecodedJsonStrings(dynamic node) {
  if (node is String) {
    final t = node.trim();
    if (t.length < 2) {
      return node;
    }
    if (t.startsWith('{') || t.startsWith('[')) {
      try {
        final inner = jsonDecode(node);
        return _recursiveExpandDecodedJsonStrings(inner);
      } catch (_) {
        return node;
      }
    }
    return node;
  }
  if (node is Map) {
    return <String, dynamic>{
      for (final entry in node.entries)
        '${entry.key}': _recursiveExpandDecodedJsonStrings(entry.value),
    };
  }
  if (node is List) {
    return node.map(_recursiveExpandDecodedJsonStrings).toList();
  }
  return node;
}
