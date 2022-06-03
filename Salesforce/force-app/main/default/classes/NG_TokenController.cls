public class NG_TokenController {
    public NG_Timesheet__c timeSheet  { get; private set; }
    public NG_Timesheet__c timeSheetData  { get; private set; }
    private String exisitingToken;
    private Id recordId;
    public  String message {get; set;}
    
    public NG_TokenController(){
        message = '';
        recordId = ApexPages.currentPage().getParameters().get('Id'); 
        System.debug('## recordId : ' + recordId);
        timeSheet = [select id,NG_UUID__c from NG_Timesheet__c where Source_Object_ID__c = : recordId];
        timeSheet.NG_UUID__c = '';
        timeSheetData = [select id,NG_UUID__c from NG_Timesheet__c where Source_Object_ID__c = : recordId];
        exisitingToken = timeSheetData.NG_UUID__c;
    }
    
    public PageReference verifyToken(){
        NGCSH__c config = NGCSH__c.getOrgDefaults();
        String URL = config.TS_Approval_Domain_Url__c + '/ts/TimesheetApproval?id=' + recordId;
        PageReference pageRef = new PageReference(URL);
        System.debug('in verifyToken');
        system.debug('timeSheet.NG_UUID__c : ' + timeSheet.NG_UUID__c);
        system.debug('exisitingToken : ' + exisitingToken);
            if(timeSheet.NG_UUID__c == exisitingToken){
                message = 'Success';                
                pageRef.setRedirect(true);
            }
            else {
                message = 'Incorrect Token';
                pageRef = null;//new PageReference('/apex/NG_Token?id=' + recordId);
                //pageRef.setRedirect(true);
            }
        return pageRef;
    }
    
}