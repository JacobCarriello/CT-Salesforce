({
    init: function (component, event, helper) {
        helper.getContactId(component);
    },
    
    handleUploadFinished : function(component, event, helper) {
       helper.uploadFile(event); 
    }
})