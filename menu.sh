#! /bin/bash

addToGroup() {
    echo "enter username: "
    read user
    echo "enter group name: "
    read group
    sudo usermod -a -G $group $user
}

removeFromGroup() {
    echo "enter username: "
    read user
    echo "enter group name: "
    read group
    sudo usermod -r -G $group $user
}

printAudit() {
    echo "enter an output file path (if empty, stdout is used):"
    read out
    if [ -z "$out" ]
    then
        out=/dev/stdout
    fi
    sudo ausearch -k watch-intranet > $out
}


while [ 1 = 1 ]
do
    echo "**** Menu ****"
    echo "1) Add user to a group "
    echo "2) Remove user from a group "
    echo "3) Perform backup "
    echo "4) Perform transfer "
    echo "5) Print audit logs"
    echo "*) Exit"

    read userInput

    case $userInput in
        1) addToGroup ;;
        2) removeFromGroup ;;
        3) echo "TODO" ;;
        4) ./update.sh ;;
        5) printAudit ;;
        *) exit 0
    esac
    echo ""

done



