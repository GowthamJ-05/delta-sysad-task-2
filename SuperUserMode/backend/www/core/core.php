<?php


function core_position() {
    $conn = connection();

    $container = <<<CONTAINER
    <div class="container">
    CONTAINER;

    $query = "select Roll_Number from Mentee_Details";
    $statement = $conn->prepare($query);
    $statement->execute();
    $statement->bind_result($rollno);



    while($statement->fetch()){

        $container .= <<<CONTAINER
        <div class = "component">
            <div><b>Roll Number:</b> $rollno</div>
            <div class = "domain">
        CONTAINER;


        $mentee_detail = array();
        $conn1 = connection();
        $stmt = $conn1->prepare("select domain, task_number, submitted, completed from Mentee_Details where Roll_Number = ?");
        $stmt->bind_param('i',$rollno);
        $stmt->execute();
        $stmt->bind_result($domain, $taskno, $submitted, $completed);
        while($stmt->fetch()){

            if (!array_key_exists($domain, $mentee_detail)){
                $mentee_detail[$domain] = array(
                    'submit'=>array(),
                    'completed'=>array()
                );
            }

            if ($submitted == 'y'){
                $task='task' . $taskno;
                $mentee_detail[$domain]['submit'][] = $task;
            }
            if ($completed == 'y'){
                $task='task' . $taskno;
                $mentee_detail[$domain]['completed'][] = $task;
            }

        }

        foreach ($mentee_detail[$domain] as $key => $value){
            $tasksSubmitted = implode(' ', $mentee_detail[$domain]['submit']);
            $tasksCompleted = implode(' ', $mentee_detail[$domain]['completed']);

            $container .= <<<CONTAINER
                    <div class = "row">
                        <div><b>Domain:</b> $key</div>
                        <div><b>Tasks Submitted:</b> $tasksSubmitted</div>
                        <div><b>Tasks Completed:</b> $tasksCompleted </div>
                    </div>
            CONTAINER; 
        }
        $container .= <<<CONTAINER
            </div>
        </div>
        CONTAINER;

        $stmt->close();
        $conn1->close();
    }

    $container .= <<<CONTAINER
    </div>
    CONTAINER;


    $html = <<< HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
        <link rel = "stylesheet" href="./style.css">
    </head>
    <body>
        <div id="heading">
            <div id = "login">
                <h1>You have logged in successfully</h1>
                <div>as <b>Core</b></div>
            </div>
        </div>
            $container
    </body>
    </html>
    HTML;

    echo $html;
}