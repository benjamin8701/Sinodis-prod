/**************************************************************************************************
 * Name           : CN_ShipTo_Prevent_Delete_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-15
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_ShipTo_Prevent_Delete_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeUpdate() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        System.runAs(salesRep) {
            Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
            Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
            Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
            Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
            Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();

            Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();

            Id shipToRTId = Schema.SObjectType.CN_Ship_to_Party__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SHIPTO_RT_API_NAME).getRecordTypeId();
            CN_Ship_to_Party__c sh = new CN_Ship_to_Party__c();
            sh.RecordTypeId = shipToRTId;
            sh.CN_Sold_To_Party_Customer__c = acc_factory.Id;
            sh.CN_City_CN__c = city.Id;
            sh.CN_Province_CN__c = province.Id;
            sh.CN_Customer_Type__c = '0001';
            sh.CN_Customer_Name__c = 'Test ShipTo 01';
            sh.CN_Delivery_Plant__c = 'P011';
            sh.CN_Delivery_Address_EN__c  = 'Addresss EN';
            sh.CN_Delivery_Address_CN__c  = 'Addresss CN';
            sh.CN_Contact_Name__c = 'Contact Name';
            sh.CN_Telephone__c = '15755555555';
            sh.CN_Mobile_Phone__c = '15755555555';
            insert sh;

            Account acc_update1 = new Account();
            acc_update1.Id = acc_factory.Id;
            acc_update1.CN_Account_Status__c = 'Ready for Approval';
            update acc_update1;

            Account acc_update2 = new Account();
            acc_update2.Id = acc_factory.Id;
            acc_update2.CN_Account_Status__c = 'Submitted for Approval';
            update acc_update2;

            Account acc_update3 = new Account();
            acc_update3.Id = acc_factory.Id;
            acc_update3.CN_Account_Status__c = 'Approved';
            update acc_update3;

            test.startTest();
            
            CN_Ship_to_Party__c sh_delete = new CN_Ship_to_Party__c();
            sh_delete.Id = sh.Id;
            try{
                delete sh_delete;
            }catch(exception e){

            }
            

            test.stopTest();
        }
    }
}