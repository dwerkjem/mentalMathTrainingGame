#!/usr/bin/env bash

dependencies=(
    "docker"
    "docker compose"
    "python3"
    "npm"
)

all_ok=true

for cmd in "${dependencies[@]}"; do
    read -r -a parts <<< "$cmd"

    if command -v "${parts[0]}" >/dev/null 2>&1; then
        if [ "${#parts[@]}" -gt 1 ]; then
            if "${parts[@]}" version >/dev/null 2>&1; then
                echo "$cmd is installed"
            else
                echo "$cmd is not available. Please install or enable it."
                all_ok=false
            fi
        else
            echo "$cmd is installed"
        fi
    else
        echo "${parts[0]} is not installed. Please install it."
        all_ok=false
    fi
done

if ! $all_ok; then
    echo
    echo "Some dependencies are missing. Please install them and rerun the script."
    exit 1
fi

echo
echo "All dependencies are installed and ready!"