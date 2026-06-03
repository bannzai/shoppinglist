import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Firestore の [Timestamp] と Dart の [DateTime] を相互変換するコンバータ。
///
/// 必須フィールド用。nullable な場合は [NullableTimestampConverter] を使用する。
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp json) {
    return json.toDate();
  }

  @override
  Timestamp toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

/// Firestore の [Timestamp] と Dart の [DateTime] を相互変換する nullable 版コンバータ。
class NullableTimestampConverter
    implements JsonConverter<DateTime?, Timestamp?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Timestamp? json) {
    return json?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return Timestamp.fromDate(dateTime);
  }
}

/// クライアント側で作成日時を設定するコンバータ。
///
/// 読み込み時は [Timestamp] を [DateTime] に変換する。
/// 書き込み時は null の場合に `DateTime.now()` をデフォルト値として使用する。
class ClientCreatedTimestamp implements JsonConverter<DateTime?, Timestamp?> {
  const ClientCreatedTimestamp();

  @override
  DateTime? fromJson(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? dateTime) {
    if (dateTime == null) {
      return Timestamp.fromDate(DateTime.now());
    }
    return Timestamp.fromDate(dateTime);
  }
}

/// クライアント側の更新日時フィールド用コンバータ。
///
/// 読み込み時は [Timestamp] を [DateTime] に変換する。
/// 書き込み時は値をそのまま変換する。null の場合は null を返す。
/// 更新時に呼び出し元が `copyWith(updatedDateTime: DateTime.now())` で明示的に設定する想定。
class ClientUpdatedTimestamp implements JsonConverter<DateTime?, Timestamp?> {
  const ClientUpdatedTimestamp();

  @override
  DateTime? fromJson(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? date) {
    if (date == null) {
      return null;
    }
    return Timestamp.fromDate(date);
  }
}

/// サーバー側で作成日時を設定するコンバータ。
///
/// 書き込み時は null の場合に [FieldValue.serverTimestamp] を使用し、
/// Firestore サーバーのタイムスタンプで記録する。
class ServerCreatedTimestamp implements JsonConverter<DateTime?, dynamic> {
  const ServerCreatedTimestamp();

  @override
  DateTime? fromJson(dynamic timestamp) {
    return timestamp?.toDate();
  }

  @override
  dynamic toJson(DateTime? dateTime) {
    if (dateTime == null) {
      return FieldValue.serverTimestamp();
    }
    return dateTime;
  }
}

/// サーバー側で更新日時を設定するコンバータ。
///
/// 書き込み時は常に [FieldValue.serverTimestamp] を使用し、
/// 書き込みのたびにサーバータイムスタンプで上書きする。
class ServerUpdatedTimestamp implements JsonConverter<DateTime?, dynamic> {
  const ServerUpdatedTimestamp();

  @override
  DateTime? fromJson(dynamic timestamp) {
    return timestamp?.toDate();
  }

  @override
  dynamic toJson(DateTime? date) {
    return FieldValue.serverTimestamp();
  }
}
