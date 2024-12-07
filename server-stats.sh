#!/bin/bash

get_timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

save_statistics() {
    echo "=== Server Statistics ===" > stats.log
    echo "TimeStamp: $(get_timestamp)" >> stats.log
    echo "=========================" >> stats.log
    echo "" >> stats.log
    
    # CPU Statistics
    read -a cpu_load_array <<< $(cat /proc/loadavg)
    cpu_count=$(nproc)

    load1=$(bc <<< "scale=2; (${cpu_load_array[0]}  / $cpu_count) * 100")
    load2=$(bc <<< "scale=2; (${cpu_load_array[1]}  / $cpu_count) * 100")
    load3=$(bc <<< "scale=2; (${cpu_load_array[2]}  / $cpu_count) * 100")

    # Save CPU usage
    echo "CPU Usage:" >> stats.log
    echo "----------------" >> stats.log
    echo "Last minute:     ${load1}%" >> stats.log
    echo "Lat 5 minutes:   ${load2}%" >> stats.log
    echo "Last 15 minutes: ${load3}%" >> stats.log
    echo "" >> stats.log

    # Save memory usage
    echo "Memory Usage:" >> stats.log
    echo "----------------" >> stats.log
    free | awk '
        NR==2 && $1=="Mem:" {
            total=$2/1024/1024    # KB to GB conversion
            available=$7/1024/1024
            used=total-available
            used_percent=(used/total)*100
            
            printf "Total Memory:          %.2f GB\n", total >> "stats.log"
            printf "Used Memory:           %.2f GB\n", used >> "stats.log"
            printf "Available Memory:      %.2f GB\n", available >> "stats.log"
            printf "Percentage Usage       %.2f%%\n", used_percent >> "stats.log"
        }'
    echo "" >> stats.log

    # Save disk usage
    echo "Disk Usage:" >> stats.log
    echo "----------------" >> stats.log    
    df | awk '
    	NR==5 && $1=="/dev/xvda1" {
	    total=$2/1024/1024
	    available=$4/1024/1024
	    used=total-available
	    used_percent=(used/total)*100

	    printf "Total Disk space:          %.2f GB\n", total >> "stats.log"
            printf "Used Disk space:           %.2f GB\n", used >> "stats.log"
            printf "Available Disk space:      %.2f GB\n", available >> "stats.log"
            printf "Percentage Usage           %.2f%%\n", used_percent >> "stats.log"	    
	}'
    echo"" >> stats.log

    # Save top 5 processes by cpu usage
    echo "Top 5 Processes by CPU Usage:" >> stats.log
    echo "----------------" >> stats.log
    ps aux | sort -nrk 3,3 | head -n 5 | awk '
        NR > 0 {
	    command = ""
	    for (i=11; i<=NF; i++) command = command " " $i
	    
            printf "PID: %-6s | CPU: %-4s%% | Process: %s\n", $2, $3, command >> "stats.log"
        }'
    echo "" >> stats.log

    # Save top 5 proceses by memory usage
    echo "Top 5 Processes by Mem Usage:" >> stats.log
    echo "----------------" >> stats.log
    ps aux | sort -nrk 4,4 | head -n 5 | awk '
        NR > 0 {
            command = ""
            for (i=11; i<=NF; i++) command = command " " $i

            printf "PID: %-6s | MEM: %-5s%% | Process: %s\n", $2, $3, command >> "stats.log"
        }'
    echo "" >> stats.log

    # Save logged users
    echo "Logged users:" >> stats.log
    echo "----------------" >> stats.log
    read -a logged_users <<< $(users)
    printf "%s\n" "${logged_users[@]}" >> stats.log
    echo "" >> stats.log

    # Save OS version
    echo "OS Version:" >> stats.log
    echo "----------------" >> stats.log
    os_version=$(cat /etc/os-release | grep PRETTY_NAME | head -n 1 | awk -F'"' '{printf$2}')
    echo "$os_version" >> stats.log
    echo "" >> stats.log

}


save_statistics

echo "Statistics are saved to stats.log file"
