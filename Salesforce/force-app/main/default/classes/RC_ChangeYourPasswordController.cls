/**
 * An apex page controller that exposes the change password functionality
 */
 
public with sharing class RC_ChangeYourPasswordController {
    public String oldPassword 					{get; set;}
    public String newPassword 					{get; set;}
    public String verifyNewPassword 			{get; set;}   
    public Boolean isErrorPresent				{get; set;}
    
    public RC_ChangeYourPasswordController()
    {
    	// No actions
    }
    
    public Pagereference redirectUnAuthenticatedUser()
    {
        return (Userinfo.getUserType() != 'CspLitePortal' && Userinfo.getUserType() != 'PowerCustomerSuccess') ? new Pagereference('/Signin') : null;
    }
    
    public PageReference changePassword() {
    	
    	String strRetURL;
    	
    	// Check if user is changing password from email link or from My Profile page
    	strRetURL = Site.isPasswordExpired() ? '/Home_v2' : '/MyAccount_v1';
    		
		Pagereference prResultURL = Site.changePassword(newPassword, verifyNewPassword, oldpassword); 
		
		// Check if any errors found in changing the password
		if(prResultURL == null)
		{
			isErrorPresent = true;
			return prResultURL;
		}
   		return new Pagereference(strRetURL);
    }
}