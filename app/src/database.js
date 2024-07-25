import mysql from 'mysql2'


const pool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    port: process.env.MYSQL_PORT,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_ROOT_PASSWORD,
    database: process.env.MYSQL_DATABASE
}).promise()

export async function searchForRow (table,param1,param2,param3){
    switch(table){
        case 'Mentee_Details':{
            let tableName=mysql.escapeId(table)
            const [row]=await pool.query(`
            select * 
            from ${tableName}
            where Roll_Number = ?
            ;`,[param1])
            
            if (row.length){
                return true
            }
            else{
                return false
            }
        }

        case 'Mentee_Domain':{
            let tableName=mysql.escapeId(table)
            const [row]=await pool.query(`
            select * 
            from ${tableName}
            where Roll_Number = ?
            ;`,[param1])

            if (row.length){
                return true
            }
            else{
                return false
            }
        }


        case 'Mentee_Task':{
            let tableName=mysql.escapeId(table)
            const [row]=await pool.query(`
            select * 
            from ${tableName}
            where Roll_Number = ?
            ;`,[param1])

            if (row.length){
                return true
            }
            else{
                return false
            }
        }
        case 'Mentor_Details':{
            let tableName=mysql.escapeId(table)
            const [row]=await pool.query(`
            select * 
            from ${tableName}
            where Mentor_name = ? and domain = ?
            ;`,[param1,param2])

            if (row.length){
                return true
            }
            else{
                return false
            }
        }
        case 'Mentor_Allocation':{
            let tableName=mysql.escapeId(table)
            const [row]=await pool.query(`
            select * 
            from ${tableName}
            where Roll_Number = ? and Mentor_name = ?
            ;`,[param1,param2])

            if (row.length){
                return true
            }
            else{
                return false
            }
        }
        case 'Mentee_Not_Submit':{
            let tableName=mysql.escapeId(table)
            const [row]=await pool.query(`
            select * 
            from ${tableName}
            where Roll_Number = ? and domain = ? and task_number = ?
            ;`,[param1,param2,param3])

            if (row.length){
                return true
            }
            else{
                return false
            }
        }

    }
}

export async function insertIntoDatabase (table,param1,param2,param3,param4,param5){
    switch(table){
        case 'Mentee_Details':{
            let tableName=mysql.escapeId(table)
            await pool.query(`
            insert
            into ${tableName}
            values (?,?)
            ;`,[param1,param2])

            break
        }
        case 'Mentee_Domain':{
            let tableName=mysql.escapeId(table)
            const [row]=await pool.query(`
            insert
            into ${tableName}
            values (?,?,?,?)
            ;`,[param1,param2,param3,param4])

            break

        }
        case 'Mentee_Task':{
            let tableName=mysql.escapeId(table)
            await pool.query(`
            insert
            into ${tableName}
            values (?,?,?,?,?)
            ;`,[param1,param2,param3,param4,param5])
            break

        }
        case 'Mentor_Details':{
            let tableName=mysql.escapeId(table)
            const [row]=await pool.query(`
            insert
            into ${tableName}
            values (?,?)
            ;`,[param1,param2])

            break

        }
        case 'Mentor_Allocation':{
            let tableName=mysql.escapeId(table)
            await pool.query(`
            insert
            into ${tableName}
            values (?,?)
            ;`,[param1,param2])

            break

        }
        case 'Mentee_Not_Submit':{
            let tableName=mysql.escapeId(table)
            await pool.query(`
            insert
            into ${tableName}
            values (?,?,?)
            ;`,[param1,param2,param3])

            break

        }
    }
}
export async function updateDatabase (table,param1,param2,param3,param4,param5){
    switch(table){
        case 'Mentee_Details':{
            let tableName=mysql.escapeId(table)
            await pool.query(`
            update ${tableName}
            set Mentee_name = ?
            where Roll_Number = ?
            ;`,[param2,param1])
            break
        }

        case 'Mentee_Domain':{
            let tableName=mysql.escapeId(table)
            await pool.query(`
            update ${tableName}
            set web = ?, app = ?, sysad =?
            where Roll_Number = ? 
            ;`,[param2,param3,param4,param1])
            break
        }

        case 'Mentee_Task_Submitted':{
            let tableName=mysql.escapeId('Mentee_Task')
            await pool.query(`
            update ${tableName}
            set submitted = ?
            where Roll_Number = ? and domain = ? and task_number = ?
            ;`,[param4,param1,param2,param3])
            break
        }


        case 'Mentee_Task_Completed':{
            let tableName=mysql.escapeId('Mentee_Task')
            await pool.query(`
            update ${tableName}
            set completed = ?
            where Roll_Number = ? and domain = ? and task_number = ?
            ;`,[param4,param1,param2,param3])
            break
        }
    }
}


export async function End_Connection(){
    pool.end((err) => {
        if (err) {
          console.error('Error terminating connection pool:', err);
        } else {
          console.log('Connection pool closed.');
        }
    })
}

