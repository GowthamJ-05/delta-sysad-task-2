<?php 

function connection(){
    $servername = getenv("MYSQL_HOST");
    $user = getenv("MYSQL_USER");
    $pass = getenv("MYSQL_ROOT_PASSWORD");
    $dbname = getenv("MYSQL_DATABASE");

    // Create connection
    $conn = new mysqli($servername, $user, $pass, $dbname);
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    return $conn;
}
