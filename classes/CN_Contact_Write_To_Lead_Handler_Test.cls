/**************************************************************************************************
 * Name           : CN_Contact_Write_To_Lead_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-10-13
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Contact_Write_To_Lead_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void handleAfterInsert() {
        TestDataFactory testFactory = new TestDataFactory();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }

        User salesRep = lastNameUserMap.get('Sales1');
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];

        Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();
        Id editDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_DIRECT).getRecordTypeId();
        Id newInDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_INDIRECT).getRecordTypeId();
        Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
        Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();

        List<Account> accList = testFactory.makeAccounts(1);
        Account acc = accList[0];

        Test.startTest();
        testFactory.approveAccount(accList);

        System.runAs(salesRep) {
        
            Lead l = new Lead(
                recordTypeId = cnLeadRTId,
                Company = 'Test Class Lead',
                LastName  = 'Lead last Name',
                FirstName = 'Lead First Name',
                LeadSource = 'Website',
                CN_Customer_Category__c = 'Restaurant',
                Status = 'Open',
                MobilePhone = '15748484848',
                CN_Province__c = province.Id,
                CN_City__c = city.Id,
                CN_Street__c = 'Lead Visit Address',
                CN_Zip_Postal_Code__c = '123456',
                OwnerId = salesRep.Id
            );
            insert l;

            CN_Change_Request__c cr = new CN_Change_Request__c();
            cr.RecordTypeId = newContactRTId;
            cr.New_CN_Contact_Type__c = '04';
            cr.New_CN_Contact_License_Name__c = acc.Id;
            cr.New_CN_Contact_Title__c = 'CR Contact Title';
            cr.New_CN_Contact_Dept_Of_Contact_Person__c = '0002';
            cr.New_CN_Contact_CN_First_Name__c = 'Contact 01';
            cr.New_CN_Contact_CN_Last_Name__c = 'Test CR';
            cr.New_CN_Contact_Name_EN__c = 'Test CR Contact Name 01';
            cr.New_CN_Contact_Mobile__c = '15755555551';
            cr.New_CN_Contact_Billing_To_Address__c = 'CR Bill to Address';
            cr.CN_Is_Generate_From_Action__c = true;
            insert cr;


            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.CN_Contact_Type__c = '04';
            con.Title = 'CEO';
            con.CN_Department_Of_Contact_Person__c = '0001';
            con.CN_Contact_Name_EN__c = 'Test Contact Write Back To Lead';
            con.LastName = 'Write Back To Lead Contact';
            con.MobilePhone = '13058585858';
            con.CN_Bill_To_Address__c = 'ABCDE';
            con.CN_Converted_From__c = l.Id;
            con.CN_Change_Request__c = cr.Id;
            insert con;

            Test.stopTest();
        }
    }
}