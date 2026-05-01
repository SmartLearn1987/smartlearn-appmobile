import 'package:equatable/equatable.dart';

class ContentBlock extends Equatable {
  final String type;
  final String content;

  // Optional styling — null means use default
  final double? fontSize;
  final String? fontFamily; // 'default' | 'serif' | 'mono' | 'sans'
  final String? color;      // hex string e.g. '#222D3F'
  final bool? bold;
  final bool? italic;

  const ContentBlock({
    required this.type,
    required this.content,
    this.fontSize,
    this.fontFamily,
    this.color,
    this.bold,
    this.italic,
  });

  @override
  List<Object?> get props => [type, content, fontSize, fontFamily, color, bold, italic];
}
