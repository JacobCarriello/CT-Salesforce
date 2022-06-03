public with sharing class RC_ContactUsController {
    
    public String strName                   {get;set;}      //To get the Name of the contact person
    public String strEmail                  {get;set;}      //To get the email id to send the assitance 
    public String strDescription            {get;set;}      //To get the description about help.
    public String strSubject                {get;set;}      //To get the subject from page
    
    //Constructor
    public RC_ContactUsController()
    {
        strSubject = 'Help Desk';
        strName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
    }
    
    //Checking for security
    public Pagereference redirectUnAuthenticatedUser()
    {
        if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
        {
            return new Pagereference('/Signin');
        }
        
         return null;
    }
    
    //Send an email to selected email id along with details
    public void sendEmail()
    {
        try{
        
            //Create a master list to hold the emails we'll send  
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      
    
            //Create a new Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            //Set list of people who should get the email
            List<String> sendTo = new List<String>(); 
            sendTo=strEmail.split(';');     
            mail.setToAddresses(sendTo);
            
            //Set the Subject
            mail.setSubject(strSubject);
            //Set who the email is sent from
            mail.setReplyTo(UserInfo.getUserEmail());
            mail.setSenderDisplayName(strName);   
              
            //Set email contents - you can use variables!     
            mail.setHtmlBody(strDescription);
            
            // Add your email to the master list
            mails.add(mail);
        
            //Send all emails in the master list
            List<Messaging.SendEmailResult>  results =  Messaging.sendEmail(mails);
            
            system.debug('---  results ----'+results);
        
        }
        catch(Exception ex)
        {   
            system.debug('--- Ex ---'+ex);
        }
    }
}