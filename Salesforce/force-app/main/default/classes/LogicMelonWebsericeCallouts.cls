global with sharing class LogicMelonWebsericeCallouts {
    
    // Webservice function to Send Offer JSON
    webservice static String makeWebserviceCall(String xmlBody) {
        try {
            Http h = new Http();
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            
            // Set Headers
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Endpoint
            req.setEndpoint(Label.LogicMelon_EndpointURL);
            // Set method
            req.setMethod('POST');
            
            // Set Body
            req.setBody(xmlBody);
            system.debug('FeedBody: '+xmlBody);
            // Set Timeout
            req.setTimeOut(60000);
            // Send the request, and return a response
            HttpResponse res = h.send(req);

            system.debug('REspinse: ' + res);
            system.debug('REspinse: ' + res.toString());

            for(String key : res.getHeaderKeys()) {
                if(String.isNotBlank(key))
                    system.debug(key + ' - ' + res.getHeader(key));
            }
            
            return res.getBody();
        }
        catch(Exception e) {
            system.debug('ERROR: ' + e.getMessage());
        }
        return null;
    }


    public static String getAllChannels() {

        String channelXML = LogicMelonXMLHelper.createXMLForChannelList();
        system.debug('Channel list: '+channelXML);
        //Utility.AddInfoMessage('channelXML: ' + channelXML);

        //String responseBody = makeWebserviceCall(channelXML);
        String responseBody = '';
        if(!test.isRunningTest()){
            responseBody = makeWebserviceCall(channelXML);
        }
        else{
            responseBody = '<?xml version="1.0" encoding="utf-8"?><AdCourierAPIResponse><TimeNow>2014-11-24T10:24:00Z</TimeNow><ResponseId>crmtest-11-24-1416824640-api-01.gs-13895-950138</ResponseId><ListChannelsResponse><ChannelList><Channel><ChannelId>LogicMelon</ChannelId><ChannelName>LogicMelon Test Board</ChannelName><BoardId>999</BoardId><FreeToPost>true</FreeToPost></Channel><Channel><ChannelId>jobscabi</ChannelId><ChannelName>Jobs Cabinet (Test Board)</ChannelName><BoardId>2336</BoardId><FreeToPost>true</FreeToPost></Channel></ChannelList></ListChannelsResponse></AdCourierAPIResponse>';
            
        }

        System.debug('Response Bdoy: ' + responseBody);

        return responseBody;

    }
    
    public static String getAdvStatus (TR1__Job__c job) {
        
        String AdvStatusXML = LogicMelonXMLHelper.createXMLForAdvCheck(job);
        System.debug('Status val :'+AdvStatusXML);
        
        String responseBody = '';
        if(!test.isRunningTest()){
            responseBody = makeWebserviceCall(AdvStatusXML);
        }
        else {
            responseBody = '<?xml version="1.0" encoding="utf-8"?><AdCourierAPIResponse><TimeNow>2014-11-24T10:31:09Z</TimeNow><ResponseId>crmtest-11-24-1416825069-api-02.gs-7731-510186</ResponseId><AdvertCheckResponse><Advert><Id>28118</Id><CreateTime>2014-11-24T06:05:09Z</CreateTime><Consultant>Chirag.Mehta</Consultant><Team>hybridtest</Team><Office>Talent</Office><UserName>Chirag.Mehta@hybridtest.Talent.crmtest</UserName><JobTitle>Job 2</JobTitle><JobReference>a0Qo00000002WfrEAE</JobReference><JobType>Permanent</JobType><Location_Id>43379</Location_Id><Industry>Sales</Industry><SalaryFrom>25</SalaryFrom><SalaryTo>35</SalaryTo><SalaryCurrency>GBP</SalaryCurrency><SalaryPer>hour</SalaryPer><SalaryBenefits></SalaryBenefits><Skills></Skills><JobDescription>&lt;p&gt;test&lt;/p&gt;</JobDescription></Advert><Contact><ContactName>Chirag Mehta</ContactName><ContactEmail>cmehta@talentrover.com</ContactEmail><ContactTelephone>118118</ContactTelephone></Contact><ChannelList><Channel><ChannelId>jobscabi</ChannelId><ChannelName>Jobs Cabinet (Test Board)</ChannelName><ChannelStatus PostedTime="2014-11-24T06:18:53Z" RemovalTime="2014-12-01T06:18:53Z" AdvertURL="http://www.jobscabi.net/jobs/view/45841" Responses="0" ReturnCode="0" ReturnCodeClass="Success">Delivered</ChannelStatus></Channel></ChannelList></AdvertCheckResponse></AdCourierAPIResponse>';
        }
        System.debug('Response Body :'+responseBody);
        
        return responseBody;
        
    }
    
    public static String getdeleteDetails (TR1__Job__c job , List<String> channelIDList) {
        
        String AdvStatusXML = LogicMelonXMLHelper.createXMLForDeletion(job, channelIDList);
        System.debug('Status val :'+AdvStatusXML);
        
        String responseBody = '';
        
        if(!test.isRunningTest()){
            responseBody = makeWebserviceCall(AdvStatusXML);    
        }
        else {
            responseBody = '<?xml version="1.0" encoding="utf-8"?><AdCourierAPIResponse><TimeNow>2014-11-24T11:40:55Z</TimeNow><ResponseId>crmtest-11-24-1416829255-api-02.gs-5981-302542</ResponseId><DeleteResponse><Advert><Id>62160</Id><CreateTime>2014-11-21T06:53:28Z</CreateTime><Consultant>Chirag.Mehta</Consultant><Team>hybridtest</Team><Office>Talent</Office><UserName>Chirag.Mehta@hybridtest.Talent.crmtest</UserName><JobTitle>Job 2</JobTitle><JobReference>a0Qo00000002WfrEAE</JobReference><JobType>Permanent</JobType><CustomField name="hybrid_log_file">/mnt/logger1.gs/hybrid/2014/11/21/crmtest/06/52/crmtest-11-21-1416552731-api-01.gs-27047-681038</CustomField></Advert><ChannelList><Channel><ChannelId>LogicMelon</ChannelId><ChannelName>LogicMelon Test Board</ChannelName><ChannelStatus PostedTime="2014-11-21T06:53:32Z" RemovalTime="2014-11-21T10:24:43Z" ReturnCode="5" ReturnCodeClass="Success">Deleted</ChannelStatus></Channel></ChannelList></DeleteResponse><DeleteResponse><Advert><Id>57015</Id><CreateTime>2014-11-21T12:41:33Z</CreateTime><Consultant>Chirag.Mehta</Consultant><Team>hybridtest</Team><Office>Talent</Office><UserName>Chirag.Mehta@hybridtest.Talent.crmtest</UserName><JobTitle>Job 2</JobTitle><JobReference>a0Qo00000002WfrEAE</JobReference><JobType>Permanent</JobType><CustomField name="hybrid_log_file">/mnt/logger1.gs/hybrid/2014/11/21/crmtest/12/40/crmtest-11-21-1416573630-api-01.gs-14892-455027</CustomField></Advert><ChannelList><Channel><ChannelId>LogicMelon</ChannelId><ChannelName>LogicMelon Test Board</ChannelName><ChannelStatus PostedTime="2014-11-21T12:42:19Z" RemovalTime="2014-11-21T12:42:29Z" ReturnCode="5" ReturnCodeClass="Success">Deleted</ChannelStatus></Channel></ChannelList></DeleteResponse></AdCourierAPIResponse>';         
        }
        
        System.debug('Response Body :'+responseBody);
        
        return responseBody;
        
    }
    
    // Get Channels for a specific Job
    public static String getChannelStatusForAJob() {

        return '';
    }

    // Post a Job to a external Site
    public static String postJobToJobBoards(TR1__Job__c job, set<String> channelIds) {

        String ExportJobXML = LogicMelonXMLHelper.createXMLForPostingJob(job, channelIds);
        system.debug(' ExportJobXML LM ' + ExportJobXML);
        //Utility.AddInfoMessage('ExportJobXML: ' + ExportJobXML);

        String responseBody = makeWebserviceCall(ExportJobXML);
        system.debug(' responseBody  LM ' + responseBody);
        
        return responseBody;
    }
    
    
    
}