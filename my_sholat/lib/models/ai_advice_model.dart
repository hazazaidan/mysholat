// lib/models/ai_advice_model.dart

enum AdviceType { reminder, consistency, tips, achievement }

class AiAdvice {
  final String id;
  final AdviceType type;
  final String title;
  final String description;
  final String? actionLabel;
  final String? targetPrayer;
  final DateTime createdAt;

  const AiAdvice({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.actionLabel,
    this.targetPrayer,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case AdviceType.reminder:    return 'AI Insight';
      case AdviceType.consistency: return 'Konsistensi';
      case AdviceType.tips:        return 'Tips Ibadah';
      case AdviceType.achievement: return 'Pencapaian';
    }
  }

  bool get hasAction => actionLabel != null;

  @override
  String toString() => 'AiAdvice(id: $id, type: $type, title: $title)';
}