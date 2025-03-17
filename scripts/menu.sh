#! /bin/bash

addOrRemove()
{
    read -prompt "enter username: " user
    read -prompt "enter group: " group
    sudo usermod -$1 -G $group $user
}


# adds a user to a group.
addToGroup() {
    addOrRemove a
}

# removes a user from a group.
removeFromGroup() {
    addOrRemove r
}

# printAudit prints the audit report from auditd to stdout or a specified file.
printAudit() {
    read -prompt "enter an output file path (if empty, stdout is used): " out

    if [ -z "$out" ]
    then
        sudo ausearch -k watch-intranet
    else
        # the output file will be owned by root, but that should be ok
        sudo ausearch -k watch-intranet | sudo tee $out > /dev/null
    fi
}

backup() {
    read -prompt "enter a commit message: " message

    sudo /home/admin/ca-2/scripts/lock.sh
    if [ $? -ne 0 ]
    then
        echo "ERROR: failed to lock /var/www/html/intranet; backup not completed" >&2
        return 1
    fi
    /home/admin/ca-2/scripts/backup.sh "$message" $1
    if [ $? -ne 0 ]
    then
        echo "ERROR: backup of /var/www/html/intranet failed" >&2
        sudo /home/admin/ca-2/scripts/unlock.sh
        return 1
    fi

    sudo /home/admin/ca-2/scripts/unlock.sh
    if [ $? -ne 0 ]
    then
        echo "ERROR: failed to unlock /var/www/html/intranet" >&2
        return 1
    fi
}

transfer() {
    /home/admin/ca-2/scripts/pull_live.sh
}

# urgentUpdate stages changes to a file to the intranet git repo, commits those changes,
# and pulls the updates to the live git repo.
urgentUpdate() {
    read -prompt "enter the file name: " fileName
    
    backup $fileName
    if [ $? -ne 0 ]
    then
        echo "ERROR: unable to stage urgent update" >&2
        exit 1
    fi
    
    transfer
}


while [ 1 = 1 ]
do
    echo "**** Menu ****"
    echo "1) Add a user to a group."
    echo "2) Remove a user from a group."
    echo "3) Perform a backup."
    echo "4) Perform a transfer."
    echo "5) Print audit logs."
    echo "6) Perform an urgent update."
    echo "*) Exit"
    echo "**********"
    read userInput

    case $userInput in
        1) addToGroup ;;
        2) removeFromGroup ;;
        3) backup
           if [ $? -ne 0 ]
           then
                echo "ERROR: backup failed" >&2
           fi ;;
        4) transfer
           if [ $? -ne 0 ]
           then
                echo "ERROR: transfer failed" >&2
           fi ;;
        5) printAudit ;;
        6) urgentUpdate
           if [ $? -ne 0 ]
           then
                echo "ERROR: unable to complete urgent update" >&2
           fi ;;
        *) exit 0
    esac
    echo ""

done



