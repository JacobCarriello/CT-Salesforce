public with sharing class Utility {
  
  public static final string CONSULTING = 'Consulting';
  
  
  // CONSULTING Record Type Id
  public static final String CONSULTING_RTID = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
  
//  public static final String EDUCATION_CANDIDATE_RTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Education Candidate Contact').getRecordTypeId();
//  public static final String CONSTRUCTION_CANDIDATE_RTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Construction Candidate Contact').getRecordTypeId();
   
  // Set containing specific User profile names
  public static set<String> profileName = new set<String>{
    'EP Education Sales Managers', 
    'EP Construction Sales Managers',
    'EP Resource Directors', 
    'EP Education Team Leaders', 
    'EP Construction Team Leaders' , 
    'EP System Admin',
    'System Admin'
  };
  
  
  public static String getDay(Integer day) {
    if(day == 0)
      return 'SUN';
    else if(day == 1)
      return 'MON';
    else if(day == 2)
      return 'TUE';
    else if(day == 3)
      return 'WED';
    else if(day == 4)
      return 'THU';
    else if(day == 5)
      return 'FRI';
    else if(day == 6)
      return 'SAT';
    return 'SUN';
  }
  
  public static String getFullDay(Integer day) {
    if(day == 0)
      return 'Sunday';
    else if(day == 1)
      return 'Monday';
    else if(day == 2)
      return 'Tuesday';
    else if(day == 3)
      return 'Wednesday';
    else if(day == 4)
      return 'THursday';
    else if(day == 5)
      return 'Friday';
    else if(day == 6)
      return 'Saturday';
    return 'Sunday';
  }
  
  public static String getMonth(Integer month) {
    if(month == 1)
      return 'Jan';
    else if(month == 2)
      return 'Feb';
    else if(month == 3)
      return 'Mar';
    else if(month == 4)
      return 'Apr';
    else if(month == 5)
      return 'May';
    else if(month == 6)
      return 'Jun';
    else if(month == 7)
      return 'Jul';
    else if(month == 8)
      return 'Aug';
    else if(month == 9)
      return 'Sep';
    else if(month == 10)
      return 'Oct';
    else if(month == 11)
      return 'Nov';
    else if(month == 12)
      return 'Dec';
    return 'Jan';
  }
  
  public static String addTableRow(String label, String value) {
    String tooltipContent   = '<tr>';
        tooltipContent += '<td align="right" width="35%" style="padding-top:3px;"><b>' + label + ': </b></td>';
        tooltipContent += '<td style="padding-left:5px;padding-top:3px;">' + value + '</td>';
        tooltipContent += '</tr>';
    return tooltipContent;
  }
  public static String addTableRow(String label, Sobject value) {
    String tooltipContent   = '<tr>';
        tooltipContent += '<td align="right" width="35%" style="padding-top:3px;"><b>' + label + ': </b></td>';
        tooltipContent += '<td style="padding-left:5px;padding-top:3px;">' + value + '</td>';
        tooltipContent += '</tr>';
    return tooltipContent;
  }
  
  public static String addTableRow(String label, Decimal value) {
    String valueStr = '';
    if(value != null)
      valueStr = String.valueOf(value);
    return addTableRow(label, valueStr);
  }
  
  public static String addTableRow(String label, Date value) {
    String tooltipContent   = '<tr>';
        tooltipContent += '<td align="right" width="35%" style="padding-top:3px;"><b>' + label + ': </b></td>';
        tooltipContent += '<td style="padding-left:5px;padding-top:3px;">' + value + '</td>';
        tooltipContent += '</tr>';
    return tooltipContent;
  }
  
    // Returns date formatted as DD/MM/YYYY
    public static String DateFormat(Date dt) {
      String DateFormat = '';
      if(dt != null) { 
        DateFormat = String.valueOf(String.valueOf(dt.day()) + '/' + dt.month()) + '/' + String.valueOf(dt.year()); 
      }
      return DateFormat;
    }
    // Returns date formatted as MM/DD/YYYY
    public static String formatDate(Date dt) {
      String formattedDate = '';
      if(dt != null) { 
        //formattedDate = dt.format(); 
        formattedDate = String.valueOf(dt.month()) + '/' + String.valueOf(dt.day()) + '/' + String.valueOf(dt.year()); 
      }
      return formattedDate;
    }
     // Returns date formatted as YYYY/MM/DD
    public static Date formatedDate(String dt) {
      Date formatedDate ; 
      String[] dates = dt.split('/');
      if(String.isNotBlank(dt) != null) {  
        formatedDate = date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[1]), Integer.valueOf(dates[0]));
      }
      return formatedDate;
    }
    
    
    // Check if the User is Portal Enabled or not
    public static boolean isInternalUser() {
      try {
        return String.isBlank(Site.getName());
      }
      catch(Exception e) {}
      return false;
    }
    
    // check the profile Name of the user
    public static boolean isEducationProfile(){
      try {
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name; 
        if(usrProfileName.contains('Education')){
          return true;
        }
        else if(usrProfileName.Contains('Construction')){ 
          return false;
        } 
      }
      catch(Exception e) {}
      return null;
    }
    
    public static String currentUserProfileName { 
      get {
        if(currentUserProfileName == null)
          currentUserProfileName = [Select Name from Profile where Id=:userinfo.getProfileId()].Name;
        return currentUserProfileName;
      }
      private set;
    }
    
    
    // to generate formatted query string for a multi picklist field value
    public static String listToFormattedMultiPicklistString(List<String> strList) {
      string queryStr = '';
      for(String spec : strList){
        queryStr += '\'' + escapeSingleQuotes(spec) + '\',';
      }
      queryStr = queryStr.subString(0, queryStr.length() - 1);
      queryStr = '(' + queryStr + ')';  
      return queryStr;          
    }    
     
       // to generate formatted query string for a multi picklist field value
    public static String listToFormattedMultiPicklistStringSemi(List<String> strList) {
      string queryStr = '';
      for(String spec : strList){
        queryStr += '\'' + escapeSingleQuotes(spec) + '\';';
      }
      queryStr = queryStr.subString(0, queryStr.length() - 1);
      queryStr = '(' + queryStr + ')';  
      return queryStr;          
    }
  
   
  
  public static Map<String, String> colorStsMap = new Map<String, String> {
        'Booked'             => 'redColorStyle',
        'Holiday'             => 'blueColorStyle',
        'Unknown'             => 'grayColorStyle',
        'Working for Another Agency'   => 'orangeColorStyle',
        'Available'           => 'greenColorStyle',
        'AM'               => 'greenColorStyle',
        'PM'               => 'greenColorStyle',
        'Full Day'             => 'greenColorStyle',
        'Sick'              => 'peachColorStyle',
        'Interview'           => 'orangeColorStyle'
    }; 
    
    
  /* VF UTIL FUNCTIONS */
  public static void AddInfoMessage( String s) {   
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.INFO, s));
    }

    public static void AddWarningMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.WARNING, s));
    }

    public static void AddConfirmMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, s));
    }

    public static void AddErrorMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.ERROR, s));
    }

    public static void AddFatalMessage( String s) {
        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.FATAL, s));
    }

    // Utility method to check for specifc page message in apex pages
    public static Boolean hasMessage( String pageMessage) {
        if ( ApexPages.hasMessages() ) {
            for ( ApexPages.Message msg : ApexPages.getMessages()) {
                if ( msg.getDetail().contains( pageMessage)) {
                    return true;
                }
            }
        }

        return false;
    }
    
    // Returns the Page parameter if present.
    public static String getPageParameter(String param) {
        if (ApexPages.currentPage().getParameters().containsKey(param)) {
          return escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get(param));  //.replace('%2F', '')
        }
        return null;
    }

    public static String escapeSingleQuotes(String param) {
      String stringToReturn;
        if (param != null) stringToReturn = String.escapeSingleQuotes(param);
          return stringToReturn;
    }
    
    /* VF UTIL FUNCTIONS - END */
}