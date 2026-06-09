/** AI機能の月次利用回数データの型定義。 */
export interface UserAIUsageData {
  /** ドキュメントID（yearMonth形式、例: "2026-04"） */
  id: string;
  /** このドキュメントの所有ユーザーID */
  userID: string;
  /** AI画像認識の利用回数 */
  imageRecognitionCount: number;
  /** URLからの買い物リスト生成の利用回数 */
  urlRecognitionCount?: number;
  /** AIカテゴリ分けの利用回数 */
  categorizeCount?: number;
  /** サーバー側の作成日時 */
  serverCreatedDateTime?: FirebaseFirestore.Timestamp;
  /** サーバー側の更新日時 */
  serverUpdatedDateTime?: FirebaseFirestore.Timestamp;
}
