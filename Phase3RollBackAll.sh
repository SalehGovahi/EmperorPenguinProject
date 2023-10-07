#! /bin/bash

# Author: Mohammad Saleh Govahi
# Created: October 2 2023
# Last Modified: October 2 2023
# Description: A script for running phase 2 functions with http protocol
# Usage: bash Phase3RollBackAll.sh OR ./Phase3RollBackAll.sh

function _execute_command() {
    local command="$@"
    local log_file="$(pwd)/error.log"

    output=$(eval "$command" 2>&1)

    exit_status=$?
    if [[ $exit_status -ne 0 ]]; then
        echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] Command: $command" >> "$log_file" 2>/dev/null
        echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] Error: $output" >> "$log_file" 2>/dev/null
        return ${exit_status}
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Command: $command" >> "$log_file" 2>/dev/null
        echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Output: $output" >> "$log_file" 2>/dev/null
        return ${exit_status}
    fi
}

function _rollbackAllConfigurations() {

    clear
    _makeLogTitle "Rollback All Configurations ..."

    _execute_command 'sudo rm -r /opt/project'

    _execute_command 'sudo apt-get -y purge libvips-dev'

    _execute_command 'sudo apt-get -y purge golang'
        
    _execute_command 'sudo apt-get -y autoremove'

    _execute_command 'sudo rm /usr/local/bin/imgproxy'

    _execute_command 'sudo rm /etc/systemd/system/imgproxy.service'
        
    _execute_command 'sudo systemctl stop imgproxy.service'
        
    _execute_command 'sudo systemctl daemon-reload'

    _execute_command 'sudo systemctl restart nftables'
        
    _execute_command 'sudo nft delete rule inet filter input handle 4'
        
    _execute_command 'sudo nft list ruleset > /etc/nftables.conf'
        
    _execute_command 'sudo nft -f /etc/nftables.conf'

    exit 1

}

if [[ $EUID -eq 0 ]]; then
    _rollbackAllConfigurations
    exit 1
else
    echo "This script must be run as root."
    exit 1
fi
