#!/bin/bash

# check_ports.sh - Check port availability with project-aware detection
# Usage: ./check_ports.sh [port] [--kill <port>] [--kill-if-same <port>]

COMMON_PORTS=(3000 3001 5173 5174 8080 8000 4000 4200 8888)

get_process_cwd() {
    local pid=$1
    # macOS: use lsof to get cwd
    if [[ "$(uname)" == "Darwin" ]]; then
        lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | grep '^n' | sed 's/^n//'
    else
        # Linux: read from /proc
        readlink -f "/proc/$pid/cwd" 2>/dev/null
    fi
}

is_same_project() {
    local pid=$1
    local process_cwd=$(get_process_cwd "$pid")
    local current_dir=$(pwd -P)

    [[ -z "$process_cwd" ]] && return 1

    # Check if process cwd is same as or parent/child of current dir
    [[ "$process_cwd" == "$current_dir" ]] && return 0
    [[ "$current_dir" == "$process_cwd"/* ]] && return 0
    [[ "$process_cwd" == "$current_dir"/* ]] && return 0
    return 1
}

check_port() {
    local port=$1
    local pid=$(lsof -ti :$port 2>/dev/null | head -1)
    if [[ -n "$pid" ]]; then
        local cmd=$(ps -p $pid -o comm= 2>/dev/null)
        local full_cmd=$(ps -p $pid -o args= 2>/dev/null | head -c 60)
        local process_cwd=$(get_process_cwd "$pid")

        echo "Port $port: IN USE by PID $pid ($cmd)"
        echo "  Command: $full_cmd"

        if [[ -n "$process_cwd" ]]; then
            echo "  Project: $process_cwd"
            if is_same_project "$pid"; then
                echo "  Status: SAME PROJECT (safe to kill)"
            else
                echo "  Status: DIFFERENT PROJECT (ask before killing)"
            fi
        fi
        return 1
    else
        echo "Port $port: AVAILABLE"
        return 0
    fi
}

kill_port() {
    local port=$1
    local same_only=${2:-false}
    local pids=$(lsof -ti :$port 2>/dev/null)

    if [[ -z "$pids" ]]; then
        echo "No processes found on port $port"
        return 0
    fi

    local killed=0
    local skipped=0

    for pid in $pids; do
        if [[ "$same_only" == "true" ]]; then
            if is_same_project "$pid"; then
                echo "Killing PID $pid (same project)"
                kill -9 "$pid" 2>/dev/null
                ((killed++))
            else
                local process_cwd=$(get_process_cwd "$pid")
                echo "Skipping PID $pid (different project: $process_cwd)"
                ((skipped++))
            fi
        else
            echo "Killing PID $pid"
            kill -9 "$pid" 2>/dev/null
            ((killed++))
        fi
    done

    sleep 0.5

    if [[ $killed -gt 0 ]]; then
        if lsof -ti :$port >/dev/null 2>&1; then
            echo "Warning: Some processes may still be running on port $port"
            return 1
        else
            echo "Successfully killed $killed process(es) on port $port"
        fi
    fi

    if [[ $skipped -gt 0 ]]; then
        echo "Skipped $skipped process(es) from different projects"
        return 2
    fi

    return 0
}

find_available_port() {
    local start_port=${1:-3000}
    for port in $(seq $start_port $((start_port + 100))); do
        if ! lsof -ti :$port >/dev/null 2>&1; then
            echo $port
            return 0
        fi
    done
    echo ""
    return 1
}

scan_common_ports() {
    echo "=== Scanning Common Dev Ports ==="
    echo "Current project: $(pwd -P)"
    echo ""
    local available_ports=()
    local same_project_ports=()
    local other_project_ports=()

    for port in "${COMMON_PORTS[@]}"; do
        local pid=$(lsof -ti :$port 2>/dev/null | head -1)
        if [[ -n "$pid" ]]; then
            if is_same_project "$pid"; then
                same_project_ports+=($port)
            else
                other_project_ports+=($port)
            fi
            check_port $port
            echo ""
        else
            available_ports+=($port)
        fi
    done

    echo "=== Summary ==="
    [[ ${#available_ports[@]} -gt 0 ]] && echo "Available: ${available_ports[*]}"
    [[ ${#same_project_ports[@]} -gt 0 ]] && echo "Same project (safe to kill): ${same_project_ports[*]}"
    [[ ${#other_project_ports[@]} -gt 0 ]] && echo "Other projects (ask first): ${other_project_ports[*]}"

    if [[ ${#available_ports[@]} -gt 0 ]]; then
        echo ""
        echo "Suggested port: ${available_ports[0]}"
    elif [[ ${#same_project_ports[@]} -gt 0 ]]; then
        echo ""
        echo "Suggested: kill same-project server on port ${same_project_ports[0]}"
    fi
}

# Main
case "$1" in
    --scan)
        scan_common_ports
        ;;
    --find)
        port=$(find_available_port ${2:-3000})
        if [[ -n "$port" ]]; then
            echo $port
        else
            echo "No available ports found" >&2
            exit 1
        fi
        ;;
    --kill)
        if [[ -n "$2" ]]; then
            kill_port "$2" false
        else
            echo "Usage: $0 --kill <port>"
            exit 1
        fi
        ;;
    --kill-if-same)
        if [[ -n "$2" ]]; then
            kill_port "$2" true
        else
            echo "Usage: $0 --kill-if-same <port>"
            exit 1
        fi
        ;;
    [0-9]*)
        check_port $1
        ;;
    *)
        scan_common_ports
        ;;
esac
