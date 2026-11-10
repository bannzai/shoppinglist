---
scope: cross-repository
recorded: 2026-11-10
---
# mobile-mcp で Flutter の 1 行の TextField のキーボードを閉じる時は、done の座標ではなく ENTER ボタンを使う

ローカルの simulator で実測した (AI レビューのシートの TextField の検証)。`mobile_list_elements_on_screen` が返す "done" ボタンの座標を `mobile_click_on_screen_at_coordinates` でタップすると、done ではなく削除キーとして働き、文字が 1 つずつ消えた。

**なぜ:** キーボードのアクセシビリティ上の座標が、実際に描かれているキーの位置と一致しないことがあるためと見ている (実測からの推測で、出典は無い)。

**どう使う:**

- 1 行の TextField (`textInputAction: TextInputAction.done`) は `mobile_press_button(button: "ENTER")` で確定する。`onSubmitted` が呼ばれ、キーボードも閉じる
- モーダルシートの中の複数行の TextField は、ENTER が改行になり、外側のタップでも閉じない (Maestro の `hideKeyboard` も日本語キーボードで失敗した)。キーボードを閉じずに、シートをスワイプでスクロールして保存ボタンまで移動する (アイテムのメモのシートは PR #393 でスクロールできるようにしてある)
