#!/usr/bin/env bash
set -e

# リリーススクリプト
# このスクリプトはリリース作業を自動化します
#
# 機能:
# - セマンティックバージョン管理 (例: 0.1.0)
# - ビルド番号の管理 (例: 0.1.0-900)
# - ビルド番号のカスタムインクリメント (デフォルト: +100)
# - 変更履歴の自動更新
# - Gitタグの自動作成
# - リリースPRの自動作成
#
# 使用方法:
# ./scripts/release.sh
# または
# mise run release

# 色の設定
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# ヘルパー関数
info() {
  echo -e "${GREEN}INFO:${NC} $1"
}

warn() {
  echo -e "${YELLOW}WARN:${NC} $1"
}

error() {
  echo -e "${RED}ERROR:${NC} $1"
  exit 1
}

# 必要なコマンドの確認
check_commands() {
  local commands=("git" "gh")

  for cmd in "${commands[@]}"; do
    if ! command -v $cmd &> /dev/null; then
      error "$cmd コマンドが見つかりません。インストールしてください。"
    fi
  done
}

# 現在のブランチがmainかどうかを確認
check_branch() {
  local current_branch=$(git branch --show-current)
  if [ "$current_branch" != "main" ]; then
    warn "現在 $current_branch ブランチにいます。リリースは通常 main ブランチから行います。"
    read -p "続行しますか？ (y/N): " confirm
    if [[ $confirm != [yY] ]]; then
      error "リリースを中止しました。"
    fi
  fi
}

# 変更がステージングされていないことを確認
check_clean_worktree() {
  if ! git diff --quiet; then
    error "ワークツリーに未コミットの変更があります。変更をコミットまたはスタッシュしてから再試行してください。"
  fi

  if ! git diff --cached --quiet; then
    error "ステージングされた変更があります。変更をコミットまたはリセットしてから再試行してください。"
  fi
}

# バージョン番号を取得
get_version() {
  echo "現在のバージョン番号を取得中..."

  # プロジェクトに応じてバージョン取得方法を変更する
  # 例: package.json からの取得
  if [ -f "pubspec.yaml" ]; then
    current_version=$(grep -E '^version:' pubspec.yaml | sed 's/version: //')
    echo "現在のバージョン: $current_version"

    # 現在のバージョンからベースバージョンとビルド番号を抽出
    if [[ $current_version =~ ^([0-9]+\.[0-9]+\.[0-9]+)-([0-9]+)$ ]]; then
      current_base_version="${BASH_REMATCH[1]}"
      current_build_number="${BASH_REMATCH[2]}"
      echo "現在のベースバージョン: $current_base_version"
      echo "現在のビルド番号: $current_build_number"
    else
      current_base_version="$current_version"
      current_build_number="0"
      echo "ビルド番号が見つかりません。ビルド番号を0とします。"
    fi
  else
    current_version="0.0.0"
    current_base_version="0.0.0"
    current_build_number="0"
    warn "バージョン情報が見つかりませんでした。初期バージョンを $current_version とします。"
  fi

  # 新しいベースバージョンの入力を求める
  read -p "新しいベースバージョン番号を入力してください（例: 1.0.0）[${current_base_version}]: " new_base_version
  new_base_version=${new_base_version:-$current_base_version}

  # ビルド番号のインクリメント幅を設定（デフォルトは100）
  default_increment=100
  read -p "ビルド番号のインクリメント幅を入力してください [${default_increment}]: " increment_value
  increment_value=${increment_value:-$default_increment}

  # 新しいビルド番号の計算
  new_build_number=$((current_build_number + increment_value))
  read -p "新しいビルド番号を入力してください [${new_build_number}]: " input_build_number
  new_build_number=${input_build_number:-$new_build_number}

  # 完全なバージョン番号を作成
  new_version="${new_base_version}-${new_build_number}"

  if [ -z "$new_version" ]; then
    error "バージョン番号が指定されていません。"
  fi

  echo "リリースバージョン: $new_version"
}

# バージョン番号を更新
update_version() {
  echo "バージョン番号を更新中..."

  # プロジェクトに応じてバージョン更新方法を変更する
  if [ -f "pubspec.yaml" ]; then
    sed -i '' "s/^version: .*/version: $new_version/" pubspec.yaml
    info "pubspec.yaml のバージョンを $new_version に更新しました。"
  else
    warn "バージョン情報を更新するファイルが見つかりませんでした。"
  fi
}

# 変更履歴を更新
update_changelog() {
  if [ -f "changes.md" ]; then
    echo "変更履歴を更新中..."

    # 今日の日付
    today=$(date "+%Y-%m-%d")

    # テンプレートの作成
    changelog_entry="## $new_version ($today)\n\n"

    # エディタで変更履歴を編集
    echo -e "変更履歴に追加する内容を入力してください。完了したら保存して閉じてください。"
    sleep 2

    # 一時ファイルの作成
    temp_file=$(mktemp)
    echo -e "$changelog_entry" > "$temp_file"
    echo "- " >> "$temp_file"
    echo "" >> "$temp_file"

    # 既存の内容を一時ファイルに追加
    cat "changes.md" >> "$temp_file"

    # エディタで開く
    ${EDITOR:-vi} "$temp_file"

    # 一時ファイルの内容をchanges.mdに移動
    mv "$temp_file" "changes.md"

    info "変更履歴を更新しました。"
  else
    warn "changes.md ファイルが見つかりません。変更履歴の更新をスキップします。"
  fi
}

# コミットとタグの作成
commit_and_tag() {
  echo "変更をコミットして、タグを作成中..."

  git add .
  git commit -m "chore: バージョン $new_version へ更新"
  git tag -a "v$new_version" -m "リリース v$new_version"

  info "コミットとタグを作成しました。"
}

# リリースPRの作成（必要に応じて）
create_release_pr() {
  echo "リリースプロセスを完了中..."

  # リリースブランチが必要な場合
  if [ -d "pr-body" ] && [ -f "pr-body/release-pr-body.md" ]; then
    # リリースブランチの作成
    release_branch="release/v$new_version"
    git checkout -b "$release_branch"

    # リモートにプッシュ
    git push origin "$release_branch"

    # GitHub CLIでPRを作成
    if command -v gh &> /dev/null; then
      pr_title="リリース: v$new_version"
      gh pr create --base main --head "$release_branch" --title "$pr_title" --body-file "pr-body/release-pr-body.md"
      info "リリースPRを作成しました。"
    else
      warn "GitHub CLI (gh) がインストールされていません。手動でPRを作成してください。"
    fi
  fi
}

# メイン処理
main() {
  info "リリースプロセスを開始します..."

  check_commands
  check_branch
  check_clean_worktree
  get_version
  update_version
  update_changelog
  commit_and_tag
  create_release_pr

  info "リリースプロセスが完了しました！"
}

# スクリプトの実行
main
