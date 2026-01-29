/// Enum representing all possible states of an insurance claim.
/// 
/// The status workflow follows strict transition rules:
/// - Draft → Submitted
/// - Submitted → Approved OR Rejected
/// - Approved → Partially Settled
/// - Partially Settled → Settled
enum ClaimStatus {
  draft,
  submitted,
  approved,
  rejected,
  partiallysettled,
  settled;

  /// Returns a human-readable display name for the status
  String get displayName {
    switch (this) {
      case ClaimStatus.draft:
        return 'Draft';
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.partiallysettled:
        return 'Partially Settled';
      case ClaimStatus.settled:
        return 'Settled';
    }
  }

  /// Returns the list of valid next statuses from the current status.
  /// Implements the strict status transition workflow.
  List<ClaimStatus> get validTransitions {
    switch (this) {
      case ClaimStatus.draft:
        return [ClaimStatus.submitted];
      case ClaimStatus.submitted:
        return [ClaimStatus.approved, ClaimStatus.rejected];
      case ClaimStatus.approved:
        return [ClaimStatus.partiallysettled];
      case ClaimStatus.rejected:
        return []; // Terminal state - no further transitions
      case ClaimStatus.partiallysettled:
        return [ClaimStatus.settled];
      case ClaimStatus.settled:
        return []; // Terminal state - no further transitions
    }
  }

  /// Checks if transitioning to [newStatus] is valid from the current status
  bool canTransitionTo(ClaimStatus newStatus) {
    return validTransitions.contains(newStatus);
  }

  /// Returns true if this is a terminal state (no further transitions possible)
  bool get isTerminal => validTransitions.isEmpty;

  /// Returns true if the claim can be edited (only in draft status)
  bool get isEditable => this == ClaimStatus.draft;

  /// Returns a description of what this status means
  String get description {
    switch (this) {
      case ClaimStatus.draft:
        return 'Claim is being prepared and can be edited';
      case ClaimStatus.submitted:
        return 'Claim has been submitted for review';
      case ClaimStatus.approved:
        return 'Claim has been approved for settlement';
      case ClaimStatus.rejected:
        return 'Claim has been rejected';
      case ClaimStatus.partiallysettled:
        return 'Partial payment has been made';
      case ClaimStatus.settled:
        return 'Claim has been fully settled';
    }
  }
}
