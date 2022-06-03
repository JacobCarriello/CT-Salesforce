global class MedestarWebService{

    webservice static String sendConfirmation(String crId, String fieldAPIName){
        String msg = 'Success';
        try{
            if(crId != null){
                if(fieldAPIName == 'Medestar_Client_Confirmation_Last_Sent__c'){
                    update new TR1__Closing_Report__c(id = crId, Medestar_Client_Confirmation_Last_Sent__c = System.Now());
                    msg = Label.Client_Confirmation_Success;
                }else if(fieldAPIName == 'Medestar_Candidate_Confirmation_LastSent__c'){
                    update new TR1__Closing_Report__c(id = crId, Medestar_Candidate_Confirmation_LastSent__c = System.Now());
                    msg = Label.Candidate_Confirmation_Success;
                }
            }
        }catch(Exception ex){
            msg = ex.getMessage();
        }
        return msg;
    }
}