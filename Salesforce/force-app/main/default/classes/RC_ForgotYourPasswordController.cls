public with sharing class RC_ForgotYourPasswordController {
    
    public String strUsername           {get; set;}     //To get the user name from forgot password page.
    public boolean blnSuccess           {get; set;}     //To check the username is get success or not
       
    //Contstrutor
    public RC_ForgotYourPasswordController () {}
    
    //Securtiy redirecting 
    public Pagereference redirectAuthenticatedUser()
    {
        if(Userinfo.getUserType() == 'CspLitePortal' || Userinfo.getUserType() == 'PowerCustomerSuccess')
        {
            return new Pagereference('/Home_v2');
        }
        return null;
    } 
    
    
    //To check the user is available or not. 
    //If not available, will show the error message on page else it will redirect to forgot paswword confirmation page     
    public PageReference forgotPassword() {     
        
        List<User> lstUser = RC_AccessController.query('Select Username, ContactId From User where Username = \'' + strUsername + '\' And ContactId != null');
        blnSuccess =  false;
        
        if(!lstUser.isEmpty())
        {
            blnSuccess = Site.forgotPassword(strUsername);        
            PageReference pr = Page.ForgotYourPasswordConfirm;  
            pr.setRedirect(true);        
            if (blnSuccess) {              
                return pr;
            }           
            return null;
        }
        
        return null;
    }


}