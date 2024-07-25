<?php

require "database.php";
function process($username, $password) {

    $conn = connection();

    $query = "SELECT Position FROM Account_Details WHERE Username = ? AND Passwrd = ?";
    $statement = $conn->prepare($query);
    
    $statement->bind_param("ss", $username, $password);
    $statement->execute();
    $statement->bind_result($position);
    $validity = false;
    while($statement->fetch()){
        $validity = true;
    }
    if ($validity){
        evaluate_position($position);
    }else{
        echo "Invalid password or username";
    }
    
    $statement->close();
    $conn->close();
}

function evaluate_position($position) {
    if ($position == "core") {
        require "core/core.php";
        core_position();
    }
    elseif($position == "mentor"){
        require "mentor/mentor.php";
        mentor_position($username);
    }
    else{
        require "mentee/mentee.php";
        mentee_position($username);
    }
}





