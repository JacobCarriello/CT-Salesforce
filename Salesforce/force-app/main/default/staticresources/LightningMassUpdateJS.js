document.addEventListener("DOMContentLoaded", function(){
    
    var currentStep = parseInt("{!HTMLENCODE(step)}");
    var progressBar = document.getElementById("progressBar");
    var wlis = document.getElementById("wizardlist").getElementsByTagName("li");
    for (i=0; i<wlis.length; i++){
        
        if (i<currentStep) {
            wlis[i].classList.add("slds-is-active");
        }else {
            wlis[i].classList.remove("slds-is-active");
        }
    }
    switch (currentStep) {
        case 1:
            progressBar.style.width="0%";
            break;
        case 2:
            progressBar.style.width="25%";
            break;
        case 3:
            progressBar.style.width="50%";
            break;
        case 4:
            progressBar.style.width="75%";
            break;
        case 5:
            progressBar.style.width="100%";
    }
    var spinningEl = document.getElementById("spinning");
    spinningEl.style.visibility  = "hidden";
    var modalEl = document.getElementById("cancel-modal");
    modalEl.style.visibility  = "hidden";
    var modalBackEl = document.getElementById("cancel-modal-backdrop");
    modalBackEl.style.visibility  = "hidden";
    
    
});

function openCancelModal(){
    var modalEl = document.getElementById("cancel-modal");
    var modalBackEl = document.getElementById("cancel-modal-backdrop");
    modalEl.style.visibility  = "visible";
    modalBackEl.style.visibility  = "visible";
}

function closeCancelModal(){
    var modalEl = document.getElementById("cancel-modal");
    var modalBackEl = document.getElementById("cancel-modal-backdrop");
    modalEl.style.visibility  = "hidden";
    modalBackEl.style.visibility  = "hidden";
}

function showSpinning(){
    var spinningEl = document.getElementById("spinning");
    spinningEl.style.visibility  = "visible";
}

function goBack(){
    if( typeof sforce != 'undefined' && sforce != null ){
        sforce.one.back(true);
    }
}

function cancel(){
    goBack();
    return false;
}