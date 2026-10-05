#!/usr/bin/env bash

mapfile -t sessions < <(
    tmux list-sessions -F '#{session_name}' |
    grep -E '^[0-9]+$' |
    sort -n
)

for i in "${!sessions[@]}"; do
    tmux rename-session -t "${sessions[$i]}" "__tmp_$$_$i"
done

for i in "${!sessions[@]}"; do
    tmux rename-session -t "__tmp_$$_$i" "$i"
done
