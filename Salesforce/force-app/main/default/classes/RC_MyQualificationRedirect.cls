public with sharing class RC_MyQualificationRedirect {
    public String QualId;
    public TR1__Associated_Qualification__c objAssocQual {get;set;} 
    public Contact objCont {get;set;}
    
    public Map<String, String> redirectPageMap {
      get{
        if(redirectPageMap == null){
          redirectPageMap = new Map<String, String>();
          redirectPageMap.put('Field Update','/apex/MyQualificationDetailEdit?qid=');
          redirectPageMap.put('Upload File','/apex/MyQualificationUploadDocument?qid=');
          redirectPageMap.put('Docusign','/apex/MyQualificationDocuSignUpdated?qid=');
          redirectPageMap.put('Success','/apex/MyQualificationEditSuccess?qid=');
        }
        return redirectPageMap;
      }
      protected set;
    }
    
    public List<String> methodCheckOrder {
      get{
        if(methodCheckOrder == null){
          methodCheckOrder = new List<String>();
          methodCheckOrder.add('Field Update');
          methodCheckOrder.add('Upload File');
          methodCheckOrder.add('Docusign');
          
          
        }
        return methodCheckOrder;
      }
      protected set;
    }
    
    public RC_MyQualificationRedirect(){
        objAssocQual = null;
        fetchContactInfo();
    }
    
     //To fetch the contact detail
    private void fetchContactInfo()
    {
        String fieldNames ='';
        
        String strQuery = 'Select Id'; 
        
        List<Schema.FieldSetMember> lstFieldSet = SObjectType.Contact.FieldSets.getMap().get('RC_My_Profile_Header').getFields();
        
        for(Schema.FieldSetMember field : lstFieldSet) 
        {
            if(!fieldNames.contains(field.getFieldPath()))
                fieldNames += ', ' + field.getFieldPath(); 
        }
        
        String idContact = [Select Id, ContactId                                           
                                   From User 
                                   where Id=: UserInfo.getUserId()].ContactId;
               
        strQuery  += fieldNames + ' from Contact where id =: idContact' ;    
        system.debug('---strQuery-'+strQuery);
        List<Contact> lstContact = Database.query(strQuery);
        
        Integer index = 0;
        
        if(!lstContact.isEmpty())
            objCont = lstContact[index]; 
    } 

    public Pagereference checkMethod(){
        Pagereference pg = null;
        try{
          if(System.currentPageReference().getParameters().containsKey('qId')){
              qualId = System.currentPageReference().getParameters().get('qId');
          }
          
          String startOver = '';
          if(System.currentPageReference().getParameters().containsKey('startOver')){
              startOver = System.currentPageReference().getParameters().get('startOver');
          }
          
          // Fetch AQ
      for(TR1__Associated_Qualification__c aq : RC_AccessController.getAssociatedQualificationsById(qualId, objCont.Id)){
        ObjAssocQual = aq;  
      }
          if(ObjAssocQual == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Associated Qualification Missing!'));
            return pg;
          }
          
          if(startOver == '1'){
            ObjAssocQual.TR1__Completed_Collection_Methods__c = null;
            RC_AccessController.updateRecord(ObjAssocQual);
          }
          //Check if Qualification have Collection Methods
          if(ObjAssocQual.TR1__Qualification__r.TR1__Collection_Methods__c != null){
            Set<String> qlfCollectionMethods = new Set<String>();
            Set<String> assQlfCollectionMethods = new Set<String>();
            for(String str : ObjAssocQual.TR1__Qualification__r.TR1__Collection_Methods__c.split(';')){
              qlfCollectionMethods.add(str);
            }
            
            if(ObjAssocQual.TR1__Completed_Collection_Methods__c != null){
              for(String str : ObjAssocQual.TR1__Completed_Collection_Methods__c.split(';')){
                assQlfCollectionMethods.add(str);
              }
            }
            
            system.debug('--- assQlfCollectionMethods ---'+assQlfCollectionMethods);
            system.debug('--- qlfCollectionMethods ---'+qlfCollectionMethods);
            
            
            for(String method : methodCheckOrder){
              if(qlfCollectionMethods.contains(method)
                && !assQlfCollectionMethods.contains(method)){
                    system.debug('--- method ---'+method);
                pg = new pagereference(redirectPageMap.get(method)+QualId);
                pg.setRedirect(true);
                break;
              }
            }
            
            // FOR SUCCESS
            if(pg == null){
              pg = new pagereference(redirectPageMap.get('Success')+QualId);
              pg.setRedirect(true);
            }
          }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Collection Methods have been defined. Please contact the System Administrator'));
          }
        }catch(Exception e){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getStackTraceString()));
            pg = null;
    }
    return pg;
    }
    
}