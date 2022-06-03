@isTest(SeeAllData = false)
public with sharing class Test_LogicMelonHelper {

    static testMethod void Test_LogicMelonHelper() {
        
        
        //Create Test Data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(LastName = 'ABC');
        insert con;
        
        TR1__Job__c jobRec = new TR1__Job__c(TR1__Account__c = acc.id , TR1__Contact__c = con.id , Name = 'Test Job' , TR1__Hiring_Manager__c = con.id ,TR1__Division__c = 'Clinical' , TR1__Salary_High__c = 100 ,TR1__Fee_Percentage__c = 10,
                                                                TR1__Level__c =  'Executive' ,TR1__Primary_Matching_Requirement__c = 'Test' , TR1__Estimated_Start_Date__c = System.today() ,TR1__City__c = 'Test');
        insert jobRec;

        List< LogicMelonXMLTag__c > lmCSList = new List< LogicMelonXMLTag__c >();
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM015',StartTag__c='<VacExtension name="jobid">',EndTag__c='</VacExtension>',DefaultValue__c='',FieldAPI__c='ID',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM013',StartTag__c='<VacExtension name="startdate">',EndTag__c='</VacExtension>',DefaultValue__c='',FieldAPI__c='TR1__Estimated_Start_Date__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM001',StartTag__c='<JobTitle>',EndTag__c='</JobTitle>',DefaultValue__c='',FieldAPI__c='TR1__Job_Title__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM002',StartTag__c='<JobReference>',EndTag__c='</JobReference>',DefaultValue__c='',FieldAPI__c='TR1__Job_Number__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM003',StartTag__c='<JobType>',EndTag__c='</JobType>',DefaultValue__c='',FieldAPI__c='RecordTypeName__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM005',StartTag__c='<Industry>',EndTag__c='</Industry>',DefaultValue__c='',FieldAPI__c='TR1__Industry__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM006',StartTag__c='<SalaryFrom>',EndTag__c='</SalaryFrom>',DefaultValue__c='',FieldAPI__c='TR1__Minimum_Pay_Rate__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM007',StartTag__c='<SalaryTo>',EndTag__c='</SalaryTo>',DefaultValue__c='',FieldAPI__c='TR1__Maximum_Pay_Rate__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM008',StartTag__c='<SalaryCurrency>',EndTag__c='</SalaryCurrency>',DefaultValue__c='USD',FieldAPI__c='',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM009',StartTag__c='<SalaryPer>',EndTag__c='</SalaryPer>',DefaultValue__c='annum',FieldAPI__c='',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM010',StartTag__c='<Skills>',EndTag__c='</Skills>',DefaultValue__c='',FieldAPI__c='TR1__Primary_Background__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM011',StartTag__c='<JobDescription>',EndTag__c='</JobDescription>',DefaultValue__c='',FieldAPI__c='TR1__Client_Description__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM012',StartTag__c='<VacExtension name="duration">',EndTag__c='</VacExtension>',DefaultValue__c='6 months',FieldAPI__c='',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM023',StartTag__c='<SalaryTo>',EndTag__c='</SalaryTo>',DefaultValue__c='',FieldAPI__c='TR1__Salary_High__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM018',StartTag__c='<JobTitle>',EndTag__c='</JobTitle>',DefaultValue__c='',FieldAPI__c='TR1__Job_Title__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM030',StartTag__c='<VacExtension name="jobid">',EndTag__c='</VacExtension>',DefaultValue__c='',FieldAPI__c='ID',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM025',StartTag__c='<SalaryPer>',EndTag__c='</SalaryPer>',DefaultValue__c='hour',FieldAPI__c='',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM031',StartTag__c='<City>',EndTag__c='</City>',DefaultValue__c='',FieldAPI__c='TR1__City__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM019',StartTag__c='<JobReference>',EndTag__c='</JobReference>',DefaultValue__c='',FieldAPI__c='TR1__Job_Number__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM026',StartTag__c='<Skills>',EndTag__c='</Skills>',DefaultValue__c='',FieldAPI__c='TR1__Primary_Background__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM028',StartTag__c='<VacExtension name="duration">',EndTag__c='</VacExtension>',DefaultValue__c='6 months',FieldAPI__c='',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM032',StartTag__c='<County>',EndTag__c='</County>',DefaultValue__c='',FieldAPI__c='TR1__State_Area__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM021',StartTag__c='<Industry>',EndTag__c='</Industry>',DefaultValue__c='',FieldAPI__c='TR1__Industry__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM027',StartTag__c='<JobDescription>',EndTag__c='</JobDescription>',DefaultValue__c='',FieldAPI__c='TR1__Client_Description__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM022',StartTag__c='<SalaryFrom>',EndTag__c='</SalaryFrom>',DefaultValue__c='',FieldAPI__c='TR1__Salary_Low__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM024',StartTag__c='<SalaryCurrency>',EndTag__c='</SalaryCurrency>',DefaultValue__c='USD',FieldAPI__c='',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM020',StartTag__c='<JobType>',EndTag__c='</JobType>',DefaultValue__c='',FieldAPI__c='RecordTypeName__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM029',StartTag__c='<VacExtension name="startdate">',EndTag__c='</VacExtension>',DefaultValue__c='',FieldAPI__c='TR1__Estimated_Start_Date__c',RecordTypeName__c='Contract'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM017',StartTag__c='<County>',EndTag__c='</County>',DefaultValue__c='',FieldAPI__c='TR1__State_Area__c',RecordTypeName__c='Permanent'));
        lmCSList.add(new LogicMelonXMLTag__c(Name='LM016',StartTag__c='<City>',EndTag__c='</City>',DefaultValue__c='',FieldAPI__c='TR1__City__c',RecordTypeName__c='Permanent'));
        insert lmCSList;        
        
        //Start Test
        Test.startTest();
        
        // Setting Apex Page
        ApexPages.StandardController stdController;
        Test.setCurrentPage(Page.LogicMelonJobHelper);  

        // Defining and setting the constructor
        stdController = new ApexPages.StandardController(jobRec);
        PostToLogicMelonController a = new PostToLogicMelonController(stdController);
        
        a.ChannelIdVal.add('jobscabi'); 
        a.ChannelIdVal.add('LogicMelon');
        a.PostJobToSelectedJobBoards();
        a.deletePosting();
        
        //Stop Test                                                     
        Test.stopTest();
        
    }

    public static testMethod void Test_LogicMelonTrigger() {
        //Create Test Data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(LastName = 'ABC');
        insert con;
        
        TR1__Job__c jobRec = new TR1__Job__c(TR1__Account__c = acc.id , TR1__Contact__c = con.id , Name = 'Test Job' , TR1__Hiring_Manager__c = con.id ,TR1__Division__c = 'Clinical' , TR1__Salary_High__c = 100 ,TR1__Fee_Percentage__c = 10,
                                                                TR1__Level__c =  'Executive' ,TR1__Primary_Matching_Requirement__c = 'Test' , TR1__Estimated_Start_Date__c = System.today() ,TR1__City__c = 'Test');
        insert jobRec;

        Test.startTest();

        jobRec.TR1__Status__c = 'Closed';
        update jobRec;

        Test.stopTest();
    }
}