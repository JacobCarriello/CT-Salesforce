public with sharing class ReassignGuestOwnershipController {

    /**
     * Constructor
     */
    public ReassignGuestOwnershipController(){
        user = new User();
    }

    public User user {get;set;}
    public Id userId{get;set;}
    public List<User> userList {get;set;}
    public String userName {get;set;}

    public PageReference callLookup() {
        userList = new List<User>();
        List<User> users = [
            SELECT id, Name
            FROM User
            WHERE IsActive = TRUE
            LIMIT 49000
        ];
        if (userName != null) {
            for (User u : users) {
                if (u.Name.contains(userName)) {
                    userList.add(u);
                }
            }
        } else  {
            userList.addAll(users);
        }
        PageReference pr = new PageReference('/apex/UserLookup');
        pr.setRedirect(false);
        return pr;
    }

    public PageReference goBack(){
        userName = ApexPages.currentPage().getParameters().get('userName');
        userId = ApexPages.currentPage().getParameters().get('userId');
        PageReference pr = new PageReference('/apex/ReassignGuestOwnership');
        pr.setRedirect(false);
        return pr;
    }

    /**
     *  Property stores the selected object api name for calculating and revealing the number of records
     */
    public String selectedObjectApiName{get;set;}

    /**
     *  Property will indicate if the batch job has stared by clicking the button
     */
    public Boolean jobIsRunning {
        get{
            if(jobIsRunning == null) jobIsRunning = false;
            return jobIsRunning;
        }
        set;
    }

    /**
     *  Property will return the batch size that is used for executing the batch apex
     */
    public String selectedBatchSize{
        get{
            if(selectedBatchSize == null) selectedBatchSize = '200';
            return selectedBatchSize;
        }
        set;
    }

    /**
     *  Property will return a selectoption list with batch size numbers
     */
    public List<SelectOption> batchSizeSelectList{
        get{
            if(batchSizeSelectList == null){
                batchSizeSelectList = new List<SelectOption>{
                        new SelectOption('1','1'),
                        new SelectOption('5','5'),
                        new SelectOption('10','10'),
                        new SelectOption('50','50'),
                        new SelectOption('100','100'),
                        new SelectOption('200','200'),
                        new SelectOption('500','500'),
                        new SelectOption('1000','1000')
                };
            }
            return batchSizeSelectList;
        }
        set;
    }

    /**
     * Inner class for store and select the objects that need the Owner field to convert
     * from Site User to selected 'fallback'.
     */
    public class ConvertObject{
        public Boolean Selected {get;set;}
        public String ObjectLabel {get;set;}
        public String ObjectApiName {get;set;}
        public Integer RecordCount {get;set;}
        public Boolean DisplayCount {get;set;}

        public String ErrorMessages {
            get{
                if(ErrorMessages == null) ErrorMessages = '';
                return ErrorMessages;
            }
            set;
        }

        public ConvertObject(String label, String apiName, Integer numberOfRecords){
            this.Selected = false;
            this.DisplayCount = false;
            this.ObjectLabel = label;
            this.ObjectApiName = apiName;
            this.RecordCount = numberOfRecords;
        }
    }

    /**
     * This property will hold the list of ConvertObject records which have one or more owners assigned to the Site user
     */
    public List<ConvertObject> convertObjectList{
        get{
            if(convertObjectList == null){
                convertObjectList = new List<ConvertObject>();

                //Get Guest User Id
                if(!guestUserMap.isEmpty()){
                    //Check if an object has records with the Guest Site User as Owner
                    for(String objectApiName:objectConversionList){
                        if(HasRecordsToConvert(objectApiName, guestUserMap.keySet())){
                            String objectLabel = Schema.getGlobalDescribe().get(objectApiName.toLowerCase()).getDescribe().getLabelPlural();
                            ConvertObject newConvertObject = new ConvertObject(objectLabel, objectApiName, 0);
                            convertObjectList.add(newConvertObject);
                        }
                    }
                }
            }
            return convertObjectList;
        }
        set;
    }

    /**
     *  Property will return a list of object api names from the application settings
     */
    private List<String> objectConversionList{
        get{
            if(objectConversionList == null){
                objectConversionList = ReassignConstants.LIST_OBJECT_CONVERSION;
            }
            return objectConversionList;
        }
        set;
    }

    /**
     *   Method will return a list of Site Guest Users
     */
    @testVisible
    private Map<Id, User> guestUserMap{
        get{
            if(guestUserMap == null){
                guestUserMap = new Map<Id, User>();

                Map<Id, Profile> profileMap = new Map<Id, Profile>([
                        SELECT Id
                        FROM Profile
                        WHERE UserLicense.Name LIKE 'Guest%'
                ]);
                Set<Id> guestProfileIdSet = profileMap.keySet();
                if(!profileMap.isEmpty()) {
                    guestUserMap = new Map<Id, User>([
                        SELECT Id, Name
                        FROM User
                        WHERE ProfileId IN :guestProfileIdSet
                    ]);
                }
            }
            return guestUserMap;
        }
        set;
    }

    /**
     *  Property will return the maxLimit of row count as an integer
     */
    public Integer maxLimit{
        get{
            if(maxLimit == null) maxLimit = 10000;
            return maxLimit;
        }
        set;
    }

    /**
     *  Method will return the number of records with the Site Guest User as Owner of the record
     */
    @testVisible
    private Integer GetObjectRecordCount(String objectName, Set<Id> guestUserIdSet){
        Integer count = 0;

        String soql = 'SELECT count() FROM ' + objectName + ' WHERE OwnerId IN :guestUserIdSet LIMIT ' + maxLimit;
        count = Database.countQuery(soql);

        return count;
    }

    /**
     *  Method will return if the object has records with the Site Guest User as Owner of the record
     */
    @testVisible
    private Boolean HasRecordsToConvert(String objectName, Set<Id> guestUserIdSet){
        Boolean hasRecords = false;

        //Query the count of all records with a Site User owner if the limit of max number of queries is not yet hit
        String soql = 'SELECT Id FROM ' + objectName + ' WHERE OwnerId IN :guestUserIdSet LIMIT 1';
        List<sObject> recordList = Database.query(soql);
        hasRecords = !recordList.isEmpty();

        return hasRecords;
    }

    /**
     *  Method will start the conversion process for the selected object(s) if the fallbackuser is selected
     */
    public PageReference ConvertSiteUserOwnership(){

        //Convert Process
        if(userId != null){
            List<String> objectApiNameList = new List<String>();
            for(ConvertObject co:convertObjectList){
                if(co.Selected) objectApiNameList.add(co.ObjectApiName);
            }

            if(!objectApiNameList.isEmpty()){
                try{
                    ReassignGuestOwnershipBatch qBatch = new ReassignGuestOwnershipBatch(objectApiNameList, 0, guestUserMap.keySet(), userId, Integer.valueOf(selectedBatchSize));
                    Database.executeBatch(qBatch, Integer.valueOf(selectedBatchSize));
                    jobIsRunning = true;
                }catch(Exception ex){
                    ApexPages.addMessages(ex);
                    system.debug('### ERROR: ' + ex.getStackTraceString());
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select objects to convert'));
                return null;
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select User'));
            return null;
        }
        return null;
    }

    /**
     *  Method will make sure the convert object list gets updated when the job is running or just finished
     */
    public PageReference RecalculateConvertObjects(){
        jobIsRunning = isQueueableJobRunning;
        UpdateConvertObjectList();
        return null;
    }

    /**
     *  Method will update the convert object list with a new count on the objects.
     *  Also unchecked objects gets recalculated because new records can be added and
     *  when opening the screen and the job is still running does not check the objects anymore
     */
    private void UpdateConvertObjectList(){
        for(Integer i=0;i<convertObjectList.size();i++){
            ConvertObject co = convertObjectList.get(i);
            if(!HasRecordsToConvert(co.ObjectApiName, guestUserMap.keySet())) {
                convertObjectList.remove(i);
                i--;
            }
        }
    }

    /**
     *  Method will update the convert object list with a new count on the objects.
     *  Also unchecked objects gets recalculated because new records can be added and
     *  when opening the screen and the job is still running does not check the objects anymore
     */
    public PageReference RevealRecordCount(){
        if(selectedObjectApiName != null){
            Integer count = GetObjectRecordCount(selectedObjectApiName, guestUserMap.keySet());
            for(ConvertObject co:convertObjectList){
                if(co.ObjectApiName == selectedObjectApiName){
                    co.RecordCount = count;
                    co.DisplayCount = true;
                    selectedObjectApiName = null;
                }
            }
        }
        return null;
    }

    /**
     *  Property will return the Id of this Apex Class
     */
    private Id apexClassId{
        get{
            if(apexClassId == null){
                List<ApexClass> apexClassList = [
                    SELECT Id
                    FROM ApexClass
                    WHERE Name = 'ReassignGuestOwnershipBatch'
                ];
                if(!apexClassList.isEmpty()) {
                    apexClassId = apexClassList.get(0).Id;
                }
            }
            return apexClassId;
        }
        set;
    }

    /**
     * Property will get the active queued job
     */
    private List<AsyncApexJob> activeQueueableJobList{
        get{
            Set<String> statusSet = new Set<String>{'Queued', 'Preparing', 'Processing'};
            return [
                SELECT Status, NumberOfErrors
                FROM AsyncApexJob
                WHERE ApexClassId = :apexClassId
                AND  Status IN :statusSet
            ];
        }
        set;
    }

    /**
     *  Property will return true of an cxsSetupConvertSiteUserQueueanle AsyncApexJob is running
     */
    public Boolean isQueueableJobRunning{
        get{
            Boolean isRunning = !activeQueueableJobList.isEmpty();
            if(!isRunning) {
                system.debug('### Job Stopped ###');
                UpdateConvertObjectList();
            }
            return isRunning;
        }
        set;
    }

}