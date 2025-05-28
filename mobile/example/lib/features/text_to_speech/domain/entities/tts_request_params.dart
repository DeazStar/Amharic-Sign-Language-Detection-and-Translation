import 'package:equatable/equatable.dart';

class TtsRequestParams extends Equatable {
  final String text;
  final String languageCode; // e.g., "am-ET"
  final String voiceName;    // e.g., "am-ET-MekdesNeural"
  // Add other params like rate, pitch if needed

  const TtsRequestParams({
    required this.text,
    required this.languageCode,
    required this.voiceName,
  });

  @override
  List<Object?> get props => [text, languageCode, voiceName];
}
