import {globby} from 'globby'
import fs from 'fs'

import {searchForRow,insertIntoDatabase,updateDatabase,End_Connection} from './database.js'


import { server, serverClose } from './server.js'

const hostname = '0.0.0.0';
const port = process.env.PORT || 8080

async function updateMenteeDetails() {
    return new Promise((res,rej)=>{

        fs.readdir("/home/core/mentees",async (err,dirs)=>{
            if (err) console.log(err)
            let mentee_name
            let mentee_rollno
            for (let dir of dirs ){
                mentee_name = dir.split('_')[0]
                mentee_rollno = dir.split('_')[1]
        
                if (await searchForRow("Mentee_Details",mentee_rollno)){
                    await updateDatabase("Mentee_Details",mentee_rollno,mentee_name)
                }
                else{
                    await insertIntoDatabase("Mentee_Details",mentee_rollno,mentee_name)
                }
            }
            res()
        })

    }) 
}

async function updateMenteeDomain() {
    return new Promise((res,rej)=>{
        fs.readFile("/home/core/mentee_domain.txt",'utf-8',async (err,contents)=>{
            if (contents == undefined){
                res()
                return
            }
            let content=contents.split('\n')
            let fields ,mentee_rollno, domains 
            for (let line of content){
        
                if (line != '' && line != 'Rollno Name Domain'){
                    fields=line.split(' ')
                    mentee_rollno=fields[0]
                    // console.log(line,fields,rollno)
        
                    domains=[]
                    if (fields[2].includes('web')){
                        domains[0]='y'
                    }
                    else{
                        domains[0]='n'
                    }
                    if (fields[2].includes('app')){
                        domains[1]='y'
                    }
                    else{
                        domains[1]='n'
                    }
                    if (fields[2].includes('sysad')){
                        domains[2]='y'
                    }
                    else{
                        domains[2]='n'
                    }
        
        
                    if (await searchForRow("Mentee_Domain",mentee_rollno)){
                        await updateDatabase("Mentee_Domain",mentee_rollno,domains[0],domains[1],domains[2])
                    }
                    else{
                        await insertIntoDatabase("Mentee_Domain",mentee_rollno,domains[0],domains[1],domains[2])
                    }
                }
            } 
            res()
        })



    })
}

async function Completion(file){
    return new Promise((res,rej)=>{
        let mentee_rollno=file.split('/')[4].split('_')[1]
    //task_completed.txt
        fs.readFile(`${file}/task_completed.txt`,"utf-8",async (err,contents)=>{
            if (contents == undefined){
                res()
                return
            }
            const rows=contents.split('\n')
            const domains=rows[0].split(',')
            domains.shift()
            if (await searchForRow('Mentee_Task',mentee_rollno)){
                let j
                for (let i in domains){
                    j=parseInt(i)+1
                    await updateDatabase('Mentee_Task_Completed',mentee_rollno,domains[i],1,rows[1].split(',')[j])
                    await updateDatabase('Mentee_Task_Completed',mentee_rollno,domains[i],2,rows[2].split(',')[j])
                    await updateDatabase('Mentee_Task_Completed',mentee_rollno,domains[i],3,rows[3].split(',')[j])
                
                }
            }
            else{
                let j
                for (let i in domains){
                    j=parseInt(i)+1
                    await insertIntoDatabase('Mentee_Task',mentee_rollno,domains[i],1,undefined,rows[1].split(',')[j])
                    await insertIntoDatabase('Mentee_Task',mentee_rollno,domains[i],2,undefined,rows[2].split(',')[j])
                    await insertIntoDatabase('Mentee_Task',mentee_rollno,domains[i],3,undefined,rows[3].split(',')[j])
                }
            }
            res()
        })
    })
    
}




async function updateMenteeTaskCompleted() {
    return new Promise(async (res,rej)=>{
        const files = await globby(["/home/core/mentees/*"],{ onlyDirectories: true })
        for (let file of files){
            await Completion(file)
        }
        res()
    })
}


async function Submission(file) {

    return new Promise(async (res,rej)=>{
    
            let mentee_rollno=file.split('/')[4].split('_')[1]
             //task_submitted.txt
            fs.readFile(`${file}/task_submitted.txt`,"utf-8",async (err,contents)=>{
                if (contents == undefined){
                    res()
                    return
                }
    
                //creating tasksObject
                const lines = contents.split('\n')
                const tasksObject = {}
                let currentDomain = ''
                lines.forEach(line=>{
                    line=line.trim()
                    if (line.endsWith(':')){
                        currentDomain=line.slice(0,-1)
                        tasksObject[currentDomain]=[]
                    }
                    else if (line.includes(':')){
                        const [,status] = line.split(':').map(part=>part.trim())
                        tasksObject[currentDomain].push(status);
                    }
                })
    
    
                if (await searchForRow('Mentee_Task',mentee_rollno)){
                    for (let domain in tasksObject){
                        await updateDatabase('Mentee_Task_Submitted',mentee_rollno,domain,1,tasksObject[domain][0])
                        await updateDatabase('Mentee_Task_Submitted',mentee_rollno,domain,2,tasksObject[domain][1])
                        await updateDatabase('Mentee_Task_Submitted',mentee_rollno,domain,3,tasksObject[domain][2])
                    }
                }
                else{
                    for (let domain in tasksObject){
                        await insertIntoDatabase('Mentee_Task',mentee_rollno,domain,1,tasksObject[domain][0])
                        await insertIntoDatabase('Mentee_Task',mentee_rollno,domain,2,tasksObject[domain][1])
                        await insertIntoDatabase('Mentee_Task',mentee_rollno,domain,3,tasksObject[domain][2])
                    }
                }
                res()
            })
    })



}

async function updateMenteeTaskSubmitted() {
    return new Promise(async (res,rej)=>{
        const files = await globby("/home/core/mentees/*",{ onlyDirectories: true });
        for (let file of files){
            await Submission(file)
        }
        res()
    })
}

async function webMentor(file){
    return new Promise(async (res,rej)=>{
        let mentorName=file.split('/')[5]
        if (await searchForRow('Mentor_Details',mentorName,'web')){
        }
        else{
            await insertIntoDatabase('Mentor_Details',mentorName,'web')
        }
        res()
    })
}


async function appMentor(file){
    return new Promise(async (res,rej)=>{
        let mentorName=file.split('/')[5]
        if (await searchForRow('Mentor_Details',mentorName,'app')){
        }
        else{
            await insertIntoDatabase('Mentor_Details',mentorName,'app')
        }
        res()
    })
}


async function sysadMentor(file){
    return new Promise(async (res,rej)=>{
        let mentorName=file.split('/')[5]
        if (await searchForRow('Mentor_Details',mentorName,'sysad')){
        }
        else{
            await insertIntoDatabase('Mentor_Details',mentorName,'sysad')
        }
        res()
    })
}


async function updateMentorDetails(){
    return new Promise(async (res,rej)=>{
        const filesWeb = await globby("/home/core/mentors/Webdev/*",{ onlyDirectories: true })
        for (let file of filesWeb){
            await webMentor(file)
        }
        const filesApp = await globby("/home/core/mentors/Appdev/*",{ onlyDirectories: true })
        for (let file of filesApp){
            await appMentor(file)
        }
        const filesSysad = await globby("/home/core/mentors/Sysad/*",{ onlyDirectories: true })
        for (let file of filesSysad){
            await sysadMentor(file)
        }
        res()
    })

}

async function mentorAllocation(file){
    return new Promise((res,rej)=>{
        fs.readFile(file,'utf-8',async (err,contents)=>{
            if (contents == undefined){
                res()
                return
            }
            const rows=contents.split('\n')
            let mentorName=file.split('/')[5]
            for (let row of rows){
                 if (row != 'Rollno Name' && row != ''){
                    let menteeRollno = row.split(' ')[0]
                    if (await searchForRow('Mentor_Allocation',menteeRollno,mentorName)){
                        continue
                    }
                    else{
                        await insertIntoDatabase('Mentor_Allocation',menteeRollno,mentorName)
                    }
                 }
            }
            res()
        })
    })
}


async function updateMentorAllocation(){
    return new Promise(async (res,rej)=>{
        const files = await globby("/home/core/mentors/*/*/Alottedmentees.txt",{})
        for (let file of files){
            await mentorAllocation(file)
        }
        res()
    })
}




async function updateMenteeNotSubmit(){
    return new Promise(async (res,rej)=>{
        fs.readFile('/home/core/.mentee_not_submit.txt','utf-8',async (err,contents)=>{
            if (contents == undefined){
                res()
                return
            }
            let rows=contents.split('\n')
            for (let row of rows){
                if (row != 'Rollno Name Domain Taskno-1'){
                    let menteeRollno = row.split(' ')[0]
                    let domain = row.split(' ')[2]
                    let taskno = row.split(' ')[3]
                    if (await searchForRow('Mentee_Not_Submit',menteeRollno,domain,taskno)){
                        continue
                    }
                    else{
                        await insertIntoDatabase('Mentee_Not_Submit',menteeRollno,domain,taskno)
                    }
                }
            }
            res()
        })
    })
}




async function updateGeminiClubDatabase(){
    await updateMenteeDetails()
    await updateMenteeDomain()
    await updateMenteeTaskCompleted()
    await updateMenteeTaskSubmitted()
    await updateMentorDetails()
    await updateMentorAllocation()
    await updateMenteeNotSubmit()
    

}
updateGeminiClubDatabase()



server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});



process.on("SIGINT",async ()=>{
    await End_Connection()
    serverClose()
})

process.on("SIGTERM",async ()=>{
    await End_Connection()
    serverClose()
})