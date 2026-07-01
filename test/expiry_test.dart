import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/ui/labels.dart';

void main() {
  final now = DateTime(2026, 6, 25);

  test('expiry within 30 days is flagged "soon"', () {
    expect(expiryState(DateTime(2026, 7, 10), now), ExpiryState.soon); // 15 d
    expect(expiryState(DateTime(2026, 7, 25), now), ExpiryState.soon); // 30 d
    expect(expiryState(now, now), ExpiryState.soon); // today (0 d)
  });

  test('expiry before today is "expired"', () {
    expect(expiryState(DateTime(2026, 6, 24), now), ExpiryState.expired);
  });

  test('expiry beyond 30 days is "ok"', () {
    expect(expiryState(DateTime(2026, 7, 26), now), ExpiryState.ok); // 31 d
    expect(expiryState(DateTime(2026, 8, 1), now), ExpiryState.ok);
  });

  test('no expiry date is "none"', () {
    expect(expiryState(null, now), ExpiryState.none);
  });

  test('daysUntil counts whole local days', () {
    expect(daysUntil(DateTime(2026, 6, 30), now), 5);
    expect(daysUntil(DateTime(2026, 6, 20), now), -5);
    expect(daysUntil(null, now), isNull);
  });
}
