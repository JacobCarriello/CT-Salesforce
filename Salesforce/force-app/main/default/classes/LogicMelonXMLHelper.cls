public with sharing class LogicMelonXMLHelper {
    
    // Create XML from Label and Value
    public static String createXMLRow(String label, String value) {
        String str = '<' + label + '>';
        str += String.isNotBlank(value) ? value : '';
        str += '</' + label + '>';

        return str;
    }

    public static String createXMLRow(String label, Decimal value) {
        String strValue = (value == null) ? '' : String.valueOf(value);
        return createXMLRow(label, strValue);
    }

    public static String getAccountXML() {
        String str = '<Account>';
        String UserName;
        
        User usr = [Select LogicMenon_UserName__c from User where Id = :UserInfo.getUserId()];
        if(String.isNotBlank(usr.LogicMenon_UserName__c)) {
            str += createXMLRow('UserName', usr.LogicMenon_UserName__c);
            str += createXMLRow('Password', Label.LogicMelon_Password);
        }
        else {
            Utility.addErrorMessage('LogicMelon Username not defined for the user.');
            return null;
        }
        str += '</Account>';

        return str;
    }
    

    // Get the Config Options
    public static String getConfigOptions(TR1__Job__c job) {
        String str = '';
        str += createXMLRow('RedirectOnCompletion', URL.getSalesforceBaseUrl().toExternalForm() +'/' +job.id);
        str += createXMLRow('ReturnStoreURL', 'True');
        str = createXMLRow('Options', str);
        str = createXMLRow('Config', str);
        return str;
    }
 
    public static String addStartingXMLString() {
        return '<?xml version="1.0" encoding="utf-8" ?>';
    }

    public static String createXMLForChannelList() {

        String ChannelListXML = '';

        ChannelListXML += createXMLRow('Method', 'ListChannels');
        ChannelListXML += getAccountXML();
        ChannelListXML = createXMLRow('AdCourierAPI', ChannelListXML);
        ChannelListXML = addStartingXMLString() + ChannelListXML;

        return ChannelListXML;
    }
    
    // Get the XML with API Key
    public static String getAPIKeyXML() {
        return createXMLRow('APIKey', getApiKey());
    }
    
     // Function to get the API Key
    public static String getAPIKey() {
        return Label.LogicMelon_API_Key.trim();
    }
    
     // Get Times XML
    public static String getTimeDetails (){
        String strn = '<Times>';
        strn += createXMLRow('TimeFrom' , '2014-11-20T06:15:00Z');
        strn += createXMLRow('TimeTo' , '2014-12-20T06:15:00Z');
        strn += '</Times>' ;
        
        return strn;
    }
    
    // Get Times XML
    public static String getTimeFromDetails (){
        String strn = '<Times>';
        strn += createXMLRow('TimeFrom' , '2014-11-20T06:15:00Z');
        strn += '</Times>' ;
        
        return strn;
    }
    
    public static String createXMLForDeletion(TR1__Job__c job ,List<String> channelId){
        
        String AdvCheckXML = '';
        String XMLString   = '';
        String ChannelVal  = '';
        
        AdvCheckXML  += createXMLRow('Method' , 'Delete');
        AdvCheckXML  += getAPIKeyXML();
        AdvCheckXML  += getAccountXML();
        
        XMLString    += createXMLRow('JobReference', job.TR1__Job_Number__c);
        XMLString    += getTimeFromDetails();
        XMLString    =  createXMLRow('Filter', XMLString); 
        
        System.debug('channelId::::'+channelId);
        
        for(String val : channelId){
            String ChanelIdval = createXMLRow('ChannelId', val);
            ChannelVal  +=  createXMLRow('Channel', ChanelIdval);
        }
        
        ChannelVal  =  createXMLRow('ChannelList', ChannelVal);    
        ChannelVal  = XMLString + ChannelVal;  
        AdvCheckXML = AdvCheckXML + createXMLRow('Options', ChannelVal);
        AdvCheckXML = createXMLRow('AdCourierAPI', AdvCheckXML);
        AdvCheckXML = addStartingXMLString() + AdvCheckXML;
        
        return AdvCheckXML;
    }
    
    public static String createXMLForAdvCheck(TR1__Job__c job) {
        
        String AdvCheckXML = '';
        String XMLString   = '';
        
        AdvCheckXML  += createXMLRow('Method', 'AdvertCheck');
        AdvCheckXML  += getAPIKeyXML();
        AdvCheckXML  += getAccountXML();
        XMLString    += createXMLRow('JobReference', job.TR1__Job_Number__c);
        XMLString    += getTimeDetails();
        XMLString    =  createXMLRow('Filter', XMLString); 
        AdvCheckXML  = AdvCheckXML + createXMLRow('Options', XMLString)  ;
        AdvCheckXML  = createXMLRow('AdCourierAPI', AdvCheckXML);
        AdvCheckXML  = addStartingXMLString() + AdvCheckXML ;
        
        return AdvCheckXML ;
    }
    
    // Create XML for Posting a Job to External Channel Ids
    public static String createXMLForPostingJob(TR1__Job__c job, set<String> channelIds) {

        String ExportJobXML = '';

        ExportJobXML += createXMLRow('Method', 'Export');
        //ExportJobXML += getAPIKeyXML();
        ExportJobXML += getAccountXML();

        // Add Config Details
        ExportJobXML += getConfigOptions(job); 

        // Create Advert Data
        ExportJobXML += '<Advert>';

        String jobType = 'Permanent';
        if(job.RecordType.Name == 'Consulting')
            jobType = 'Contract';

        for(LogicMelonXMLTag__c lmAdvert : LogicMelonXMLTag__c.getAll().values()){
            if(String.IsNotBlank(lmAdvert.RecordTypeName__c) && lmAdvert.RecordTypeName__c == jobType) {
                String str = lmAdvert.StartTag__c;
                if(String.IsNotBlank(lmAdvert.FieldAPI__c)) {
                    if(job.get(lmAdvert.FieldAPI__c) != null)
                        str += string.valueOf(job.get(lmAdvert.FieldAPI__c)).replaceAll('(</{0,1}[^>]+>)', '');
                    else
                        str += '';    
                }
                else if(lmAdvert.DefaultValue__c != null)
                    str += lmAdvert.DefaultValue__c.replace('&','%26');    
                else
                    str += '';    
                str += lmAdvert.EndTag__c;
                ExportJobXML += str;
            }
        }
        ExportJobXML += '</Advert>';    

        ExportJobXML += '<ChannelList>';
        for(String channelId : channelIds) {
            ExportJobXML += '<Channel>';
            ExportJobXML += createXMLRow('ChannelId', channelId);
            ExportJobXML += '</Channel>';
        }
        ExportJobXML += '</ChannelList>';

        ExportJobXML = createXMLRow('AdCourierAPI', ExportJobXML);
        ExportJobXML = addStartingXMLString() + ExportJobXML;
        return ExportJobXML;
    }
}