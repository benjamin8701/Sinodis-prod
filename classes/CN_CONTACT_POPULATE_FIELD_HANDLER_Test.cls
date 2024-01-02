/**************************************************************************************************
 * Name           : CN_CONTACT_POPULATE_FIELD_HANDLER_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_CONTACT_POPULATE_FIELD_HANDLER_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void contact_Populate_Test() {
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        Trigger_Switcher_Setting__c setting = new Trigger_Switcher_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            EnableFlow__c = true,
            EnableTrigger__c = true,
            EnableValidationRule__c = true
        );
        insert setting;

        CN_Approve_Process_Settings__c approveSetting = new CN_Approve_Process_Settings__c(
            CN_CEO_UserId__c = lastNameUserIdMap.get('CEO'),
            CN_CFO_UserId__c = lastNameUserIdMap.get('CFO'),
            CN_Finance_AR_UserId__c = lastNameUserIdMap.get('FinanceAR'),
            CN_Finance_MDM_UserId__c = lastNameUserIdMap.get('FinanceMDM'),
            CN_Sales_MDM_UserId__c = lastNameUserIdMap.get('SalesMDM'),
			CN_WholeSales_Development_Supervisor__c = lastNameUserIdMap.get('WholeSalesDevelopmentSupervisor')
        );
        insert approveSetting;

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        
        System.runAs(salesRep) {
            Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();
            Id editDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_DIRECT).getRecordTypeId();
            Id newInDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_INDIRECT).getRecordTypeId();
            Account acc = new Account();
            acc.RecordTypeId = newDirectRTId;
            acc.Name = 'TestAccount';
            acc.CN_License_Name_EN__c = 'TestAccount';
            acc.CN_Store_Name_EN__c = 'TestAccount';
            acc.CN_Store_Name_CN__c = 'TestAccount';
            acc.CN_Sales_District__c = '001';
            //acc.CN_Customer_Group__c = '01';
            acc.CN_Category__c = 'BAPA';
            acc.CN_Subcategory__c = 'Access Bakery';
            acc.CN_Province_CN__c = province.Id;
            acc.CN_City_CN__c = city.Id;
            acc.CN_Post_Code__c = '100000';
            acc.CN_Delivery_Plant__c = 'P011';
            acc.CN_Payment_Terms__c = 'D000';
            acc.CN_Invoicing_Name_Bill_To_Party__c = 'D000';
            acc.CN_Tax_Registration_No__c = '10000000';
            acc.CN_Invoice_Type__c = 'General Invoice';
            acc.CN_Invoicing_Address_EN__c = 'ABCDEF';
            acc.CN_Reference_Day__c = 'Delivery_Day';
            acc.CN_Business_Unit_UI__c = businessUnit.Id;
            acc.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc;

            CN_Document__c doc_b = new CN_Document__c();
            doc_b.CN_Account__c = acc.Id;
            doc_b.CN_Document_Type__c = Constants.CN_DOCUMENT_TYPE_BUSINESS_LICENSE;
            doc_b.CN_Is_File_Upload__c = true;
            insert doc_b;

            CN_Document__c doc_f = new CN_Document__c();
            doc_f.CN_Account__c = acc.Id;
            doc_f.CN_Document_Type__c = Constants.CN_DOCUMENT_TYPE_FAPIAO_INFORMATION;
            doc_f.CN_Is_File_Upload__c = true;
            insert doc_f;

            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.CN_Contact_Type__c = '01;02';
            con.Title = 'CEO';
            con.CN_Department_Of_Contact_Person__c = '0001';
            con.CN_Contact_Name_EN__c = 'Test Contact';
            con.LastName = 'Contact';
            con.MobilePhone = '13013001300';
            con.CN_Bill_To_Address__c = 'ABCDE';
            insert con;

            Contact con2 = new Contact();
            con2.AccountId = acc.Id;
            con2.CN_Contact_Type__c = '02';
            con2.Title = 'CEO';
            con2.CN_Department_Of_Contact_Person__c = '0002';
            con2.CN_Contact_Name_EN__c = 'Test Contact1';
            con2.LastName = 'Contact1';
            con2.MobilePhone = '13013801300';
            con2.CN_Bill_To_Address__c = 'ABCDEF';
            insert con2;

            con.CN_Contact_Type__c = '01;02;04';
            update con;

            delete con2;

            undelete con2;
        }
    }
}