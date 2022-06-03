global class BatchAuditTrailLog implements Database.Batchable<sObject>, Database.Stateful {

    global static String dateRange = 'YESTERDAY';
    global String query;
    global Integer count;
    
    global BatchAuditTrailLog () {

        /*
        // To Track - Development
        String apexClass = '\'changedApexClass\',\'createdApexClass\',';
        String apexTrigger = '\'createdApexTrigger\',\'changedApexTrigger\',';
        String certificateAndKeyManagement = '\'uploadCertificateChain\',';
        String changeDataCapture = '\'changeDataCaptureCreatedWithChannel\',';
        String component = '\'changedApexComponent\',\'createdApexComponent\',';
        String lightningComponents = '\'changedAuraComponent\',\'createdAuraComponent\',\'changedLightningWebComponent\',';
        String lightningPages = '\'changedFlexiPage\',\'createdFlexiPage\',';
        String page = '\'changedApexPage\',\'createdApexPage\',';
        String inboundChangeSets = '\'deployedchangeset\',';
        String staticResource = '\'createdApexPage\',\'changedStaticResource\',\'createdStaticResource\',';
        // To Track - Automation
        String approvalProcess = '\'changedprocessdefinition\',\'changedprocessnode\',\'addedprocessactionitem\',';
        String flows = '\'createdinteractiondefinition\',\'createdinteractiondefversion\',\'deletedinteractiondefversion\',\'activatedinteractiondefinition\',\'deactivatedinteractiondefinition\',\'activatedinteractiondefversion\',\'deactivatedinteractiondefversion\',';
        String globalActions = '\'createdQuickActionDefaultCustom\',\'createdQuickAction\',\'createdQuickActionDefault\',';
        String loginFlows = '\'deleteLoginFlow\',\'insertLoginFlow\',';
        String workflowRule = '\'createdworkflowrule\',\'createdflowtrigger\',\'createdworkflowtimetrigger\',\'deactivatedworkflowrule\',\'deletedworkflowrule\',\'deletedflowtrigger\',\'deletedworkflowtimetrigger\',\'createdemailalert\',\'changedworkflowrule\',\'activatedworkflowrule\',';
        // To Track - Configuration
        String application = '\'changeOauthDefaultScope\',\'changeApplicationContactEmail\',\'changeApplicationMobileSessionTimeout\',\'changeApplicationPinLength\',\'changeApplicationContactPhone\',\'changeUserRuntimeAccessPolicy\',';
        String connectedAppSessionPolicy = '\'insertConnectedAppSessionPolicy\',';
        String connectedApps = '\'insertConnectedApplication\',';
        String customApps = '\'upgradedpackagingapp\',\'changedTabSetTabs\',\'deletedTabSet\',\'installedpackagingapp\',\'createdTabSet\',\'changedTabSetName\',\'changedTabSetDevName\',';
        String customizeHistoricalEntityTrending = '\'HistoricalTrendingEntityTracked\',\'HistoricalTrendingFieldTracked\',';
        String feedTracking = '\'feed_entity_tracked\',\'feed_field_tracked\',';
        String manageApps = '\'changeAppMenuItemVisibility\',';
        String trackFieldHistory = '\'entity_history_field_untracked\',\'entity_history_field_tracked\',';
        String validationRules = '\'changedValidationFormula\',\'changedValidationActive\',';
        // To Track - Org Administration
        String identityVerification = '\'U2FChanged\',\'ToopherLocationAutomationChanged\',';
        String omniChannel = '\'createQueueRoutingConfig\',';
        String securityControls = '\'createIpWhiteList\',\'remoteproxy\',';
        String sessionSettings = '\'sessiontimeoutForProfile\',\'updateSessionSecurityLevel\',';
        String sharingDefaults = '\'owdUpdateStarted\',\'owdInternalUpdateStartedForEntity\',\'owdExternalUpdateStartedForEntity\',\'defaultCustomEntityAccess\',\'defaultCustomEntityExtAccess\',\'owdUpdateFinished\',';
        String sharingRules = '\'recalcSingleSharingRuleStart\',\'recalcSingleSharingRuleComplete\',\'updateSharingRule\',';
        // To Track - User Administration
        String manageUsersLoginAs = '\'suOrgAdminLogin\',\'suOrgAdminLogout\',\'suNetworkAdminLogin\',\'suNetworkAdminLogout\',';
        // To Track - Other
        String none = '\'userLicenseUserPermRevoked\',\'subscriptionAppEnrolledOffOn\',\'value_PROV_SCRATCH_DAILY_LIMIT\',\'value_MAX_STREAMING_TOPICS_PROV\',\'value_PROV_SCRATCH_ACTIVE_LIMIT\',\'rqrEmailChangeConfirmPrefOffOn\',\'inAppLearningOffOn\',\'nonSecurityReviewedManagedPackageInstalled\',\'deletedLoginIpRange_withProfile\',\'pipelineInspectionSetupPrefOffOn\',\'pipelineInspectionPrefOffOn\',\'PermissionSelfHealing\',\'loginasgrantedtosfdc\',\'loginasgrantedtopartnerbt\',\'preventBadgeGuestAccessOffOn\',\'preventBadgeGuestAccessOnOff\',\'pdf2JpgOffOn\',\'communitiesDefaultCdnPrefOffOn\',\'auraComponentAccessFixPrefOffOn\',\'chatFindOrCreateEnableOffOn\',\'recipeDirectDataPrefOffOn\',\'vFJSRemotingEnforcePrefOffOn\',\'BlackTabFrameworkActionRun\',\'einsteinArticleRecOffOn\',\'cspNotesOnAccConPrefOffOn\',\'orgHasMobileOfflineEnabledOffOn\',\'sourceTrackingSandboxesOffOn\',';
        */

        // Not To Track - Automation
        String reportingSnapshots = '\'deletedReportJob\',';
        // Not To Track - Configuration
        String articleTypes = '\'createdCFArtType\',\'articlelayout\',\'changedCFFieldHelpArtType\',';
        String companyInformation = '\'add_external_id\',\'delete_external_id\',';
        String customObjects = '\'createdCustEnt\',\'changedCustEntName\',\'changedCustEntLabel\',\'changedCustEntRecName\',\'changedCustEntRptOn\',\'changedCustEntRptOff\',\'changedCustEntActivityOn\',\'deletedCustEnt\',\'custentlayout\',\'savedlistlayoutCustomObject\',\'createdCompactLayout\',\'createdCFCustom\',\'createdPicklistWithColorCustom\',\'createdCFMasterDetailCustom\',\'createdCFLookupCustom\',\'createdCF_RSFCustom\',\'createdCFFormulaCustom\',\'createdFieldSet\',\'changedCFCustom\',\'changedCFDevNameCustom\',\'changedCFFieldHelpCustom\',\'changedCFLengthCustom\',\'changedCFOptionOffOnCustom\',\'changedCFOptionOnOffCustom\',\'changedPicklistCustom\',\'changedPicklistValueApiNameCustom\',\'changedPicklistDefaultCustom\',\'changedPicklistSortCustom\',\'changedCFDefaultFormulaCustom\',\'changedCFFormulaCustom\',\'changedCFTypeCustom\',\'deactivatePicklistValueWithColorCustom\',\'deletedCFCustom\',\'filteredLookupCreate\',\'filteredLookupCreateNewField\',\'filteredLookupActivate\',\'filteredLookupRequired\',\'createdCustLinkCustom\',\'changedCustLinkContentCustom\',\'createdActionOverrideCustom\',';
        String businessProcess = '\'updatedBusinessProcessValues\',\'updatedBusinessProcess\',';
        String customTabs = '\'createdCustEntTab\',\'deletedCustEntTab\',\'changedCustomTabField\',\'createdCustomTab\',';
        String customizeAccounts = '\'createdCF\',\'changedCF\',\'changedCFDevName\',\'changedCFFieldHelp\',\'activatedPicklistValueWithColor\',\'deactivatePicklistValueWithColor\',\'deletedPicklistMapWithColor\',\'accountlayout\',\'savedlistlayoutAccount\',\'createdCustLink\',';
        String customizeActivities = '\'createdPicklistWithColor\',\'deletedPicklistWithColor\',\'updatedCompactLayoutMapping\',';
        String customizeCampaigns = '\'changedCustLinkContent\',';
        String customizeCases = '\'createdCF\',\'changedPicklistDefault\',\'changedPicklistSort\',\'deletedCF\',\'undeletedCF\',\'caseassrule\',\'caselayout\',\'changedQuickActionDefaultFormulaCustom\',';
        String customizeContacts = '\'contactlayout\',\'savedlistlayoutContact\',\'changedCFTypeFormula\',';
        String customizeLeads = '\'leadlayout\',\'createdCFFormula\',\'savedlistlayoutLead\',\'changedCFFormula\',\'changedPicklist\',\'changedPicklistValueApiName\',\'createdCFLookup\',\'updatedDefaultCompactLayoutMapping\',\'changedQuickActionLayout\',\'changedCFType\',\'changedCFOptionOnOff\',\'changedCFLine\',';
        String customizeOpportunities = '\'opplayout\',\'removedFieldOnCompactLayout\',\'createdActionOverride\',\'deletedActionOverride\',\'createdQuickActionCustom\',\'savedlistlayoutOpportunity\',\'createdCF_RSF\',\'changedCF_RSFFilter\',\'forceRecalc_RSFField\',\'addedFieldToCompactLayout\',';
        String customizeProducts = '\'changedCFScale\',\'productlayout\',';
        String fieldDependencies = '\'updatedDependency\',';
        // Not To Track - Org Administration
        String apiUsageNotification = '\'RateLimitingNotification\',';
        String dataManagement = '\'accounttransfer\',\'leadtransfer\',\'queueMembership\',\'emptiedUserRecycleBin\',\'createdqueue\',';
        String groups = '\'groupMembership\',\'createdgroup\',';
        String mobileAdministration = '\'changedmobileconfigurationname\',\'changedmobileconfigdatasizelimit\',\'changedmobileconfigmobilizerecent\',\'assigneduserstomobileconfig\',';
        // Not To Track - User Administration
        String customerPortal = '\'createdcustomersuccessuser\',\'CSPUserDisabled\',';
        String inboxMobileAndLegacyDesktopApps = '\'disableSIQUserNonEAC\',\'enableSIQUserInbox\',\'siqUserAcceptedInboxTOS\',';
        String manageUsers = '\'createduser\',\'activateduser\',\'unfrozeuser\',\'frozeuser\',\'deactivateduser\',\'unlockeduser\',\'changedpassword\',\'resetpassword\',\'changedusername\',\'changedemail\',\'useremailchangesent\',\'changedcommunitynickname\',\'changedManager\',\'changedDelegateApprover\',\'changedroleforuser\',\'changedroleforusertonone\',\'changedroleforuserfromnone\',\'changedprofileforuser\',\'changedprofileforusercusttostd\',\'changedprofileforuserstdtocust\',\'PermSetAssign\',\'PermSetUnassign\',\'changedofflineuseroffon\',\'changedofflineuseronoff\',\'changedsfcontentuseroffon\',\'changedsfcontentuseronoff\',\'changedsupportuseroffon\',\'changedsupportuseronoff\',\'changedknowledgeuseroffon\',\'changedknowledgeuseronoff\',\'changedliveagentuseroffon\',\'changedliveagentuseronoff\',\'changedmarketinguseroffon\',\'changedmarketinguseronoff\',\'registeredUserPhoneNumber\',\'changedUserPhoneNumber\',\'unregisterdUserPhoneNumber\',\'changedUserPhoneVerifiedStatusVerified\',\'changedUserPhoneVerifiedStatusUnverified\',\'changedUserAdminVerifiedStatusVerified\',\'changedUserAdminVerifiedStatusUnverified\',\'changedUserEmailVerifiedStatusVerified\',\'changedUserEmailVerifiedStatusUnverified\',';
        String manageUserMFA = '\'insertAuthenticatorPairing\',\'deleteAuthenticatorPairing\',\'insertTwoFactorInfo2\',\'deleteTwoFactorInfo2\',\'lightningloginenroll\',\'lightninglogincancel\',\'insertTwoFactorU2F\',\'deleteTwoFactorU2F\',\'insertTwoFactorTempCode\',';
        String manageProfiles = '\'profileClonedCustom\',\'profileClonedStandard\',\'deletedprofile\',\'profileViewAllDataEnabledCustom\',\'profileViewAllDataDisabledCustom\',\'profileViewAllDataEnabledStandard\',\'profileViewAllDataDisabledStandard\',\'profilePermChangedCustom\',\'profilePermChangedStandard\',\'profileOlpChangedCustom\',\'profileOlpChangedStandard\',\'profileFlsChangedCustom\',\'profileFlsChangedStandard\',\'profileRecordTypeAddedCustom\',\'profileRecordTypeRemovedCustom\',\'profileRecordTypeAddedStandard\',\'profileRecordTypeRemovedStandard\',\'profileDefaultRecordTypeChangedCustom\',\'profileDefaultRecordTypeChangedStandard\',\'profilePageLayoutChangedCustom\',\'profilePageLayoutChangedStandard\',\'profileTabsetChangedCustom\',\'profileTabsetChangedStandard\',\'profileCustAppCustom\',\'profileCustAppStandard\',\'profileDefaultCustAppCustom\',\'profileDefaultCustAppStandard\',\'SetupEntityAccessAudit_Profile_ApexClass_EnabledCustom\',\'SetupEntityAccessAudit_Profile_ApexClass_DisabledCustom\',\'SetupEntityAccessAudit_Profile_ApexClass_EnabledStandard\',\'SetupEntityAccessAudit_Profile_ApexClass_DisabledStandard\',\'SetupEntityAccessAudit_Profile_ApexPage_EnabledCustom\',\'SetupEntityAccessAudit_Profile_ApexPage_DisabledCustom\',\'SetupEntityAccessAudit_Profile_ApexPage_EnabledStandard\',\'SetupEntityAccessAudit_Profile_ApexPage_DisabledStandard\',\'SetupEntityAccessAudit_Profile_ConnectedApplication_EnabledCustom\',\'SetupEntityAccessAudit_Profile_ConnectedApplication_DisabledCustom\',\'SetupEntityAccessAudit_Profile_ConnectedApplication_EnabledStandard\',\'SetupEntityAccessAudit_Profile_ConnectedApplication_DisabledStandard\',';
        String manageRoles = '\'createdrole\',\'deletedrole\',\'role\',';
        String managePermSets = '\'PermSetCreate\',\'PermSetCreateNoLicense\',\'PermSetClone\',\'PermSetCloneNoLicense\',\'PermSetLabelChange\',\'PermSetDeveloperNameChange\',\'PermSetDelete\',\'PermSetEnableUserPerm\',\'PermSetDisableUserPerm\',\'PermSetEntityPermChanged\',\'PermSetFlsChanged\',\'PermSetRecordTypeAdded\',\'PermSetTabSettingsChangedNew\',\'SetupEntityAccessAudit_PermissionSet_ApexClass_Enabled\',\'SetupEntityAccessAudit_PermissionSet_ApexClass_Disabled\',\'SetupEntityAccessAudit_PermissionSet_ApexPage_Enabled\',\'SetupEntityAccessAudit_PermissionSet_ApexPage_Disabled\',\'SetupEntityAccessAudit_PermissionSet_ConnectedApplication_Enabled\',\'SetupEntityAccessAudit_PermissionSet_ConnectedApplication_Disabled\',\'SetupEntityAccessAudit_PermissionSet_TabSet_Enabled\',\'SetupEntityAccessAudit_PermissionSet_TabSet_Disabled\',';
        String partnerRelationshipManagement = '\'createdpartneruser\',\'AccountPRMEnabled\',\'PRMUserDisabled\',';

        query = 'SELECT Action,CreatedByContext,CreatedById,CreatedByIssuer,CreatedDate,DelegateUser,Display,Id,ResponsibleNamespacePrefix,Section FROM SetupAuditTrail WHERE CreatedDate = ' + dateRange + ' AND Action NOT IN (' + reportingSnapshots + articleTypes + companyInformation + customObjects + businessProcess + customTabs + customizeAccounts + customizeActivities + customizeCampaigns + customizeCases + customizeContacts + customizeLeads + customizeOpportunities + customizeProducts + fieldDependencies + apiUsageNotification + dataManagement + groups + mobileAdministration + customerPortal + inboxMobileAndLegacyDesktopApps + manageUsers + manageUserMFA + manageProfiles + manageRoles + managePermSets + partnerRelationshipManagement.removeEnd(',') + ')';
        count = 0;
    }

    global Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext bc,List <SetupAuditTrail> listSAT) {
        List <Audit_Trail_Log__c> listATL = new List <Audit_Trail_Log__c> ();
        if (!listSAT.isEmpty()) {
            for (SetupAuditTrail theSAT : listSAT) {
                listATL.add(new Audit_Trail_Log__c (Action__c = theSAT.Action,Change_Detail__c = theSAT.Display,Delegate_User__c = theSAT.DelegateUser,Edit_Date__c = theSAT.CreatedDate,Section__c = theSAT.Section,SetupAuditTrail_Id__c = theSAT.Id,User__c = theSAT.CreatedById));
                count++;
            }
        } else {
            listATL.add(new Audit_Trail_Log__c (Empty_Scope__c = true));
        }
        if (!listATL.isEmpty()) {Database.insert(listATL,false);}
    }

    global void finish (Database.BatchableContext bc) {}
}