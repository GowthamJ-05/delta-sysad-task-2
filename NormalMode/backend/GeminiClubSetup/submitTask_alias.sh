#!/bin/bash

mentor_func ()
{
    if echo $(groups) | grep -q '\bweb_mentors_grp\b'
    then
        domain=web
    elif echo $(groups) | grep -q '\bapp_mentors_grp\b'
    then
        domain=app
    elif echo $(groups) | grep -q '\bsysad_mentors_grp\b'
    then
        domain=sysad
    fi
    
    mentee_list=$(awk 'BEGIN{ OFS="_";ORS=" "} $0 !~/Rollno Name/{ print $2,$1 ;}' "$HOME/Alottedmentees.txt") 
    for mentee in $mentee_list
    do
        dir_location="$HOME/../../../mentees/$mentee/$domain"
        declare -a task_completed_arr
        for i in {1..3}
        do
            task_location="$dir_location/Task$i"
            if [[ -d "$task_location" ]]
            then
                if [[ ! -h "$HOME/submitted_tasks/task$i/$mentee" ]]
                then
                    ln -s $HOME/../../../mentees/$mentee/$domain/Task$i $HOME/submitted_tasks/task$i/$mentee
                fi
                if [[ -z "$task_location/*" ]]
                then
                    task_completed_arr[$i]='n'
                else
                    task_completed_arr[$i]='y'
                fi
            else
                task_completed_arr[$i]='n'
            fi
        done
        modified_data=$(awk -v col="$column" -v val1="${task_completed_arr[1]}" -v val2="${task_completed_arr[2]}" -v val3="${task_completed_arr[3]}" 'BEGIN {task[2] = val1;task[3] = val2;task[4] = val3;FS = ",";OFS = ",";ORS="\n"}$0 !~ /^Task_Domain/ {$col = task[NR];}{print $1,$2,$3,$4;}' "$dir_location/../task_completed.txt")
        echo -e "$modified_data" > $dir_location/../task_completed.txt
    done
}

mentee_func ()
{
    mentee_preference=$(awk 'BEGIN{FS="->"} {if (NR == 2) {for (i=1;i<=NF;i++) print $i}}' "/home/core/mentees/$(whoami)/domain_pref.txt")
    condition=1
    if echo $1 | grep -q "${mentee_preference}"
    then
        echo "$1:" > /home/core/mentees/$(whoami)/task_submitted.txt
        for i in {1..3}
        do
            read -p "Have you submitted the task$i (Y/n) " reply
            echo -e "\tTask$i: $reply" >> /home/core/mentees/$(whoami)/task_submitted.txt
            if  [[ $reply == 'y' || $reply == 'Y' ]] && ![[ -d "/home/core/mentees/$(whoami)/$1/Task$i" ]]
            then
                mkdir /home/core/mentees/$(whoami)/$1/Task$i 
            fi
        done
        echo "Task folders have been created"
    else
        echo "The domain $1 isn't in your domain preference"
    fi
}

check_mentee_func ()
{
    if [[ $# -eq 0 ]]
    then
        echo "USAGE: submitTask domain[web|app|sysad]..."
        return
    fi
    for i in $1 $2 $3
    do 
        match=1
        declare -l tolower
        tolower=$i
        for j in web app sysad
        do
            if [[ $tolower == $j ]]
            then
                match=0
                break
            fi
        done

        if [[ $match -eq 0 ]]
        then
            mentee_func $j
        else 
            echo "Invalid parameters given. Provide valid Parameters only"
            return
        fi
    done
    return
}

submitTask_func ()
{
    if echo $(groups) | grep -q '\bmentees_grp\b'
    then
        check_mentee_func $1 $2 $3
    elif echo $(groups) | grep -q '\bmentors_grp\b'
    then 
        mentor_func
    else
        echo "The current user is not a mentee or a mentor. Need to be a mentee or a mentor in order to use this alias " 
    fi
}


alias submitTask="submitTask_func"
