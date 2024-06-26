#!/bin/bash
#This is the start of the program

setupfunc ()
{
    # Group creation 
    groupadd core_grp
    groupadd mentors_grp
    groupadd mentees_grp

    groupadd web_mentors_grp
    groupadd app_mentors_grp
    groupadd sysad_mentors_grp

    # The core user creation and placing required directories within /home/core
    useradd -m -g core_grp core
    cd /home/core
    mkdir mentees mentors
    cd mentors
    mkdir Webdev Appdev Sysad
    cp /code/GeminiClubSetup/$3 /home/core

    # Basic permissions using chmod to restrict access to directories 
    chmod 711 /home/core
    chmod 701 /home/core/mentees
    chmod 700 /home/core/mentors
    chmod 704 /home/core/mentors/Appdev
    chmod 704 /home/core/mentors/Webdev
    chmod 704 /home/core/mentors/Sysad

    # Specific permissions of core to access directories  
    setfacl -m u:core:rwx /home/core/mentees
    setfacl -m u:core:rwx /home/core/mentors
    setfacl -m u:core:rwx /home/core/mentors/Appdev
    setfacl -m u:core:rwx /home/core/mentors/Webdev
    setfacl -m u:core:rwx /home/core/mentors/Sysad

    # Changing the owner of mentee_domain.txt to core
    chown core:core_grp /home/core/$3

    # Permissions to mentee_domain.txt
    chmod 700 /home/core/$3

    # Change core's shell from sh to bash
    usermod -s /bin/bash core
    
    # Add alias files to .bashrc file of core
    (cat "/code/GeminiClubSetup/mentorAllocation_alias.sh" ; cat "/code/GeminiClubSetup/displayStatus_alias.sh") >> /home/core/.bashrc

    # Mentee users creation and permission
    mentee_list=$(awk 'BEGIN{OFS="_"} $0 !~/Name RollNo/{print $1,$2}' $2)
    for mentee in $mentee_list
    do 
        # Mentee user creation 
        useradd -m -d /home/core/mentees/$mentee -g mentees_grp $mentee

        # Allow defaults permissions for $mentee
        setfacl -m u:$mentee:rwx /home/core/mentees/$mentee
        setfacl -d -m u:$mentee:rwx /home/core/mentees/$mentee

        # Creation of required files within $mentee's home directory
        cd /home/core/mentees/$mentee
        touch domain_pref.txt task_completed.txt task_submitted.txt

        # Change the ownership of $mentees folder to core
        chown -R core:core_grp /home/core/mentees/$mentee

        # Allow access for core to files created in the future
        setfacl -d -m u:core:rwx /home/core/mentees/$mentee

        # Specific permission for $mentee on task_completed.txt
        setfacl -m u:$mentee:r-- /home/core/mentees/$mentee/task_completed.txt

        # Restrict the mentees_grp access to $mentee
        setfacl -m g::0 /home/core/mentees/$mentee

        # Restrict the others access to $mentee
        setfacl -m o::0 /home/core/mentees/$mentee

        # Allow write access to mentee_domain.txt
        setfacl -m u:$mentee:rw- /home/core/$3

        # Change the mentee's shell from sh to bash
        usermod -s /bin/bash $mentee

        # Deny $mentee the read permissions of / and /home
        setfacl -m u:$mentee:--x /
        setfacl -m u:$mentee:--x /home

        # Add alias files to .bashrc of $mentee
        (cat "/code/GeminiClubSetup/domainPref_alias.sh" ; cat "/code/GeminiClubSetup/submitTask_alias.sh" ) >> /home/core/mentees/$mentee/.bashrc
    done

    # Mentors users creation and permission

    # Webdev Mentors
    webdev_mentor_list=$(awk 'BEGIN{FS=" ";} $0!~/^Name/{if ($2 ~ /web/) print $1;}' $1)
    for mentor in $webdev_mentor_list
    do
        
        # Mentor user creation 
        useradd -m -d /home/core/mentors/Webdev/$mentor -g mentors_grp $mentor
        usermod -aG  web_mentors_grp $mentor

        # Allow defaults permissions for $mentor
        setfacl -m u:$mentor:rwx /home/core/mentors/Webdev/$mentor
        setfacl -d -m u:$mentor:rwx /home/core/mentors/Webdev/$mentor
        
        # Creation of required files and directories within $mentor's home directory
        cd /home/core/mentors/Webdev/$mentor
        touch Alottedmentees.txt
        mkdir submitted_tasks
    
        # Creation of required directories within submitted_tasks
        cd submitted_tasks
        mkdir task1 task2 task3

        # Change the ownership of $mentor folder to core
        chown -R core:core_grp /home/core/mentors/Webdev/$mentor

        # Allow access for core to files created in the future
        setfacl -d -m u:core:rwx /home/core/mentors/Webdev/$mentor

        # Restrict the mentors_grp access to $mentor
        setfacl -m g::0 /home/core/mentors/Webdev/$mentor
        
        # Restrict the others access to $mentor
        setfacl -m o::0 /home/core/mentors/Webdev/$mentor
    
        # Change the mentor's shell from sh to bash
        usermod -s /bin/bash $mentor
    
        # Allow $mentor access to /home/core, /home/core/mentees, /home/core/mentors, /home/core/mentors/Webdev 
        setfacl -m u:$mentor:r-x /home/core 
        setfacl -m u:$mentor:r-x /home/core/mentees
        setfacl -m u:$mentor:r-x /home/core/mentors
        setfacl -m u:$mentor:r-x /home/core/mentors/Webdev 


        # Deny $mentee the read permissions of / and /home
        setfacl -m u:$mentor:--x /
        setfacl -m u:$mentor:--x /home
        
        # Add alias files to .bashrc file of $mentor
        cat "/code/GeminiClubSetup/submitTask_alias.sh" >> /home/core/mentors/Webdev/$mentor/.bashrc

    done

    #Appdev Mentors    
    appdev_mentor_list=$(awk 'BEGIN{FS=" ";} $0!~/^Name/{if ($2 ~ /app/) print $1;}' $1)
    for mentor in $appdev_mentor_list
    do
        # Mentor user creation and placing required files within $mentor's home directory
        useradd -m -d /home/core/mentors/Appdev/$mentor -g mentors_grp $mentor
        usermod -aG  app_mentors_grp $mentor

        # Allow defaults permissions for $mentor
        setfacl -m u:$mentor:rwx /home/core/mentors/Appdev/$mentor
        setfacl -d -m u:$mentor:rwx /home/core/mentors/Appdev/$mentor

        # Creation of required files and directories within $mentor's home directory
        cd /home/core/mentors/Appdev/$mentor
        touch Alottedmentees.txt
        mkdir submitted_tasks

        # Creation of required directories within submitted_tasks
        cd submitted_tasks
        mkdir task1 task2 task3

        # Change the ownership of $mentor folder to core
        chown -R core:core_grp /home/core/mentors/Appdev/$mentor

        # Allow access for core to files created in the future
        setfacl -d -m u:core:rwx /home/core/mentors/Appdev/$mentor

        # Restrict the mentors_grp access to $mentor
        setfacl -m g::0 /home/core/mentors/Appdev/$mentor

        # Restrict the others access to $mentor
        setfacl -m o::0 /home/core/mentors/Appdev/$mentor

        # Change the mentor's shell from sh to bash
        usermod -s /bin/bash $mentor


        # Allow $mentor access to /home/core, /home/core/mentees, /home/core/mentors, /home/core/mentors/Appdev 
        setfacl -m u:$mentor:r-x /home/core 
        setfacl -m u:$mentor:r-x /home/core/mentees
        setfacl -m u:$mentor:r-x /home/core/mentors
        setfacl -m u:$mentor:r-x /home/core/mentors/Appdev 


        # Deny $mentor the read permissions of / and /home
        setfacl -m u:$mentor:--x /
        setfacl -m u:$mentor:--x /home
        
        # Add alias files to .bashrc file of $mentor
        cat "/code/GeminiClubSetup/submitTask_alias.sh" >> /home/core/mentors/Appdev/$mentor/.bashrc

    done

    # Sysad Mentors
    sysad_mentor_list=$(awk 'BEGIN{FS=" ";} $0!~/^Name/{if ($2 ~ /sysad/) print $1;}' $1)
    for mentor in $sysad_mentor_list
    do
        # Mentor user creation and placing required files within $mentor's home directory
        useradd -m -d /home/core/mentors/Sysad/$mentor -g mentors_grp $mentor
        usermod -aG  sysad_mentors_grp $mentor

        # Allow defaults permissions for $mentor
        setfacl -m u:$mentor:rwx /home/core/mentors/Sysad/$mentor
        setfacl -d -m u:$mentor:rwx /home/core/mentors/Sysad/$mentor
   
        # Creation of required files and directories within $mentor's home directory
        cd /home/core/mentors/Sysad/$mentor
        touch Alottedmentees.txt
        mkdir submitted_tasks

        # Creation of required directories within submitted_tasks
        cd submitted_tasks
        mkdir task1 task2 task3

        # Change the ownership of $mentor folder to core
        chown -R core:core_grp /home/core/mentors/Sysad/$mentor

        # Allow access for core to files created in the future
        setfacl -d -m u:core:rwx /home/core/mentors/Sysad/$mentor

        # Restrict the mentors_grp access to $mentor
        setfacl -m g::0 /home/core/mentors/Sysad/$mentor

        # Restrict the others access to $mentor
        setfacl -m o::0 /home/core/mentors/Sysad/$mentor

        # Change the mentor's shell from sh to bash
        usermod -s /bin/bash $mentor

        # Allow $mentor access to /home/core, /home/core/mentees, /home/core/mentors, /home/core/mentors/Sysad 
        setfacl -m u:$mentor:r-x /home/core 
        setfacl -m u:$mentor:r-x /home/core/mentees
        setfacl -m u:$mentor:r-x /home/core/mentors
        setfacl -m u:$mentor:r-x /home/core/mentors/Sysad 


        # Deny $mentor the read permissions of / and /home
        setfacl -m u:$mentor:--x /
        setfacl -m u:$mentor:--x /home
        
        # Add alias files to .bashrc file of $mentor
        cat "/code/GeminiClubSetup/submitTask_alias.sh" >> /home/core/mentors/Sysad/$mentor/.bashrc

    done

    return 0

}


setupfunc /code/GeminiClubSetup/mentor_details.txt /code/GeminiClubSetup/mentee_details.txt mentee_domain.txt 
