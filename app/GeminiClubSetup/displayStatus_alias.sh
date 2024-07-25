#!/bin/bash

displayStatus_func()
{
    if ! [[ -e "$HOME/.mentee_not_submit.txt" ]]
    then
        touch "$HOME/.mentee_not_submit.txt"
        chmod 700 "$HOME/.mentee_not_submit.txt"
        echo "Rollno Name Domain Taskno-1" > "$HOME/.mentee_not_submit.txt"
    fi
    touch "$HOME/.mentee_new_submit.txt"
    declare -a mentee_domain_list
    mentee_list=$(awk 'BEGIN {FS=" "; OFS="_"} $0 !~/Rollno Name Domain/{print $2,$1}' "$HOME/mentee_domain.txt")
    mentee_domain_list=($(awk 'BEGIN {FS=" "} $0 !~/Rollno Name Domain/{print $3}' "$HOME/mentee_domain.txt"))

    mentee_number=0
    mentee_number_web=0
    mentee_number_app=0
    mentee_number_sysad=0

    declare -a task_submit_web task_submit_app task_submit_sysad

    declare -a task_web task_app task_sysad
    task_web=(0 0 0)
    task_app=(0 0 0)
    task_sysad=(0 0 0)

    for mentee in $mentee_list
    do
        mentee_domain=$(echo ${mentee_domain_list[$mentee_number]} | awk 'BEGIN{FS="->"; OFS=" "} {print $1,$2,$3}')
        if [[ -s "$HOME/mentees/$mentee/task_submitted.txt" ]]
        then
            for domain in $mentee_domain
            do
                if [[ $domain == "web" ]]
                then
                    task_submit_web=($(awk 'BEGIN{i=1;} $0 ~/^web:/{i=0} {if(i==0){print $2; }}$0 ~/^sysad:/{i=1} $0 ~/^app:/{i=1}' "$HOME/mentees/$mentee/task_submitted.txt" ))
                    for i in {0..2}
                    do
                        rollno=${mentee#*_}
                        name=${mentee%_*}
                        row="$rollno $name $domain $i"
                        if [[ ${task_submit_web[$i]} == 'y' ]]
                        then
                            task_web[$i]=$(( task_web[$i]+1 ))
                            if grep -q "$row" "$HOME/.mentee_not_submit.txt"
                            then
                                sed -i "/${row}/d" "$HOME/.mentee_not_submit.txt"
                                echo "$row" >> "$HOME/.mentee_new_submit.txt"
                            fi
                        elif [[ ${task_submit_web[$i]} == 'n' ]]
                        then 
                            if ! grep -qF "$row" "$HOME/.mentee_not_submit.txt"
                            then
                                echo "$row" >> "$HOME/.mentee_not_submit.txt"
                            fi
                        fi
                    done
                    mentee_number_web=$((mentee_number_web+1))
                fi

                if [[ $domain == "app" ]]
                then
                    task_submit_app=($(awk 'BEGIN{i=1;} $0 ~/^app:/{i=0} {if(i==0){print $2; }}$0 ~/^sysad:/{i=1} $0 ~/^web:/{i=1}' "$HOME/mentees/$mentee/task_submitted.txt" ))
                    for i in {0..2}
                    do
                        rollno=${mentee#*_}
                        name=${mentee%_*}
                        row="$rollno $name $domain $i"
                        if [[ ${task_submit_app[$i]} == 'y' ]]
                        then
                            task_app[$i]=$(( task_app[$i]+1 ))
                            if grep -q "$row" "$HOME/.mentee_not_submit.txt"
                            then
                                sed -i "/${row}/d" "$HOME/.mentee_not_submit.txt"
                                echo "$row" >> "$HOME/.mentee_new_submit.txt"
                            fi
                        elif [[ ${task_submit_app[$i]} == 'n' ]]
                        then 
                            if ! grep -qF "$row" "$HOME/.mentee_not_submit.txt"
                            then
                                echo "$row" >> "$HOME/.mentee_not_submit.txt"
                            fi
                        fi
                    done
                    mentee_number_app=$((mentee_number_app+1))
                fi

                if [[ $domain == "sysad" ]]
                then
                    task_submit_sysad=($(awk 'BEGIN{i=1;} $0 ~/^sysad:/{i=0} {if(i==0){print $2; }}$0 ~/^web:/{i=1} $0 ~/^app:/{i=1}' "$HOME/mentees/$mentee/task_submitted.txt" ))
                    for i in {0..2}
                    do
                        rollno=${mentee#*_}
                        name=${mentee%_*}
                        row="$rollno $name $domain $i"
                        if [[ ${task_submit_sysad[$i]} == 'y' ]]
                        then
                            task_sysad[$i]=$(( task_sysad[$i]+1 ))
                            if grep -q "$row" "$HOME/.mentee_not_submit.txt"
                            then
                                sed -i "/${row}/d" "$HOME/.mentee_not_submit.txt"
                                echo "$row" >> "$HOME/.mentee_new_submit.txt"
                            fi
                        elif [[ ${task_submit_sysad[$i]} == 'n' ]]
                        then 
                            if ! grep -qF "$row" "$HOME/.mentee_not_submit.txt"
                            then
                                echo "$row" >> "$HOME/.mentee_not_submit.txt"
                            fi
                        fi
                    done
                    mentee_number_sysad=$((mentee_number_web+1))
                fi
            done
        fi   
        mentee_number=$((mentee_number+1))
    done

    if [[ $1 == '' ]]
    then 
        for i in {0..2}
        do  
            total=$(( ${task_web[$i]}+ ${task_app[$i]}+${task_sysad[$i]} ))
            task_total=$(( $mentee_number_app + $mentee_number_sysad + $mentee_number_web ))
            cal=$(echo $total $task_total | awk '{result = $1 / $2; print 100*result}')
            taskno=$(( $i+1 ))
            # echo ${task_web[$i]} ${task_app[$i]} ${task_sysad[$i]} $mentee_number $taskno
            echo "The percentage of mentees who have submitted task $taskno is $cal %"
        done
        echo "The mentees who have newly submitted their tasks are : "
        echo "web"
        awk 'BEGIN {FS=" "; OFS=" "} $3 ~/web/{print $1,$2,"task",$4+1} ' "$HOME/.mentee_new_submit.txt"

        echo "app"
        awk 'BEGIN {FS=" "; OFS=" "} $3 ~/app/{print $1,$2,"task",$4+1} '  "$HOME/.mentee_new_submit.txt"

        echo "sysad"
        awk 'BEGIN {FS=" "; OFS=" "} $3 ~/sysad/{print $1,$2,"task",$4+1}' "$HOME/.mentee_new_submit.txt"

        rm -f "$HOME/.mentee_new_submit.txt"

    elif [[ $1 == 'web' ]]
    then
        for i in {0..2}
        do 
            cal=$( echo ${task_web[$i]} $mentee_number_web | awk '{result = $1 / $2; print 100*result}' )
            taskno=$(( $i+1 ))
            echo "The percentage of mentees who have submitted task $taskno is $cal"
        done
        echo "The mentees who have newly submitted their tasks are : "
        awk 'BEGIN {FS=" "; OFS=" "} $3 ~/web/{print $1,$2,"task",$4+1}' "$HOME/.mentee_new_submit.txt"

        rm -f "$HOME/.mentee_new_submit.txt"

    elif [[ $1 == 'app' ]]
    then
        for i in {0..2}
        do 
            cal=$( echo ${task_app[$i]} $mentee_number_app | awk '{result = $1 / $2; print 100*result}' )
            taskno=$(( $i+1 ))
            echo "The percentage of mentees who have submitted task $taskno is $cal"
        done
        echo "The mentees who have newly submitted their tasks are : "
        awk 'BEGIN {FS=" "; OFS=" "} $3 ~/app/{print $1,$2,"task",$4+1}' "$HOME/.mentee_new_submit.txt"

        rm -f "$HOME/.mentee_new_submit.txt"

    elif [[ $1 == 'sysad' ]]
    then
        for i in {0..2}
        do 
            cal=$( echo ${task_sysad[$i]} $mentee_number_sysad | awk '{result = $1 / $2; print 100*result}' )
            taskno=$(( $i+1 ))
            echo "The percentage of mentees who have submitted task $taskno is $cal"
        done
        echo "The mentees who have newly submitted their tasks are : "
        awk 'BEGIN {FS=" "; OFS=" "} $3 ~/sysad/{print $1,$2,"task",$4+1}' "$HOME/.mentee_new_submit.txt"

        rm -f "$HOME/.mentee_new_submit.txt"

    fi
}

displayStatusCheck_func ()
{
    declare -l domain_asked
    domain_asked=$1
    if [[ $domain_asked == '' ]] || [[ $domain_asked == 'web' ]] || [[ $domain_asked == 'app' ]] || [[ $domain_asked == 'sysad' ]]
    then
        displayStatus_func $domain_asked
    else
        echo "Provide a valid domain"
    fi
}

checkforcore_func ()
{
    if echo $(groups) | grep -q '\bcore_grp\b'
    then
        displayStatusCheck_func $1
    else
        echo "The current user is not core. Only core can use this alias" 
    fi
}
alias displayStatus="checkforcore_func"