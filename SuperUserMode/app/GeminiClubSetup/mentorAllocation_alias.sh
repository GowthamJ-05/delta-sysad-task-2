#!/bin/bash
task_completed_setup ()
{   
    menteelist=$(awk 'BEGIN{FS=" ";OFS="_"} $0 !~/Rollno Name Domain/{print $2,$1 ;}' $1)
    domainlist=($(awk 'BEGIN{FS=" "} $0 !~/Rollno Name Domain/{print $3 ;}' $1))
    j=0
    for mentee in $menteelist
    do 
        declare -a mentee_domainlist
        mentee_domainlist=$( echo "${domainlist[$j]}" | awk 'BEGIN{FS="->";ORS=","} {for(i=1;i<=NF;i++) print $i ;}' )
        echo -e "Tasks_domain,${mentee_domainlist%,}" > $HOME/mentees/$mentee/task_completed.txt
        echo -e "Task1\nTask2\nTask3" >> $HOME/mentees/$mentee/task_completed.txt
        j=$(( j+1 ))
    done
}

web_Mentor_Allocation_func ()
{

    declare -a Mentor_array_web
    declare -a Mentee_capacity_array_web
    
    webdevlist=$(curl -s https://inductions.delta.nitt.edu/sysad-task1-mentorDetails.txt | cat | awk 'BEGIN{FS=" "; OFS=","} $0 !~/^Name/{if ($2 ~ /web/) print $3,$1 ;}' \
    | sort -k1,1nr)
    j=0
    for i in $webdevlist
    do
        Mentor_array_web[$j]=${i#*,}
        Mentee_capacity_array_web[$j]=${i%,*}
        j=$((j+1))
    done

    menteelist_web=$(awk 'BEGIN{FS=" ";OFS="_"} $0 !~/Rollno Name Domain/{if ($3 ~/.*web.*/) print $2,$1 ;}' $1)
    j=0
    n=${#Mentor_array_web[@]}
    for mentee in $menteelist_web
    do 
        if [[ ${Mentee_capacity_array_web[$j]} -ne 0 ]]
        then
            rollno=${mentee#*_}
            name=${mentee%_*}
            echo "$rollno $name" >> $HOME/mentors/Webdev/${Mentor_array_web[$j]}/Alottedmentees.txt
            setfacl -m u:${Mentor_array_web[$j]}:r-x $HOME/mentees/$mentee
            setfacl -m u:${Mentor_array_web[$j]}:rw- $HOME/mentees/$mentee/task_completed.txt
            Mentee_capacity_array_web[$j]=$((Mentee_capacity_array_web[$j]-1))
            j=$(( (j+1) % n ))
        else
            j=$(( (j+1) % n ))
        fi
    done
}

app_Mentor_Allocation_func ()
{

    declare -a Mentor_array_app
    declare -a Mentee_capacity_array_app
    
    appdevlist=$(curl -s https://inductions.delta.nitt.edu/sysad-task1-mentorDetails.txt | cat | awk 'BEGIN{FS=" "; OFS=","} $0 !~/^Name/{if ($2 ~ /app/) print $3,$1 ;}' \
    | sort -k1,1nr)
    j=0
    for i in $appdevlist
    do
        Mentor_array_app[$j]=${i#*,}
        Mentee_capacity_array_app[$j]=${i%,*}
        j=$((j+1))
    done

    menteelist_app=$(awk 'BEGIN{FS=" ";OFS="_"} $0 !~/Rollno Name Domain/{if ($3 ~/.*app.*/) print $2,$1 ;}' $1)
    j=0
    n=${#Mentor_array_app[@]}
    for mentee in $menteelist_app
    do 
        if [[ ${Mentee_capacity_array_app[$j]} -ne 0 ]]
        then
            rollno=${mentee#*_}
            name=${mentee%_*}
            echo "$rollno $name" >> $HOME/mentors/Appdev/${Mentor_array_app[$j]}/Alottedmentees.txt
            setfacl -m u:${Mentor_array_app[$j]}:r-x $HOME/mentees/$mentee
            setfacl -m u:${Mentor_array_app[$j]}:rw- $HOME/mentees/$mentee/task_completed.txt
            Mentee_capacity_array_app[$j]=$((Mentee_capacity_array_app[$j]-1))
            j=$(( (j+1) % n ))
        else
            j=$(( (j+1) % n ))
        fi
    done
}

sysad_Mentor_Allocation_func ()
{

    declare -a Mentor_array_sysad
    declare -a Mentee_capacity_array_sysad
    
    sysadlist=$(curl -s https://inductions.delta.nitt.edu/sysad-task1-mentorDetails.txt | cat | awk 'BEGIN{FS=" "; OFS=","} $0 !~/^Name/{if ($2 ~ /sysad/) print $3,$1 ;}' \
    | sort -k1,1nr)
    j=0
    for i in $sysadlist
    do
        Mentor_array_sysad[$j]=${i#*,}
        Mentee_capacity_array_sysad[$j]=${i%,*}
        j=$((j+1))
    done

    menteelist_sysad=$(awk 'BEGIN{FS=" ";OFS="_"} $0 !~/Rollno Name Domain/{if ($3 ~/.*sysad.*/) print $2,$1 ;}' $1)
    j=0
    n=${#Mentor_array_sysad[@]}
    for mentee in $menteelist_sysad
    do 
        if [[ ${Mentee_capacity_array_sysad[$j]} -ne 0 ]]
        then
            rollno=${mentee#*_}
            name=${mentee%_*}
            echo "$rollno $name" >> $HOME/mentors/Sysad/${Mentor_array_sysad[$j]}/Alottedmentees.txt
            setfacl -m u:${Mentor_array_sysad[$j]}:r-x $HOME/mentees/$mentee
            setfacl -m u:${Mentor_array_sysad[$j]}:rw- $HOME/mentees/$mentee/task_completed.txt
            Mentee_capacity_array_sysad[$j]=$((Mentee_capacity_array_sysad[$j]-1))
            j=$(( (j+1) % n ))
        else
            j=$(( (j+1) % n ))
        fi
    done
}

mentorAlloc ()
{
    if echo $(groups) | grep -q '\bcore_grp\b' 
    then
        web_Mentor_Allocation_func $1
        app_Mentor_Allocation_func $1
        sysad_Mentor_Allocation_func $1
        task_completed_setup $1
        echo "Mentor Allocation done sucessfully" 
    else
        echo "The current user is not core. Only a core can use this alias" 
    fi
}

alias mentorAllocation="mentorAlloc $HOME/mentee_domain.txt"
