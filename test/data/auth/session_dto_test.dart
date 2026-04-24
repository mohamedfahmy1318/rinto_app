import 'package:flutter_test/flutter_test.dart';
import 'package:rento_go/data/auth/dtos/session_dto.dart';
import 'package:rento_go/domain/auth/entities/user_type.dart';

void main() {
  group('SessionDto.fromJson', () {
    test('parses token and user fields from a standard response', () {
      final dto = SessionDto.fromJson(<String, Object?>{
        'token': 'abc123',
        'user': <String, Object?>{
          'id': 42,
          'name': 'Test User',
          'email': 'u@example.test',
          'phone': '+972501234567',
          'user_type': 'owner',
          'preferred_language': 'he',
        },
      });

      final session = dto.toDomain();

      expect(session.token, 'abc123');
      expect(session.userId, 42);
      expect(session.name, 'Test User');
      expect(session.userType, UserType.owner);
      expect(session.preferredLanguage, 'he');
    });

    test('falls back to renter when user_type is unrecognized', () {
      final dto = SessionDto.fromJson(<String, Object?>{
        'token': 't',
        'user': <String, Object?>{'id': 1, 'user_type': 'martian'},
      });

      expect(dto.toDomain().userType, UserType.renter);
    });

    test('preserves rawUserJson verbatim (legacy bridge depends on it)', () {
      final raw = <String, Object?>{
        'id': 1,
        'custom_field': 'keep me',
        'user_type': 'renter',
      };

      final session = SessionDto.fromJson(<String, Object?>{
        'token': 't',
        'user': raw,
      }).toDomain();

      expect(session.rawUserJson['custom_field'], 'keep me');
    });

    test('sets requiresApproval / requiresVerification from top-level flags',
        () {
      final dto = SessionDto.fromJson(<String, Object?>{
        'token': '',
        'user': <String, Object?>{},
        'requires_approval': true,
        'requires_verification': false,
      });

      final session = dto.toDomain();

      expect(session.requiresApproval, isTrue);
      expect(session.requiresVerification, isFalse);
    });

    test('accepts string IDs (legacy backend quirk)', () {
      final session = SessionDto.fromJson(<String, Object?>{
        'token': 't',
        'user': <String, Object?>{'id': '77', 'user_type': 'renter'},
      }).toDomain();

      expect(session.userId, 77);
    });
  });
}
