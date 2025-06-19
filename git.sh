#!/bin/bash
# filepath: /tmp/undefine/git.sh

min_commits=1
max_commits=3

while getopts "m:M:" opt; do
  case $opt in
    m) min_commits=$OPTARG ;;
    M) max_commits=$OPTARG ;;
    *) echo "使用法: $0 [-m 最小コミット数] [-M 最大コミット数]"; exit 1 ;;
  esac
done

# 範囲の確認
if [ $min_commits -gt $max_commits ]; then
  echo "エラー: 最小コミット数が最大コミット数より大きくなっています"
  exit 1
fi

if [ ! -f commit_file.txt ]; then
  echo "Initial content" > commit_file.txt
fi

if [ ! -d .git ]; then
  git init
  git add .
  git commit -m "Initial commit"
fi

start_date="2024-10-21"
end_date="2025-06-19"

echo "開始日: $start_date （$(date -d "$start_date" "+%Y-%m-%d")）"
echo "終了日: $end_date （$(date -d "$end_date" "+%Y-%m-%d")）"
echo "コミット頻度: 1日あたり $min_commits〜$max_commits 回"

start_ts=$(date -d "$start_date" +%s)
end_ts=$(date -d "$end_date" +%s)

current_ts=$start_ts
day_count=1

while [ $current_ts -le $end_ts ]; do
  # 今日のコミット回数をランダムに決定
  commits_today=$(( RANDOM % (max_commits - min_commits + 1) + min_commits ))
  current_date=$(date -d "@$current_ts" "+%Y-%m-%d")
  
  echo "Day ${day_count} ($current_date): $commits_today commits"
  
  # その日のコミットを実行
  for ((commit_num=1; commit_num<=commits_today; commit_num++)); do
    # 時間をランダムに設定するが、複数コミットの場合は時間を分散させる
    # 9時〜22時の範囲で均等に分布させる
    hour_range=14
    hour_step=$(( hour_range / commits_today ))
    base_hour=$(( 9 + (commit_num - 1) * hour_step ))
    hour_random=$(( RANDOM % hour_step ))
    hour=$(( base_hour + hour_random ))
    
    minute=$(( RANDOM % 60 ))
    second=$(( RANDOM % 60 ))
    
    commit_date=$(date -d "@$current_ts" "+%Y-%m-%d ${hour}:${minute}:${second} +0900")
  
    echo "Update on day ${day_count} (commit $commit_num/$commits_today): $current_date" >> commit_file.txt
    export GIT_COMMITTER_DATE="$commit_date"
    git add commit_file.txt
    git commit -m "Update day ${day_count} (commit $commit_num/$commits_today)" --date="$commit_date"
    
    echo "  Committed for: $commit_date"
  done

  current_ts=$((current_ts + 86400))
  day_count=$((day_count + 1))
done

echo "完了しました。以下のコマンドでリモートリポジトリにプッシュしてください:"
echo "git push -u origin main"