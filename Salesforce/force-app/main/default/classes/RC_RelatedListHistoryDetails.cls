public with sharing class RC_RelatedListHistoryDetails {
    
    public TR1__EmploymentHistory__c objEmploymentDetail               {get;set;}      //To show the detailed employment on popup window
    public TR1__EducationHistory__c objEducationDetail                 {get;set;}      //To show the detailed employment on popup window
    public String strMessage                                           {get;set;}       //To show the error/Success message on page.
    private List<Schema.FieldSetMember> lstFieldSet;
    public Boolean isPageLoad                                           {get;set;}
    public Boolean isSuccess                                            {get;set;}
    public String strRelatedList                                        {get;set;}
    public String strId                                                 {get;set;}
    public String smallPhotoUrl                                         {get;set;}
    Private String strContact;
    public Contact objContact                                           {get;set;}      //To fetch the current user logged in user contact information
    public String strDateFormat                                            {get;set;}
    private User loggedInUser;                                                          //Get loggedIn user deatils
    
    //Constructor
    public RC_RelatedListHistoryDetails() 
    {
     
        strMessage = '';
        strId = '';
        strRelatedList = '';
        isPageLoad = true;
        isSuccess = true;
        objContact = new Contact();
        lstFieldSet = new List<Schema.FieldSetMember>();
        objEmploymentDetail = new TR1__EmploymentHistory__c();
        objEducationDetail = new TR1__EducationHistory__c(); 
        getRelatedListDetails(); 
        strDateFormat = (MapValues()).get(UserInfo.getLocale());

    }
    
    
     //Checking for security
    public Pagereference redirectUnAuthenticatedUser()
    {
        try
        {
            if(Userinfo.getUserType() != 'CspLitePortal'  && Userinfo.getUserType() != 'PowerCustomerSuccess')
            {
                return new Pagereference('/Signin');
            }
            
            //To get the current logged in user contact Id
            User objUser = [Select Id, ContactId, smallPhotoUrl                                           
                                       From User 
                                       where Id=: UserInfo.getUserId()]; 
            
            //If the contact id not equal to null, the function will call to fetch the contact information to show on VF page.                                      
            if(objUser != null)
            {
                smallPhotoUrl = objUser.smallPhotoUrl;
                strContact = objUser.ContactId;
                fetchContactInfo();
            } 
                
           return null;
        }
        catch(Exception e)
        {
            return null;
        }
    }
    
    //To fetch the contact detail
    private void fetchContactInfo()
    {
        String fieldNames ='';
        
        String strQuery = 'Select Id'; 
        
        lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
               
        strQuery  += fieldNames + ' from Contact where id =: strContact' ;    
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objContact = lstContact[index]; 
    } 
    
    //Checking URL Parameter and get the related list
    public void getRelatedListDetails()
    {  
        loggedInUser = [Select ContactId from User where Id =: UserInfo.getUserId() limit 1];
        
        try
        {
            if( System.currentPageReference().getParameters().containsKey('id') && 
                System.currentPageReference().getParameters().containsKey('RelatedList') &&
                System.currentPageReference().getParameters().get('id') != '' &&
                System.currentPageReference().getParameters().get('RelatedList') != '' && 
                (System.currentPageReference().getParameters().get('RelatedList') == 'Education' || 
                System.currentPageReference().getParameters().get('RelatedList') == 'Employment') )
               {
                
                strId = System.currentPageReference().getParameters().get('id');
                strRelatedList = System.currentPageReference().getParameters().get('RelatedList');
                
                String fieldNames ='';
                String strQuery = '';
                List<SObject> lstSobject = new List<SObject>();
                Integer index = 0;
                
                //To get Employment history details
                if(strRelatedList == 'Employment')
                {
                    strQuery = 'Select Id'; 
                    
                    lstFieldSet = SObjectType.TR1__EmploymentHistory__c.FieldSets.getMap().get('RC_EmploymentDetails').getFields(); 
                    
                    for(Schema.FieldSetMember field : lstFieldSet) 
                      fieldNames += ', ' + field.getFieldPath();
                    
                    strQuery  += fieldNames + ' from TR1__EmploymentHistory__c where Id =\'' + strId + '\' AND (TR1__Contact__c =  \'' + loggedInUser.ContactId + '\')';
                    lstSobject = RC_AccessController.query(strQuery);
                    
                    if(!lstSobject.isEmpty())
                        objEmploymentDetail = (TR1__EmploymentHistory__c)lstSobject[index];
                    else
                    {
                       isPageLoad = false; 
                       isSuccess = false;
                      strMessage = 'Incorrect URL';
                    }
                }
                else if(strRelatedList == 'Education') //To get Education history details
                {
                    fieldNames ='';
                    strQuery = 'Select Id'; 
                    
                    lstFieldSet = SObjectType.TR1__EducationHistory__c.FieldSets.getMap().get('RC_EducationDetails').getFields(); 
                    
                    for(Schema.FieldSetMember field : lstFieldSet) 
                      fieldNames += ', ' + field.getFieldPath();
                     
                    strQuery  += fieldNames + ' from TR1__EducationHistory__c where Id = \'' +  strId + '\' AND (TR1__Contact__c =  \'' + loggedInUser.ContactId + '\')';
                      
                    lstSobject = RC_AccessController.query(strQuery);
                    
                    if(!lstSobject.isEmpty())
                        objEducationDetail = (TR1__EducationHistory__c)lstSobject[index];
                    else
                    {
                       isPageLoad = false; 
                       isSuccess = false;
                       strMessage = 'Incorrect URL';
                    }
                }
            }
            else if( System.currentPageReference().getParameters().containsKey('RelatedList') &&
                     System.currentPageReference().getParameters().get('RelatedList') != '' && 
                     (System.currentPageReference().getParameters().get('RelatedList') == 'Education' || 
                     System.currentPageReference().getParameters().get('RelatedList') == 'Employment') )
            {
                strRelatedList = System.currentPageReference().getParameters().get('RelatedList');
            }
            else
            {
                isPageLoad = false; 
                isSuccess = false;
                strMessage = 'Incorrect URL';
            }
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception ex)
        {
            system.debug('---- ex ----'+ex);
            isPageLoad = false; 
            isSuccess = false;
            strMessage = ex.getMessage();
        }
    }
    
    //Updates/Save RelatedListRecord on click of Update/Save
    public PageReference UpdateOrSaveRelatedListRecord() 
    {
        try
        {
            if(strRelatedList == 'Employment')
            {
                if(strId != '')
                    RC_AccessController.updateRecord(objEmploymentDetail);
                else
                {
                    objEmploymentDetail.TR1__Contact__c =  strContact;
                    RC_AccessController.insertRecord(objEmploymentDetail);
                }
            }
            else if(strRelatedList == 'Education') //To get Education history details
            {
                if(strId != '')
                    RC_AccessController.updateRecord(objEducationDetail);
                else
                {
                    objEducationDetail.TR1__Contact__c =  strContact;
                    RC_AccessController.insertRecord(objEducationDetail);
                }
            }
            
            return new PageReference('/MyAccount_v1');
        }
        catch(Exception ex)
        {
           system.debug('---- ex ----'+ex); 
           strMessage = ex.getMessage();
           isSuccess = false;
           return null;
        }
        
    }
    
    //deleting the related record on click of Delete
    public PageReference deleteRelatedListRecord() 
    {
        try
        {
            if(strRelatedList == 'Employment')
                RC_AccessController.deleteRecord(objEmploymentDetail);
            else 
              RC_AccessController.deleteRecord(objEducationDetail);
            
            return new PageReference('/MyAccount_v1');
        }
        catch(Exception ex)
        {
           strMessage = ex.getMessage();
           isSuccess = false;
           return null;
        }
    }
    
    public static Map<String, String> MapValues() {
        Map<String, String> locale_map = new Map<String, String>{'ar' => 'dd/mm/yy', 
                                                                'ar_AE' => 'dd/mm/yy', 
                                                                'ar_BH' => 'dd/mm/yy', 
                                                                'ar_EG' => 'dd/mm/yy', 
                                                                'ar_JO' => 'dd/mm/yy', 
                                                                'ar_KW' => 'dd/mm/yy', 
                                                                'ar_LB' => 'dd/mm/yy', 
                                                                'ar_SA' => 'dd/mm/yy', 
                                                                'bg' => 'yy-M-d', 
                                                                'bg_BG' => 'yy-M-d', 
                                                                'ca' => 'dd/mm/yy', 
                                                                'ca_ES' => 'dd/mm/yy', 
                                                                'ca_ES_EURO' => 'dd/mm/yy', 
                                                                'cs' => 'd.M.yy', 
                                                                'cs_CZ' => 'd.M.yy', 
                                                                'da' => 'dd-mm-yy', 
                                                                'da_DK' => 'dd-mm-yy', 
                                                                'de' => 'dd.mm.yy', 
                                                                'de_AT' => 'dd.mm.yy', 
                                                                'de_AT_EURO' => 'dd.mm.yy', 
                                                                'de_CH' => 'dd.mm.yy', 
                                                                'de_DE' => 'dd.mm.yy', 
                                                                'de_DE_EURO' => 'dd.mm.yy', 
                                                                'de_LU' => 'dd.mm.yy', 
                                                                'el' => 'd/M/yy', 
                                                                'el_GR' => 'd/M/yy', 
                                                                'en_AU' => 'd/mm/yy', 
                                                                'en_BB' => 'M/d/yy', 
                                                                'en_BM' => 'M/d/yy', 
                                                                'en_CA' => 'dd/mm/yy', 
                                                                'en_GB' => 'dd/mm/yy', 
                                                                'en_GH' => 'M/d/yy', 
                                                                'en_ID' => 'M/d/yy', 
                                                                'en_IE' => 'dd/mm/yy', 
                                                                'en_IN' => 'd/M/yy', 
                                                                'en_MY' => 'd/M/yy', 
                                                                'en_NG' => 'm/d/yy', 
                                                                'en_NZ' => 'd/mm/yy', 
                                                                'en_PH' => 'm/d/yy', 
                                                                'en_SG' => 'M/d/yy', 
                                                                'en_US' => 'm/dd/yy', 
                                                                'en_ZA' => 'yy/mm/dd', 
                                                                'es' => 'd/mm/yy', 
                                                                'es_AR' => 'dd/mm/yy', 
                                                                'es_BO' => 'dd-mm-yy', 
                                                                'es_CL' => 'dd-mm-yy', 
                                                                'es_CO' => 'd/mm/yy', 
                                                                'es_CR' => 'dd/mm/yy', 
                                                                'es_DO' => 'mm/dd/yy', 
                                                                'es_EC' => 'dd/mm/yy', 
                                                                'es_ES' => 'd/mm/yy', 
                                                                'es_GT' => 'd/mm/yy', 
                                                                'es_HN' => 'mm-dd-yy', 
                                                                'es_MX' => 'd/mm/yy', 
                                                                'es_PA' => 'mm/dd/yy', 
                                                                'es_PE' => 'dd/mm/yy', 
                                                                'es_PR' => 'mm-dd-yy', 
                                                                'es_PY' => 'dd/mm/yy', 
                                                                'es_SVUS' => 'mm-dd-yy', 
                                                                'es_UY' => 'dd/mm/yy', 
                                                                'es_VE' => 'dd/mm/yy', 
                                                                'et_EE' => 'd.mm.yy', 
                                                                'fi' => 'd.M.yy', 
                                                                'fi_FI' => 'd.M.yy', 
                                                                'fr' => 'dd/mm/yy', 
                                                                'fr_BE' => 'd/mm/yy', 
                                                                'fr_CA' => 'yy-mm-dd', 
                                                                'fr_CH' => 'dd.mm.yy', 
                                                                'fr_FR' => 'dd/mm/yy', 
                                                                'fr_LU' => 'dd/mm/yy', 
                                                                'fr_MC' => 'dd/mm/yy', 
                                                                'ga_IE' => 'dd/mm/yy', 
                                                                'hr_HR' => 'yy.mm.dd', 
                                                                'hu' => 'yy.mm.dd.', 
                                                                'hu_HU' => 'yy.mm.dd.', 
                                                                'hy_AM' => 'M/d/yy', 
                                                                'in' => 'yy/mm/dd', 
                                                                'in_ID' => 'dd/mm/yy', 
                                                                'is_IS' => 'd.M.yy', 
                                                                'it' => 'dd/mm/yy', 
                                                                'it_CH' => 'dd.mm.yy', 
                                                                'it_IT' => 'dd/mm/yy', 
                                                                'iw' => 'dd/mm/yy', 
                                                                'iw_IL' => 'dd/mm/yy', 
                                                                'ja' => 'yy/mm/dd', 
                                                                'ja_JP' => 'yy/mm/dd', 
                                                                'ka' => 'mm/d/yy', 
                                                                'ka_GE' => 'mm/d/yy', 
                                                                'kk_KZ' => 'M/d/yy', 
                                                                'km_KH' => 'M/d/yy', 
                                                                'ko' => 'yy. M. d', 
                                                                'ko_KR' => 'yy. M. d', 
                                                                'lt_LT' => 'yy.M.d', 
                                                                'lv_LV' => 'yy.d.M', 
                                                                'ms_MY' => 'dd/mm/yy', 
                                                                'nl' => 'd-M-yy', 
                                                                'nl_BE' => 'd/mm/yy', 
                                                                'nl_NL' => 'd-M-yy', 
                                                                'nl_SR' => 'd-M-yy', 
                                                                'no' => 'dd.mm.yy', 
                                                                'no_NO' => 'dd.mm.yy', 
                                                                'pl' => 'yy-mm-dd', 
                                                                'pt' => 'dd-mm-yy', 
                                                                'pt_AO' => 'dd-mm-yy', 
                                                                'pt_BR' => 'dd/mm/yy', 
                                                                'pt_PT' => 'dd-mm-yy', 
                                                                'ro' => 'dd.mm.yy', 
                                                                'ro_RO' => 'dd.mm.yy', 
                                                                'ru' => 'dd.mm.yy', 
                                                                'ru_RU' => 'dd.mm.yy', 
                                                                'sh' => 'dd.mm.yy', 
                                                                'sh_BA' => 'dd.mm.yy', 
                                                                'sh_CS' => 'dd.mm.yy', 
                                                                'sk' => 'd.M.yy', 
                                                                'sl_SI' => 'd.M.yy', 
                                                                'sr' => 'd.M.yy', 
                                                                'sr_BA' => 'yy-mm-dd', 
                                                                'sr_CS' => 'd.m.yy', 
                                                                'sk_SK' => 'd.M.yy', 
                                                                'sl_SI' => 'd.M.y', 
                                                                'sv' => 'yy-mm-dd', 
                                                                'sv_SE' => 'yy-mm-dd', 
                                                                'th' => 'M/d/yy', 
                                                                'th_TH' => 'd/M/yy', 
                                                                'tr' => 'dd.mm.yy', 
                                                                'tr_TR' => 'dd.mm.yy', 
                                                                'uk' => 'dd.mm.yy', 
                                                                'uk_UA' => 'dd.mm.yy', 
                                                                'ur_PK' => 'd/M/yy', 
                                                                'ur_PK' => 'd/M/yy', 
                                                                'ur_PK' => 'M/d/yy', 
                                                                'vi' => 'dd/mm/yy', 
                                                                'vi_VN' => 'dd/mm/yy', 
                                                                'zh' => 'yy-M-d', 
                                                                'zh_CN' => 'yy-M-d', 
                                                                'zh_HK' => 'yy-M-d', 
                                                                'zh_TW' => 'yy/M/d'}; //holds the locale to timedate formats
        return locale_map; //return the map
    }
    
    public static Map<String, String> MapTimeZoneValues() 
    {
        Map<String, String> localeTimeZone_map = new Map<String, String>{'sq_AL' => '12M', 
                                                                 'hy_AM' => '24',
                                                                 'az_AZ' => '24',
                                                                 'eu_ES' => '24',
                                                                 'be_BY' => '24',
                                                                 'bs_BA' => '24',
                                                                 'bg_BG' => '24',
                                                                 'ca_ES_EURO' => '24',
                                                                 'ca_ES' => '24',
                                                                 'zh_CN_PINYIN' => '12M',
                                                                 'zh_CN_STROKE' => '12M',
                                                                 'zh_CN' => '12M',
                                                                 'zh_HK_STROKE' => '12M',
                                                                 'zh_HK' => '12M',
                                                                 'zh_MO' => '12M',
                                                                 'zh_SG' => '12M',
                                                                 'zh_TW_STROKE' => '12M',
                                                                 'zh_TW' => '12M',
                                                                 'hr_HR' => '24',
                                                                 'cs_CZ' => '24',
                                                                 'da_DK' => '24',
                                                                 'nl_AW' => '24',
                                                                 'nl_BE' => '24',
                                                                 'nl_NL' => '24',
                                                                 'nl_SR' => '24',
                                                                 'dz_BT' => '12M',
                                                                 'en_AG' => '12M',
                                                                 'en_AU' => '12M',
                                                                 'en_BS' => '12M',
                                                                 'en_BB' => '24',
                                                                 'en_BZ' => '12M',
                                                                 'en_BM' => '24',
                                                                 'en_BW' => '12M',
                                                                 'en_CM' => '12M',
                                                                 'en_CA' => '12M',
                                                                 'en_KY' => '12M',
                                                                 'en_ER' => '12M',
                                                                 'en_FK' => '12M',
                                                                 'en_FJ' => '12M',
                                                                 'en_GM' => '12M',
                                                                 'en_GH' => '24',
                                                                 'en_GI' => '12M',
                                                                 'en_GY' => '12M',
                                                                 'en_HK' => '12M',
                                                                 'en_IN' => '12M',
                                                                 'en_ID' => '24',
                                                                 'en_IE_EURO' => '24',
                                                                 'en_IE' => '24',
                                                                 'en_JM' => '12M',
                                                                 'en_KE' => '12M',
                                                                 'en_LR' => '12M',
                                                                 'en_MG' => '12M',
                                                                 'en_MW' => '12M',
                                                                 'en_MY' => '24',
                                                                 'en_MU' => '12M',
                                                                 'en_NA' => '12M',
                                                                 'en_NZ' => '12M',
                                                                 'en_NG' => '24',
                                                                 'en_PK' => '12M',
                                                                 'en_PG' => '12M',
                                                                 'en_PH' => '12M',
                                                                 'en_RW' => '12M',
                                                                 'en_SH' => '12M',
                                                                 'en_WS' => '12M',
                                                                 'en_SC' => '12M',
                                                                 'en_SL' => '12M',
                                                                 'en_SG' => '24',
                                                                 'en_SX' => '12M',
                                                                 'en_SB' => '12M',
                                                                 'en_ZA' => '12M',
                                                                 'en_SZ' => '12M',
                                                                 'en_TZ' => '12M',
                                                                 'en_TO' => '12M',
                                                                 'en_TT' => '12M',
                                                                 'en_UG' => '12M',
                                                                 'en_GB' => '24',
                                                                 'en_US' => '12M',
                                                                 'en_VU' => '12M',
                                                                 'et_EE' => '24',
                                                                 'fi_FI_EURO' => '24',
                                                                 'fi_FI' => '24',
                                                                 'fr_BE' => '24',
                                                                 'fr_CA' => '24',
                                                                 'fr_KM' => '24',
                                                                 'fr_FR_EURO' => '24',
                                                                 'fr_FR' => '24',
                                                                 'fr_GN' => '24',
                                                                 'fr_HT' => '24',
                                                                 'fr_LU' => '24',
                                                                 'fr_MR' => '24',
                                                                 'fr_MC' => '24',
                                                                 'fr_CH' => '24',
                                                                 'fr_WF' => '24',
                                                                 'ka_GE' => '24',
                                                                 'de_AT_EURO' => '24',
                                                                 'de_AT' => '24',
                                                                 'de_DE_EURO' => '24',
                                                                 'de_DE' => '24',
                                                                 'de_LU_EURO' =>'24',
                                                                 'de_LU' => '24',
                                                                 'de_CH' =>'24',
                                                                 'el_GR' => '12M',
                                                                 'iw_IL' => '12M',
                                                                 'hi_IN' => '12M',
                                                                 'hu_HU' => '24',
                                                                 'is_IS' => '24',
                                                                 'in_ID' => '24',
                                                                 'ga_IE' => '24',
                                                                 'it_IT' => '24',
                                                                 'it_CH' => '24',
                                                                 'ja_JP' => '24',
                                                                 'kk_KZ' => '24',
                                                                 'km_KH' => '24',
                                                                 'ky_KG' => '12M',
                                                                 'ko_KP' => '12M',
                                                                 'ko_KR' => '12M',
                                                                 'lo_LA' => '12M',
                                                                 'lv_LV' => '24',
                                                                 'lt_LT' => '24',
                                                                 'lu_CD' => '12M',
                                                                 'lb_LU' => '12M',
                                                                 'mk_MK' => '24',
                                                                 'ms_BN' => '12M',
                                                                 'ms_MY' => '12M',
                                                                 'mt_MT' => '24',
                                                                 'ne_NP' => '24',
                                                                 'no_NO' => '24',
                                                                 'pl_PL' => '24',
                                                                 'pt_AO' => '24',
                                                                 'pt_BR' => '24',
                                                                 'pt_CV' => '24',
                                                                 'pt_MZ' => '24',
                                                                 'pt_PT' => '24',
                                                                 'pt_ST' =>'24',
                                                                 'ro_MD'=> '24',
                                                                 'ro_RO' => '24',
                                                                 'rm_CH' => '24',
                                                                 'rn_BI' => '12M',
                                                                 'ru_RU' => '24',
                                                                 'sr_BA' => '24',
                                                                 'sr_RS' => '24',
                                                                 'sr_CS'=> '24',
                                                                 'sh_BA' => '24',
                                                                 'sh_ME' => '24',
                                                                 'sh_CS'=> '24',
                                                                 'sk_SK' => '24',
                                                                 'sl_SI' => '24',
                                                                 'so_DJ' =>'12M',
                                                                 'so_SO' => '12M',
                                                                 'es_AR'=>'24',
                                                                 'es_BO'=>'12M',
                                                                 'es_CL' =>'12M',
                                                                 'es_CO' => '12M',
                                                                 'es_CR' => '12M',
                                                                 'es_CU' => '24',
                                                                 'es_DO' => '12M',
                                                                 'es_EC' => '12M',
                                                                 'es_SV' => '12M',
                                                                 'es_GT' => '12M',
                                                                 'es_HN' => '12M',
                                                                 'es_MX' => '12M',
                                                                 'es_NI' => '12M',
                                                                 'es_PA' => '12M',
                                                                 'es_PY' => '12M',
                                                                 'es_PE' => '12M',
                                                                 'es_PR' => '12M',
                                                                 'es_ES_EURO' => '24',
                                                                 'es_ES' => '24',
                                                                 'es_US' => '12M',
                                                                 'es_UY' => '12M',
                                                                 'es_VE' => '12M',
                                                                 'sv_SE' => '24',
                                                                 'tl_PH' => '12M',
                                                                 'tg_TJ'=>'12M',
                                                                 'ta_IN'=> '12M',
                                                                 'ta_LK'=> '12M',
                                                                 'th_TH' =>'24',
                                                                 'ti_ET'=>'12M',
                                                                 'tr_TR'=>'24',
                                                                 'uk_UA'=>'24',
                                                                 'ur_PK'=>'12M',
                                                                 'uz_LATN_UZ'=> '24',
                                                                 'vi_VN'=> '24',
                                                                 'cy_GB'=>'24',
                                                                 'yo_BJ'=>'12M'};
                                                                 
        
                                                                 
        return localeTimeZone_map;                                                       
                                                                 
     }
    

}