public with sharing class JobGateway {
    public static void onBeforeInsert (List <TR1__Job__c> listNewJob) {
        validate(listNewJob,null);
    }
    
    public static void onBeforeUpdate (List <TR1__Job__c> listNewJob,List <TR1__Job__c> listOldJob) {
        validate(listNewJob,listOldJob);
    }

    // public static void onAfterInsert (List <TR1__Job__c> listNewJob) {

    // }

    // public static void onAfterUpdate (List <TR1__Job__c> listNewJob,List <TR1__Job__c> listOldJob) {

    // }

    public static void validate (List <TR1__Job__c> listNewJob,List <TR1__Job__c> listOldJob) {
        TR1__Job__c newJob = new TR1__Job__c ();
        TR1__Job__c oldJob = new TR1__Job__c ();

        List <ID> listAllowedUserIDs = new List <ID> ();
        for (User u : [SELECT Id FROM User WHERE Profile.Name LIKE '%Recruiter%' OR Profile.Name LIKE '%Account Manager%']) {
            listAllowedUserIDs.add(u.Id);
        }

        for (SObject soNew : Trigger.new) {
            newJob = (TR1__Job__c)soNew;
            if (!listAllowedUserIDs.contains(newJob.TR1__Sourcing_Recruiter__c) && newJob.TR1__Sourcing_Recruiter__c != null) {
                newJob.TR1__Sourcing_Recruiter__c.addError(' The Sourcing Recruiter must be a Recruiter or Account Manager');
            }
            // if (Trigger.isUpdate) {
            //     for (SObject soOld : Trigger.old) {
            //         oldJob = (TR1__Job__c)soOld;
            //         if (newJob.Id == oldJob.Id) {
                        
            //         }
            //     }
            // } else {
                
            // }
        }
    }

    public static void correctTitleCasing (List <TR1__Job__c> listNewJob,List <TR1__Job__c> listOldJob) {
        TR1__Job__c oldJob = new TR1__Job__c ();
        TR1__Job__c newJob = new TR1__Job__c ();

        for (SObject soNew : Trigger.new) {
            newJob = (TR1__Job__c)soNew;
            if (Trigger.isUpdate) {
                for (SObject soOld : Trigger.old) {
                    oldJob = (TR1__Job__c)soOld;
                    if (newJob.Id == oldJob.Id) {
                        if (newJob.TR1__External_Job_Title__c != oldJob.TR1__External_Job_Title__c || newJob.TR1__External_Job_Title__c != null && oldJob.TR1__External_Job_Title__c == null) {
                        //  newJob.TR1__External_Job_Title__c?.toUpperCase() != oldJob.TR1__External_Job_Title__c?.toUpperCase() /* Allows for capitalization override, commented out per Okenna */
                            newJob.TR1__External_Job_Title__c = CTUtils.convertToTitleCase(newJob.TR1__External_Job_Title__c.trim());
                        }
                    }
                }
            } else {
                if (newJob.TR1__External_Job_Title__c != null) {
                    newJob.TR1__External_Job_Title__c = CTUtils.convertToTitleCase(newJob.TR1__External_Job_Title__c.trim());
                }
            }
        }
    }

    public static List <TR1__Job__c> getJobs (List <TR1__Job__c> listJobs) {
        return [SELECT 
            Able_to_sponsor_a_US_Visa_Candidate__c
            ,Academic_Opportunity__c
            ,Accepting_Late_Stage_Resident__c
            ,Accepts_H1B_Visas__c
            ,Accepts_J1_Visas__c
            ,Accepts_Visas__c
            ,Access_to_Decision_Maker__c
            ,Account_Company_Sub_Type__c
            ,Account_Company_Type__c
            ,Account_Manager__c
            ,Account_Manager_Email__c
            ,Account_Manager_Name__c
            ,Account_Name_Text__c
            ,Age__c
            ,Airfare_Billable__c
            ,Applications_Email__c
            ,Approval_Status__c
            ,Bill_PACER_Fee__c
            ,Bill_Retainers__c
            ,Billable_Interviews__c
            ,Billing_Contact_1__c
            ,Billing_Contact_2__c
            ,Billing_Contact_3__c
            ,Billing_Contact_4__c
            ,Board_Certification_Requirements__c
            ,Call_Requirements__c
            ,CE_Phone_Eval_Date__c
            ,Certifications__c
            ,Charge_Client_Specialty_Change_Rollover__c
            ,Charting__c
            ,Chatter_Team__c
            ,Comments__c
            ,Community_Details_from_Worksite1__c
            ,Contracting_Officer_Name_GOVT_Only__c
            ,CreatedById
            ,CreatedDate
            ,Credentialing_Contact__c
            ,Credentialing_Expectations__c
            ,Credentialing_Timeframe__c
            ,Date_Last_Posted__c
            ,Date_Last_Posting_Removed__c
            ,Dates_Needed__c
            ,Days_Since_CE__c
            ,Deadline__c
            ,Degree_DocCafe__c
            ,Degree_LJO__c
            ,EEOC_Category__c
            ,Employment_Type__c
            ,Employment_Type_LJO__c
            ,Evergreen_Posting__c
            ,Facility_Location_PracticeLink__c
            ,First_Day_Instructions__c
            ,FyreSyncReq__c
            ,GM_tracking_lead__c
            ,Hold_Date__c
            ,Hold_Details__c
            ,Hold_Reason__c
            ,Hot_Job__c
            ,Id
            ,Interview_Fee__c
            ,Interview_Process__c
            ,Is_this_a_Specialty_Transfer__c
            ,IsDeleted
            ,Items_needed_for_Presentation__c
            ,Job_Feed_Contact__c
            ,Job_Posting_City__c
            ,Job_Source__c
            ,Job_Stage_Custom__c
            ,Job_Title__c
            ,Last_Medestar_AM_Activity__c
            ,LastActivityDate
            ,Lastest_Booked_Shift__c
            ,LastModifiedById
            ,LastModifiedDate
            ,LastReferencedDate
            ,LastViewedDate
            ,Legacy_Billing_Contact__c
            ,Legacy_Contracting_Officer_Name_GOVT_ON__c
            ,Legacy_Credentialing_Contact__c
            ,Legacy_Reason_for_Vacancy__c
            ,Legacy_Third_Party_GOVT_ONLY__c
            ,legacy_Timesheet_Approver__c
            ,Loan_Repayment__c
            ,Lodging_Billable__c
            ,Marketer_Email__c
            ,MD_PA_Jobsite_State_ID__c
            ,MDJobsite_Category_ID__c
            ,MDJobsite_Position_Type_ID__c
            ,Medestar_AM_on_Account__c
            ,Medical_Setting__c
            ,Midlevel_Category_PAJobsite__c
            ,Mileage_Billable__c
            ,Name
            ,Name_Clear_Required__c
            ,New_Job_ReOpen__c
            ,No_Invoiced_Interview_Fees__c
            ,No_of_Closing_Reports__c
            ,No_of_Invoiced_PACER_Fees__c
            ,NPS_Contact__c
            ,Number_of_Open_Shifts__c
            ,Old_ID__c
            ,Old_Status__c
            ,On_Hold__c
            ,OwnerId
            ,PACER_Last_Updated__c
            ,PACER_link__c
            ,PAJobsite_Category_ID__c
            ,PAJobsite_Position_Type_ID__c
            ,Parent_Account__c
            ,Patient_Ages__c
            ,Payment_Terms__c
            ,Perm_Ranking__c
            ,Physician_Category_MDJobsite__c
            ,Placements__c
            ,Position_Type__c
            ,Position_Type_DocCafe__c
            ,Position_Type_MD_Jobsite__c
            ,Position_Type_MD_PA_Jobsite__c
            ,Position_Type_PhysEmp__c
            ,Post_To_LogicMelon__c
            ,Posted_Pay_Rate__c
            ,Posting_State__c
            ,Posting_Status__c
            ,Posting_Zip__c
            ,Power_of_1__c
            ,Previous_Chair_Experience_Required__c
            ,Previous_medical_officer_exprience_requi__c
            ,Previous_Professorship_Required__c
            ,Procedures__c
            ,Profession_Name_PracticeLink__c
            ,Qualifications__c
            ,Rank__c
            ,Re_Open__c
            ,RecordTypeId
            ,RECORDTYPENAME__c
            ,Recruiter_Focus__c
            ,Recruitment_Level__c
            ,Remaining_Openings__c
            ,Rental_Car_Billable__c
            ,Required_Boards__c
            ,Required_months_experience__c
            ,Schedule_Hours__c
            ,Secondary_Contact__c
            ,Secondary_Search__c
            ,Selling_Points__c
            ,Send_Job_Update__c
            ,Sent_for_Approval__c
            ,Skills__c
            ,Specialties__c
            ,Specialty_DocCafe__c
            ,Specialty_Function__c
            ,Specialty_Group__c
            ,Specialty_LJO__c
            ,Specialty_PhysEmp__c
            ,Specialty_PracticeLink__c
            ,State_Licensure_s_needed_to_apply__c
            ,State_MD_PA_Jobsite__c
            ,Support_Staff__c
            ,SystemModstamp
            ,Temp_Specialty_Group1__c
            ,Tertiary_Contact__c
            ,Third_Party_GOVT_Only__c
            ,Timesheet_Approver__c
            ,Total_In_Person_Interviews__c
            ,Total_Interviews2__c
            ,Total_Video_Interviews__c
            ,TR1__Account__c
            ,TR1__Account_Billing_Latitude__c
            ,TR1__Account_Billing_Longitude__c
            ,TR1__Account_Name__c
            ,TR1__Account_Shipping_Latitude__c
            ,TR1__Account_Shipping_Longitude__c
            ,TR1__Add_Associated_Qualifications__c
            ,TR1__Additional_Matching_Requirement__c
            ,TR1__Applicable_Days__c
            ,TR1__Bonus__c
            ,TR1__Booking_Type__c
            ,TR1__Certification__c
            ,TR1__Chatter_Team__c
            ,TR1__City__c
            ,TR1__Client_Description__c
            ,TR1__Client_Job_Description__c
            ,TR1__Closed_Date__c
            ,TR1__Closed_Reason__c
            ,TR1__Company_Website__c
            ,TR1__Computer_Systems__c
            ,TR1__Contact__c
            ,TR1__Contact_Email__c
            ,TR1__Contact_Phone__c
            ,TR1__Country__c
            ,TR1__County__c
            ,TR1__Days_Open__c
            ,TR1__Default_Interviewer_Location_Field__c
            ,TR1__Description_Exists__c
            ,TR1__Division__c
            ,TR1__Education__c
            ,TR1__Education_Requirements__c
            ,TR1__Employees__c
            ,TR1__End_Time__c
            ,TR1__Estimated_End_Date__c
            ,TR1__Estimated_Perm_Fee__c
            ,TR1__Estimated_Retained_Fee__c
            ,TR1__Estimated_Start_Date__c
            ,TR1__Experience_Requirements__c
            ,TR1__External_Job_Title__c
            ,TR1__External_Vacancy_Id__c
            ,TR1__Featured__c
            ,TR1__Fee_Percentage__c
            ,TR1__Final_Matching_Requirement__c
            ,TR1__Friday_s_Shift__c
            ,TR1__HasBillingAddress__c
            ,TR1__HasShippingAddress__c
            ,TR1__Hiring_Manager__c
            ,TR1__Industry__c
            ,TR1__Job_Board__c
            ,TR1__Job_Contact__c
            ,TR1__Job_Forecasting__c
            ,TR1__Job_GeoLocation__c
            ,TR1__Job_GeoLocation__Latitude__s
            ,TR1__Job_GeoLocation__Longitude__s
            ,TR1__Job_Lead__c
            ,TR1__Job_Number__c
            ,TR1__Job_Owner__c
            ,TR1__Job_Stage__c
            ,TR1__Job_Stage_Banner__c
            ,TR1__Job_Text__c
            ,TR1__Job_Title__c
            ,TR1__Last_successful_Sync_Date_Time__c
            ,TR1__LEA__c
            ,TR1__Level__c
            ,TR1__LinkedIn_Location__c
            ,TR1__LinkedIn_State__c
            ,TR1__LinkedInEmpStatus__c
            ,TR1__LinkedInJobCountry__c
            ,TR1__LinkedInJobID__c
            ,TR1__LinkedInJobPost_URL__c
            ,TR1__Management_Experience__c
            ,TR1__Marketing__c
            ,TR1__Maximum_Bill_Rate__c
            ,TR1__Maximum_Hour_Charge_Rate__c
            ,TR1__Maximum_Hour_Pay_Rate__c
            ,TR1__Maximum_Pay_Rate__c
            ,TR1__Minimum_Bill_Rate__c
            ,TR1__Minimum_Pay_Rate__c
            ,TR1__Monday_s_Shift__c
            ,TR1__Most_Advanced_Stage__c
            ,TR1__No_of_Current_Applications__c
            ,TR1__No_of_Current_Offers__c
            ,TR1__No_of_Current_Sendouts__c
            ,TR1__No_of_Current_Submittals__c
            ,TR1__Non_Rejected_Applications__c
            ,TR1__Non_Rejected_Offers__c
            ,TR1__Non_Rejected_Submittals__c
            ,TR1__Notes__c
            ,TR1__Number_of_Active_Apps__c
            ,TR1__Number_of_Openings__c
            ,TR1__Open_Date__c
            ,TR1__Other_Experience__c
            ,TR1__Ownership__c
            ,TR1__Perm_Estimated_Additional_Compensation__c
            ,TR1__Post_Externally__c
            ,TR1__Post_on_Social_Sites__c
            ,TR1__Postal_Code__c
            ,TR1__PostIn_Linkedin__c
            ,TR1__Primary_Background__c
            ,TR1__Primary_Matching_Requirement__c
            ,TR1__Proximity_Location__c
            ,TR1__Qualifications__c
            ,TR1__Rates_From_Account__c
            ,TR1__Regional_Area__c
            ,TR1__Reject_Out_Other_Applicants__c
            ,TR1__Reporting_Structure__c
            ,TR1__Reports_To__c
            ,TR1__Responsibilities__c
            ,TR1__Retain_Estimated_Additional_Compensation__c
            ,TR1__Revenue__c
            ,TR1__Salary_High__c
            ,TR1__Salary_Low__c
            ,TR1__Saturday_s_Shift__c
            ,TR1__Secondary_Background__c
            ,TR1__Secondary_Matching_Requirement__c
            ,TR1__Sector1__c
            ,TR1__Selling_Points__c
            ,TR1__SEN_Additional_Experience__c
            ,TR1__Shift__c
            ,TR1__Shifts__c
            ,TR1__Skills_Training_Experience__c
            ,TR1__SMWS_Date_Time__c
            ,TR1__SMWS_Status__c
            ,TR1__SMWS_Status_Code__c
            ,TR1__Social_Post_Message__c
            ,TR1__Sourcing_Recruiter__c
            ,TR1__Sourcing_Recruiter__r.Profile.Name
            ,TR1__Sponsoron__c
            ,TR1__Stage_1_Send_Out_Schedules__c
            ,TR1__Stage_2_Send_Out_Schedules__c
            ,TR1__Stage_3_Send_Out_Schedules__c
            ,TR1__Stage_4_Send_Out_Schedules__c
            ,TR1__Stage_5_Send_Out_Schedules__c
            ,TR1__Start_Time__c
            ,TR1__State__c
            ,TR1__State_Area__c
            ,TR1__Status__c
            ,TR1__Street__c
            ,TR1__Sub_Sector__c
            ,TR1__Subject__c
            ,TR1__Sunday_s_Shift__c
            ,TR1__Sync_Error_Message__c
            ,TR1__Thursday_s_Shift__c
            ,TR1__Timesheet_Approver__c
            ,TR1__Total_Applications__c
            ,TR1__Total_Offers__c
            ,TR1__Total_Offers2__c
            ,TR1__Total_Submittals__c
            ,TR1__Tuesday_s_Shift__c
            ,TR1__Unique_VMS_Req_ID__c
            ,TR1__VMS_Last_Payload__c
            ,TR1__VMS_Last_Update__c
            ,TR1__VMS_Req_ID__c
            ,TR1__VMS_Response_Deadline__c
            ,TR1__VMS_Status__c
            ,TR1__VMS_submittalMax__c
            ,TR1__Wednesday_s_Shift__c
            ,TR1__Why_Open__c
            ,TR1__Work_Shift_Location_lkId__c
            ,TR1__Workshift_Proximity_Location__c
            ,TR1__Year_Key_Stage__c
            ,TR1__Years_of_Experience__c
            ,Travel_Lodging_Notes__c
            ,TRSCHED__Applicable_Days__c
            ,TRSCHED__Arrival_Time__c
            ,TRSCHED__Booking_Type__c
            ,TRSCHED__Chatter_Team__c
            ,TRSCHED__Country__c
            ,TRSCHED__Division__c
            ,TRSCHED__End_Time__c
            ,TRSCHED__Friday_Extra_Duties_Hours__c
            ,TRSCHED__Friday_s_Shift__c
            ,TRSCHED__Job_GeoLocation__c
            ,TRSCHED__Job_GeoLocation__Latitude__s
            ,TRSCHED__Job_GeoLocation__Longitude__s
            ,TRSCHED__Job_Title__c
            ,TRSCHED__LEA__c
            ,TRSCHED__Maximum_Annual_Salary__c
            ,TRSCHED__Maximum_Hour_Charge_Rate__c
            ,TRSCHED__Maximum_Hour_Pay_Rate__c
            ,TRSCHED__Minimum_Annual_Salary__c
            ,TRSCHED__Monday_Extra_Duties__c
            ,TRSCHED__Monday_s_Shift__c
            ,TRSCHED__Notes__c
            ,TRSCHED__Postal_Code__c
            ,TRSCHED__Proximity_Location__c
            ,TRSCHED__Qualifications__c
            ,TRSCHED__Reason_for_Vacancy__c
            ,TRSCHED__Regional_Salary_Scales__c
            ,TRSCHED__Reports_To__c
            ,TRSCHED__Saturday_Extra_Duties_Hours__c
            ,TRSCHED__Saturday_s_Shift__c
            ,TRSCHED__School_Type__c
            ,TRSCHED__Sector1__c
            ,TRSCHED__SEN_Additional_Experience__c
            ,TRSCHED__SEN_Experience__c
            ,TRSCHED__Shift__c
            ,TRSCHED__Shifts__c
            ,TRSCHED__Skills_Training_Experience__c
            ,TRSCHED__Specialism__c
            ,TRSCHED__Start_Time__c
            ,TRSCHED__State__c
            ,TRSCHED__Street__c
            ,TRSCHED__Sub_LEA__c
            ,TRSCHED__Sub_Sector__c
            ,TRSCHED__Subject__c
            ,TRSCHED__Sunday_Extra_Duties_Hours__c
            ,TRSCHED__Sunday_s_Shift__c
            ,TRSCHED__Thursday_Extra_Duties_Hours__c
            ,TRSCHED__Thursday_s_Shift__c
            ,TRSCHED__Timesheet_Approver__c
            ,TRSCHED__Timesheet_Pay_Type__c
            ,TRSCHED__Trained_As__c
            ,TRSCHED__Tuesday_Extra_Duties_Hours__c
            ,TRSCHED__Tuesday_s_Shift__c
            ,TRSCHED__Wednesday_Extra_Duties_Hours__c
            ,TRSCHED__Wednesday_s_Shift__c
            ,TRSCHED__Work_Shift_Location__c
            ,TRSCHED__Work_Shift_Location_lkId__c
            ,TRSCHED__Workshift_Proximity_Location__c
            ,TRSCHED__Year_Key_Stage__c
            ,Types_of_Cases__c
            ,Unique_ID__c
            ,Unique_Search__c
            ,VMS_Job_Link__c
            ,Volume__c
            ,Will_Client_wait_for_a_License__c
            ,Work_Environment_DocCafe__c
            ,Worksite_1__c
            ,Worksite_1_Address__c
            ,Worksite_1_City__c
            ,Worksite_1_Name__c
            ,Worksite_1_State__c
            ,Worksite_1_Street__c
            ,Worksite_1_Zip__c
            ,Worksite_10__c
            ,Worksite_2__c
            ,Worksite_2_Address__c
            ,Worksite_2_City__c
            ,Worksite_2_Name__c
            ,Worksite_2_State__c
            ,Worksite_2_Street__c
            ,Worksite_2_Zip__c
            ,Worksite_3__c
            ,Worksite_3_Address__c
            ,Worksite_3_City__c
            ,Worksite_3_Name__c
            ,Worksite_3_State__c
            ,Worksite_3_Street__c
            ,Worksite_3_Zip__c
            ,Worksite_4__c
            ,Worksite_4_Address__c
            ,Worksite_4_City__c
            ,Worksite_4_Name__c
            ,Worksite_4_State__c
            ,Worksite_4_Street__c
            ,Worksite_4_Zip__c
            ,Worksite_5__c
            ,Worksite_5_Address__c
            ,Worksite_5_City__c
            ,Worksite_5_Name__c
            ,Worksite_5_State__c
            ,Worksite_5_Street__c
            ,Worksite_5_Zip__c
            ,Worksite_6__c
            ,Worksite_7__c
            ,Worksite_8__c
            ,Worksite_9__c
            ,Worksite_Name_s_Address_es_Legacy__c
            ,Write_Up_Received__c
            ,Zip_Code__c
            ,Zip_Postal_Code__c 
        FROM TR1__Job__c WHERE Id IN : listJobs];
    }
}
