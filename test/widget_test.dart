// This is a basic Flutter widget test for the Insurance Claim Management System.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';

import 'package:insurance_claim_app/main.dart';
import 'package:insurance_claim_app/providers/providers.dart';

void main() {
  testWidgets('Dashboard displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InsuranceClaimApp());

    // Allow the app to settle
    await tester.pumpAndSettle();

    // Verify that the dashboard title is displayed
    expect(find.text('Insurance Claims'), findsOneWidget);

    // Verify that the FAB for creating new claim exists
    expect(find.text('New Claim'), findsOneWidget);

    // Verify that statistics are displayed
    expect(find.text('Total Claims'), findsOneWidget);
    expect(find.text('Total Value'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Settled'), findsOneWidget);
  });

  testWidgets('Can navigate to create claim screen', (WidgetTester tester) async {
    await tester.pumpWidget(const InsuranceClaimApp());
    await tester.pumpAndSettle();

    // Tap the 'New Claim' FAB
    await tester.tap(find.text('New Claim'));
    await tester.pumpAndSettle();

    // Verify we're on the create claim screen
    expect(find.text('Create New Claim'), findsOneWidget);
    expect(find.text('Patient Details'), findsOneWidget);
  });

  test('ClaimsProvider creates and manages claims correctly', () async {
    final provider = ClaimsProvider();

    // Initially empty
    expect(provider.isEmpty, true);
    expect(provider.claimCount, 0);

    // Create a claim
    final claim = await provider.createClaim(
      patientName: 'John Doe',
      policyNumber: 'POL12345',
      claimDate: DateTime.now(),
    );

    expect(claim.patientName, 'John Doe');
    expect(claim.status.displayName, 'Draft');
  });
}
