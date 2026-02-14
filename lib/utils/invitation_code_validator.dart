/// 招待コードが有効な形式かどうかを検証する
/// バックエンドのALPHABET "ABCDEFGHJKMNPQRSTVWXY3456789" と一致する8桁
bool isValidInvitationCode(String code) {
  return RegExp(r'^[A-HJKMNP-TV-Y3-9]{8}$').hasMatch(code.toUpperCase());
}
