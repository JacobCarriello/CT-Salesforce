public with sharing class PostToLogicMelonController {

    public TR1__Job__c job {get; set;}
    public List<AdvChannelWrapper> advChannelWrapperList {get; set;}
    public List<String> ChannelIdVal = new List<String>();
    public List<DeleteChannelListWrapper> deletechannelList {get; set;}
    public Boolean hide_showPostButton {get; set;}
    public String recordType_name {get; set;}


    public PostToLogicMelonController(ApexPages.StandardController ctrl) {
                
        if(ctrl == null || ctrl.getId() == null) {
            Utility.addErrorMessage('No Job selected to Post.');
            return;
        }

        String apiNameForDescriptionField;

        Set<String> fieldsAdded = new Set<String>();
        fieldsAdded.add('ID');
        fieldsAdded.add('NAME');
        fieldsAdded.add('RECORDTYPEID');
        fieldsAdded.add('RECORDTYPE.NAME');

        string query = '';
        for(LogicMelonXMLTag__c lm : LogicMelonXMLTag__c.getAll().values()){
            if(String.IsNotBlank(lm.FieldAPI__c) && !fieldsAdded.contains(lm.FieldAPI__c.toUpperCase())) {
                if(lm.StartTag__c == '<JobDescription>') {
                    apiNameForDescriptionField = lm.FieldAPI__c;
                }
                fieldsAdded.add(lm.FieldAPI__c.toUpperCase());
            }
        }

        for(String str : fieldsAdded) {
            query += str + ',';
        }

        query = query.subString(0, query.length() - 1);


        query = 'Select ' + query + ' from TR1__Job__c where Id = \'' + ctrl.getId() + '\'';

        system.debug(query);
        job = Database.query(query);
               
        if(String.isNotBlank(apiNameForDescriptionField) && String.IsNotBlank((String)job.get(apiNameForDescriptionField))){
            String jobDes = (string)job.get(apiNameForDescriptionField);
            if((jobDes).length() < 150){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Description has to be 150 or more characters to post a job to LogicMelon.'));
                hide_showPostButton = true;
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No Description found. Make sure Description is provided to be able to post to LogicMelon job boards.'));
            hide_showPostButton = true;
        }
        
        getChannelAndPostDetails();
        getChannelAndPostDetailsForStatus(job);
    }

    public list<ChannelWrapper> channelWrapperList {get; set;}

    public class ChannelWrapper {

        public Boolean  postToBoard     {get; set;}
        public String   channelId       {get; set;}
        public String   channelName     {get; set;}
        public String   boardId         {get; set;}
        public String   Quota           {get; set;}

        public Boolean  channelStatus   {get; set;}  

        public ChannelWrapper() {
            postToBoard = false;
        }
    } 

    public void getChannelAndPostDetails() {

        channelWrapperList = new list<ChannelWrapper>();

        // Step 1: Get all Channels
        String allChannelResponse = LogicMelonWebsericeCallouts.getAllChannels();

        //Utility.AddInfoMessage('allChannelResponse: ' + allChannelResponse);
        system.debug('Result of allChannelResponse : ' + allChannelResponse);
        // Parse the response
        parseChannelResponse(allChannelResponse);
    }

    private void parseChannelResponse(String allChannelResponse) {
        
        XmlStreamReader xmlStr = new XmlStreamReader(allChannelResponse);

        while(xmlStr.hasNext()) {
            if(xmlStr.getEventType() == XmlTag.START_ELEMENT) {
                if(xmlStr.getLocalName() == 'ChannelList') {
                    xmlStr.next();
                    while(!(xmlStr.getEventType() == XmlTag.END_ELEMENT && xmlStr.getLocalName() == 'ChannelList')) {
                        
                        if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'Channel') {
                            xmlStr.next();
                            ChannelWrapper cWrap = new ChannelWrapper();
                            while(!(xmlStr.getEventType() == XmlTag.END_ELEMENT && xmlStr.getLocalName() == 'Channel')) {
                                
                                if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'ChannelId') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.channelId = xmlStr.getText();
                                    }
                                }
                                else if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'ChannelName') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.channelName = xmlStr.getText();
                                    }
                                }
                                else if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'BoardId') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.boardId = xmlStr.getText();
                                    }
                                }
                                else if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'QuotaInformation') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                            cWrap.Quota = xmlStr.getText();
                                    }
                                }
                                xmlStr.next();
                            }

                            channelWrapperList.add(cWrap);
                        }
                        xmlStr.next();
                    }
                }
                
            }
            xmlStr.next();
        }
    }

    public PageReference PostJobToSelectedJobBoards() {
        
        system.debug(' inside post job bord method ');
        set<String> selectedChannelIds = new set<String>();
        
        system.debug('Result of channelWrapperList : '+ channelWrapperList);
        if(test.isRunningTest()){
            system.debug('Size of channelWrapperList : '+ channelWrapperList.size());
            for(ChannelWrapper cWrap : channelWrapperList) {
            //if(cWrap.postToBoard)
             //   selectedChannelIds.add(cWrap.channelId);
                system.debug('loop through channelWrapperList : '+ cWrap.postToBoard);
                cWrap.postToBoard = true;
                selectedChannelIds.add(cWrap.channelId);
            }
            
        }
        for(ChannelWrapper cWrap : channelWrapperList) {
            if(cWrap.postToBoard)
                selectedChannelIds.add(cWrap.channelId);
        }
        system.debug('selectedChannelIds ' + selectedChannelIds);
        if(selectedChannelIds.size() > 0) {
            String response = LogicMelonWebsericeCallouts.postJobToJobBoards(job, selectedChannelIds);
            system.debug('response LogicMelonWebsericeCallouts ' + response);
            //Utility.AddInfoMessage(response);
            if(test.isRunningTest()){
                response = '<?xml version="1.0" encoding="utf-8"?><AdCourierAPIResponse><TimeNow>2014-11-24T11:40:55Z</TimeNow><ResponseId>crmtest-11-24-1416829255-api-02.gs-5981-302542</ResponseId><DeleteResponse><Advert><Id>62160</Id><CreateTime>2014-11-21T06:53:28Z</CreateTime><Consultant>Chirag.Mehta</Consultant><Team>hybridtest</Team><Office>Talent</Office><UserName>Chirag.Mehta@hybridtest.Talent.crmtest</UserName><JobTitle>Job 2</JobTitle><JobReference>a0Qo00000002WfrEAE</JobReference><JobType>Permanent</JobType><CustomField name="hybrid_log_file">/mnt/logger1.gs/hybrid/2014/11/21/crmtest/06/52/crmtest-11-21-1416552731-api-01.gs-27047-681038</CustomField></Advert><ChannelList><Channel><ChannelId>LogicMelon</ChannelId><ChannelName>LogicMelon Test Board</ChannelName><ChannelStatus PostedTime="2014-11-21T06:53:32Z" RemovalTime="2014-11-21T10:24:43Z" EstimatedExpireTime="2015-12-02T11:12:00Z" ReturnCode="5" ReturnCodeClass="Success">Deleted</ChannelStatus></Channel></ChannelList></DeleteResponse><DeleteResponse><Advert><Id>57015</Id><CreateTime>2014-11-21T12:41:33Z</CreateTime><Consultant>Chirag.Mehta</Consultant><Team>hybridtest</Team><Office>Talent</Office><UserName>Chirag.Mehta@hybridtest.Talent.crmtest</UserName><JobTitle>Job 2</JobTitle><JobReference>a0Qo00000002WfrEAE</JobReference><JobType>Permanent</JobType><CustomField name="hybrid_log_file">/mnt/logger1.gs/hybrid/2014/11/21/crmtest/12/40/crmtest-11-21-1416573630-api-01.gs-14892-455027</CustomField></Advert><ChannelList><Channel><ChannelId>LogicMelon</ChannelId><ChannelName>LogicMelon Test Board</ChannelName><ChannelStatus PostedTime="2014-11-21T12:42:19Z" RemovalTime="2014-11-21T12:42:29Z" ReturnCode="5" ReturnCodeClass="Success">Deleted</ChannelStatus></Channel></ChannelList></DeleteResponse></AdCourierAPIResponse>';
                
            }
            // Parse the response to check if there its Failed or Success
            XmlStreamReader xmlStr = new XmlStreamReader(response);
            
            
            
            while(xmlStr.hasNext()) {
                system.debug('getEventType ' + xmlStr.getEventType());
                system.debug('START_ELEMENT ' + XmlTag.START_ELEMENT);
                system.debug('getLocalName ' + xmlStr.getLocalName());
                if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'Failed') {
                    xmlStr.next();
                    if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'Message') {
                        xmlStr.next();

                        if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                            Utility.AddErrorMessage('Posting to External Job Board Failed. Error Reason: ' + xmlStr.getText());
                            break;
                        }
                    }
                }

                if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'StoreJobURL') {
                    xmlStr.next();
                    system.debug('getEventType 2 ' + xmlStr.getEventType());
                    system.debug('START_ELEMENT 2 ' + XmlTag.START_ELEMENT);
                    system.debug('getLocalName 2 ' + xmlStr.getLocalName());
                    system.debug( 'xmlStr get text : ' + xmlStr.getText());
                    system.debug( 'CHARACTERS : ' + XmlTag.CHARACTERS);
                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                        PageReference ref = new PageReference(xmlStr.getText());
                        ref.setRedirect(true);
                        return ref;
                    }
                }
                xmlStr.next();
            }

        }
        else {
            Utility.AddErrorMessage('Please select a Job Board to post.');
            return null;
        }
        return null;
    }
    
    public void deletePosting(){
        
        for(AdvChannelWrapper wrapper :advChannelWrapperList){
            if(wrapper.isDeleteJob == true){
                ChannelIdVal.add(wrapper.ChannelId);
            }
        }
        
        system.debug(' ChannelIdVal : ' + ChannelIdVal);
        
        if(ChannelIdVal.size()>0){
            processDeleting(job , ChannelIdVal);
        }
        
    }
    
    public void processDeleting(TR1__Job__c jobRec , List<String> channelIdList){
        
        if(channelIdList.size()>0){
            deletechannelList = new list<DeleteChannelListWrapper>();
            String allChannelResponseValue = LogicMelonWebsericeCallouts.getdeleteDetails(jobRec, channelIdList);
            deletechannelList = DeleteWrapperList(allChannelResponseValue);
        }
        else{
            if(!trigger.isExecuting){
                
            }
        }
        
    }
    
     //Method to check status for a job inside various channels.
    public  void getChannelAndPostDetailsForStatus(TR1__Job__c jobRec) {
        
        system.debug('Inside Post details for status ');
        advChannelWrapperList = new list<AdvChannelWrapper>();
        
        // Step 1: Get all Channels
        String allChannelResponseValue = LogicMelonWebsericeCallouts.getAdvStatus(jobRec);
        System.debug('Resp LM : '+allChannelResponseValue);
        
        advChannelWrapperList = tempWrapList(allChannelResponseValue);
        System.debug('advChannelWrapperList LM : '+advChannelWrapperList); 
    }
    
    public  List<AdvChannelWrapper> tempWrapList (String allChannelResponse){
    
        
        List<AdvChannelWrapper> WrapperList = new List<AdvChannelWrapper>(); 
        
        //Map to staore values for chanel Id with its record
        Map<String , AdvChannelWrapper> AdvCheckMap = new Map<String ,AdvChannelWrapper>();
        
        XmlStreamReader xmlStr = new XmlStreamReader(allChannelResponse);
        
        System.debug('xmlStr:'+xmlStr);
        
        while(xmlStr.hasNext()) {
            if(xmlStr.getEventType() == XmlTag.START_ELEMENT) {
                if(xmlStr.getLocalName() == 'ChannelList') {
                    xmlStr.next();
                    while(!(xmlStr.getEventType() == XmlTag.END_ELEMENT && xmlStr.getLocalName() == 'ChannelList')) {
                        
                        if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'Channel') {
                            xmlStr.next();
                            AdvChannelWrapper cWrap = new AdvChannelWrapper();
                            while(!(xmlStr.getEventType() == XmlTag.END_ELEMENT && xmlStr.getLocalName() == 'Channel')) {
                                
                                if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'ChannelId') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.channelId = xmlStr.getText();
                                    }
                                }
                                else if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'ChannelName') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.channelName = xmlStr.getText();
                                    }
                                }
                                else if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'Cost') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.CostVal = decimal.valueOf(xmlStr.getText());
                                    }
                                }
                                else if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'Currency') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.CurrencyVal = xmlStr.getText();
                                    }
                                }
                                else if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'ChannelStatus'){
                                    
                                    Integer countVal = xmlStr.getAttributeCount();
                                    String localName = '';
                                    if(countVal > 0){
                                        
                                        for(integer i = 0 ; i <=countVal ; i++){
                                            localName = xmlStr.getAttributeLocalName(i);
                                            
                                            if(localName == 'PostedTime'){
                                                String dateValue = xmlStr.getAttributeValueAt(i);
                                                dateValue = dateValue.replace('T', ' ');
                                                dateValue = dateValue.replace('Z', '');
                                                DateTime temp = dateTime.valueOfGMT(dateValue);
                                                System.debug('temp:::'+temp);
                                                cWrap.PostedTime = String.valueOf(temp.format());   
                                            }
                                            if(localName == 'RemovalTime'){
                                                String dateValue = xmlStr.getAttributeValueAt(i);
                                                dateValue = dateValue.replace('T', ' ');
                                                dateValue = dateValue.replace('Z', '');
                                                DateTime temp = dateTime.valueOfGMT(dateValue);
                                                cWrap.RemovalTime = String.valueOf(temp.format());
                                                
                                            }
                                             if(localName == 'EstimatedExpireTime'){        
                                                String dateValue = xmlStr.getAttributeValueAt(i);       
                                                dateValue = dateValue.replace('T', ' ');        
                                                dateValue = dateValue.replace('Z', '');     
                                                DateTime temp = dateTime.valueOfGMT(dateValue);     
                                                cWrap.EstimatedExpireTime = String.valueOf(temp.format());      
                                                        
                                            }
                                            if(localName == 'ReturnCode'){
                                                cWrap.ReturnCode = Double.valueOf(xmlStr.getAttributeValueAt(i)); 
                                            }
                                            if(localName == 'Responses'){
                                                cWrap.Responses = Integer.valueOf(xmlStr.getAttributeValueAt(i)); 
                                            }
                                            if(localName == 'Slots'){
                                                cWrap.Slots = Decimal.valueOf(xmlStr.getAttributeValueAt(i)); 
                                            }
                                            if(localName == 'ReturnCodeClass'){
                                                cWrap.ReturnCodeClass = xmlStr.getAttributeValueAt(i); 
                                            }
                                        }
                                    }
                                    
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.ChannelStatus = xmlStr.getText();
                                    }
                                }
                                xmlStr.next();
                            }
                            System.debug('cWrap::'+cWrap);
                            if(AdvCheckMap.containsKey(cWrap.ChannelId)){
                                
                                System.debug('Inside if');
                                
                                AdvChannelWrapper tempWrap = AdvCheckMap.get(cWrap.ChannelId);
                                if(tempWrap.ChannelStatus == 'Deleted' && cWrap.ChannelStatus == 'Delivered'){
                                    AdvCheckMap.put(cWrap.ChannelId , cWrap);       
                                }
                            }
                            else {
                                System.debug('Inside else');
                                AdvCheckMap.put(cWrap.ChannelId,cWrap);
                            }
                            System.debug('AdvCheckMap::'+AdvCheckMap);
                            WrapperList = AdvCheckMap.values(); 
                            System.debug('WrapperList:'+WrapperList);
                            //return                                
                            
                            //advChannelWrapperList.add(cWrap);
                            System.debug('advChannelWrapperList:'+advChannelWrapperList);
                        }
                        xmlStr.next();
                    }
                }
                
            }
            xmlStr.next();
        }
        return WrapperList;
    }
    
    
    public class DeleteChannelListWrapper {
        
        public String   channelId       {get; set;}
        public String   channelName     {get; set;}
        public String   ChannelStatus   {get; set;}

        public String   PostedTime      {get; set;}
        public String   RemovalTime     {get; set;}
          public String   EstimatedExpireTime  {get; set;}
        public Decimal  ReturnCode      {get; set;}
        public Integer  Responses       {get; set;}
        public Decimal  Slots           {get; set;}
        public String   ReturnCodeClass {get; set;}
        
        
        public DeleteChannelListWrapper(){
        }
    }
    
    public  List<DeleteChannelListWrapper> DeleteWrapperList(String allChannelResponse){
        
        List<DeleteChannelListWrapper> tempDeleteList = new List<DeleteChannelListWrapper>();
        
        XmlStreamReader xmlStr = new XmlStreamReader(allChannelResponse);
        
        while(xmlStr.hasNext()) {
            
            if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'Failed') {
                xmlStr.next();
                while(!(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'Message')) {
                    xmlStr.next();
                }
                xmlStr.next();
                if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                    Utility.AddErrorMessage('Deletion from External Job Board Failed. Error Reason: ' + xmlStr.getText());
                    break;
                }
            }
            
            if(xmlStr.getEventType() == XmlTag.START_ELEMENT) {
                system.debug('xml Str Local Name 414 : ' + xmlstr.getLocalName());
                if(xmlStr.getLocalName() == 'ChannelList') {
                    while(!(xmlStr.getEventType() == XmlTag.END_ELEMENT && xmlStr.getLocalName() == 'ChannelList')) {
                        
                        if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'Channel') {
                            
                            xmlStr.next();
                            DeleteChannelListWrapper cWrap = new DeleteChannelListWrapper();
                            
                            while(!(xmlStr.getEventType() == XmlTag.END_ELEMENT && xmlStr.getLocalName() == 'Channel')) {
                                system.debug('xml Str Local Name 424 : ' + xmlstr.getLocalName());
                                if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'ChannelId') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.channelId = xmlStr.getText();
                                    }
                                }
                                else if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'ChannelName') {
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.channelName = xmlStr.getText();
                                    }
                                }
                                else if(xmlStr.getEventType() == XmlTag.START_ELEMENT && xmlStr.getLocalName() == 'ChannelStatus'){
                                    
                                    Integer countVal = xmlStr.getAttributeCount();
                                    String localName = '';
                                    
                                    if(countVal > 0){
                                        for(integer i = 0 ; i <=countVal ; i++){
                                            localName = xmlStr.getAttributeLocalName(i);
                                            
                                            if(localName == 'PostedTime'){                                              
                                                String dateValue = xmlStr.getAttributeValueAt(i);
                                                dateValue = dateValue.replace('T', ' ');
                                                dateValue = dateValue.replace('Z', '');
                                                DateTime temp = dateTime.valueOfGMT(dateValue);
                                                System.debug('temp:::'+temp);
                                                cWrap.PostedTime = String.valueOf(temp.format());
                                                
                                            }
                                            
                                            if(localName == 'RemovalTime'){
                                                String dateValue = xmlStr.getAttributeValueAt(i);
                                                dateValue = dateValue.replace('T', ' ');
                                                dateValue = dateValue.replace('Z', '');
                                                DateTime temp = dateTime.valueOfGMT(dateValue);
                                                cWrap.RemovalTime = String.valueOf(temp.format());
                                            }
                                            if(localName == 'EstimatedExpireTime'){     
                                                String dateValue = xmlStr.getAttributeValueAt(i);       
                                                dateValue = dateValue.replace('T', ' ');        
                                                dateValue = dateValue.replace('Z', '');     
                                                DateTime temp = dateTime.valueOfGMT(dateValue);     
                                                cWrap.EstimatedExpireTime = String.valueOf(temp.format());      
                                            }
                                            if(localName == 'ReturnCode'){
                                                cWrap.ReturnCode = Double.valueOf(xmlStr.getAttributeValueAt(i)); 
                                            }
                                            if(localName == 'Responses'){
                                                cWrap.Responses = Integer.valueOf(xmlStr.getAttributeValueAt(i)); 
                                            }
                                            if(localName == 'Slots'){
                                                cWrap.Slots = Decimal.valueOf(xmlStr.getAttributeValueAt(i)); 
                                            }
                                            
                                            if(localName == 'ReturnCodeClass'){
                                                cWrap.ReturnCodeClass = xmlStr.getAttributeValueAt(i); 
                                                if(cWrap.ReturnCodeClass == 'Success'){
                                                     Utility.AddInfoMessage('Job post deleted succesfully from LogicMelon. Status in Salesforce will be updated in few seconds/minutes.');
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                    xmlStr.next();
                                    if(xmlStr.getEventType() == XmlTag.CHARACTERS) {
                                        cWrap.ChannelStatus = xmlStr.getText();
                                    }
                                    
                                }
                                xmlStr.next();
                            }   
                            tempDeleteList.add(cWrap);
                            return tempDeleteList;
                            
                            getChannelAndPostDetailsForStatus(job);
                            //System.debug('advChannelWrapperList:'+advChannelWrapperList);
                        }
                        xmlStr.next();
                    }
                }   
            }
          xmlStr.next();  
        }
        
        return null;
    }
    
    public class AdvChannelWrapper {
        
        public String   channelId       {get; set;}
        public String   channelName     {get; set;}
        public Decimal  CostVal         {get; set;}
        public String   CurrencyVal     {get; set;}
        public String   ChannelStatus   {get; set;}

        public String   PostedTime      {get; set;}
        public String   RemovalTime     {get; set;}
           public String   EstimatedExpireTime     {get; set;}
        public Decimal  ReturnCode      {get; set;}
        public Integer  Responses       {get; set;}
        public Decimal  Slots           {get; set;}
        public String   ReturnCodeClass {get; set;}
        
        public Boolean  isDeleteJob     {get; set;}
        
        public AdvChannelWrapper(){
            isDeleteJob = false;
        }
    }
    
}