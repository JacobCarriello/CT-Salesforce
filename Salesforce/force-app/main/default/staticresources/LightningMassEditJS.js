document.addEventListener("DOMContentLoaded", function(){
    var modalEl = document.getElementById("cancel-modal");
    modalEl.style.display  = "none";
    var modalBackEl = document.getElementById("cancel-modal-backdrop");
    modalBackEl.style.display  = "none";
});
function goBack(){
    console.log('goback');
    if( typeof sforce != 'undefined' && sforce != null ){
        sforce.one.back(true);
    }
}
function openCancelModal(){
    var modalEl = document.getElementById("cancel-modal");
    var modalBackEl = document.getElementById("cancel-modal-backdrop");
    modalEl.style.display  = "block";
    modalBackEl.style.display  = "block";
}

function closeCancelModal(){
    var modalEl = document.getElementById("cancel-modal");
    var modalBackEl = document.getElementById("cancel-modal-backdrop");
    modalEl.style.display = "none";
    modalBackEl.style.display = "none";
}