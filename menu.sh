#! /bin/bash

addToGroup() {
    echo "enter username:"
    read user
    echo "enter group name:"
    read group
    sudo usermod -a -G $group $user
}

removeFromGroup() {
    echo "enter username:"
    read user
    echo "enter group name:"
    read group
    sudo usermod -r -G $group $user
}

printAudit() {
    echo "enter an output file path (if empty, stdout is used):"
    read out
    if [ -z "$out" ]
    then
        sudo ausearch -k watch-intranet
    else
        # the output file will be owned by root, but that should be ok
        sudo ausearch -k watch-intranet | sudo tee $out > /dev/null
    fi
}


while [ 1 = 1 ]
do
    echo "**** Menu ****"
    echo "1) Add a user to a group "
    echo "2) Remove a user from a group "
    echo "3) Perform backup "
    echo "4) Perform transfer "
    echo "5) Print audit logs"
    echo "6) Perform urgent update"
    echo "*) Exit"

    read userInput

    case $userInput in
        1) addToGroup ;;
        2) removeFromGroup ;;
        3) echo "enter a commit message:"
           read message
           sudo /home/admin/ca-2/scripts/lock.sh $message ;;
        4) /home/admin/ca-2/scripts/pull_live.sh ;;
        5) printAudit ;;
        6) echo "enter the file name:"
           read fileName
           echo "enter a commit message"
           read message
           here=$(pwd)
           cd /home/admin/ca-2/intranet.git
           git add $fileName
           git commit -m "$message"
           cd /home/admin/ca-2/live.git
           git pull origin main
           cd $here ;;
        *) exit 0
    esac
    echo ""

done



