class DocumentStatus {
  final bool submitted;
  final String status; // pending | approved | rejected | not_submitted
  final String? reviewNotes;
  final String? submissionDate;
  final bool hasCdl;
  final bool hasInsurance;
  final bool hasCabCard;
  final bool hasSelfie;

  const DocumentStatus({
    required this.submitted,
    required this.status,
    this.reviewNotes,
    this.submissionDate,
    this.hasCdl = false,
    this.hasInsurance = false,
    this.hasCabCard = false,
    this.hasSelfie = false,
  });

  factory DocumentStatus.notSubmitted() => const DocumentStatus(
        submitted: false,
        status: 'not_submitted',
      );

  factory DocumentStatus.fromJson(Map<String, dynamic> j) => DocumentStatus(
        submitted: j['submitted'] as bool? ?? false,
        status: j['status'] as String? ?? 'not_submitted',
        reviewNotes: j['review_notes'] as String?,
        submissionDate: j['submission_date'] as String?,
        hasCdl: (j['documents']?['cdl'] as bool?) ?? false,
        hasInsurance: (j['documents']?['insurance'] as bool?) ?? false,
        hasCabCard: (j['documents']?['cab_card'] as bool?) ?? false,
        hasSelfie: (j['documents']?['selfie'] as bool?) ?? false,
      );

  bool get isComplete => hasCdl && hasInsurance && hasCabCard && hasSelfie;
}
