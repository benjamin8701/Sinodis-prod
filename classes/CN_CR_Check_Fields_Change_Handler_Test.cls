/**************************************************************************************************
 * Name           : CN_CR_Check_Fields_Change_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-11
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_CR_Check_Fields_Change_Handler_Test {
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
        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];

        System.runAs(salesRep) {
            Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
            Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
            Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
            Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
            Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();
            ID conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();

            List<Account> accList_second = testFactory.makeAccounts(1,false);
            Account acc_second = accList_second[0];
            Integer num = 3;
            List<Contact> conList = new List<Contact>();
            for(integer n = 0 ; n < num ; n++){
                Contact con = new Contact();
                con.RecordTypeId = conRTId;
                con.AccountId = acc_factory.Id;
                con.CN_Contact_Type__c = '04';
                con.Title = 'Contact Title';
                con.CN_Bill_To_Address__c = 'Bill to Address';
                con.LastName = 'Test Contact 01';
                con.CN_Contact_Name_EN__c = 'Test Contact Name 01';
                con.CN_Department_Of_Contact_Person__c = '0002';
                con.MobilePhone = '15755555555';
                conList.add(con);
            }
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = true;
            Database.SaveResult[] srList = Database.insert(conList, dml);

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

            CN_Ship_to_Party__c sh2 = new CN_Ship_to_Party__c();
            sh2.RecordTypeId = shipToRTId;
            sh2.CN_Sold_To_Party_Customer__c = acc_second.Id;
            sh2.CN_City_CN__c = city.Id;
            sh2.CN_Province_CN__c = province.Id;
            sh2.CN_Customer_Type__c = '0001';
            sh2.CN_Customer_Name__c = 'Test ShipTo 01';
            sh2.CN_Delivery_Plant__c = 'P011';
            sh2.CN_Delivery_Address_EN__c  = 'Addresss EN';
            sh2.CN_Delivery_Address_CN__c  = 'Addresss CN';
            sh2.CN_Contact_Name__c = 'Contact Name';
            sh2.CN_Telephone__c = '15755555555';
            sh2.CN_Mobile_Phone__c = '15755555555';
            insert sh2;

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
            acc_update3.CN_Sync_Status__c = 'Success';
            acc_update3.CN_Account_Status__c = 'Approved';
            acc_update3.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_APPROVE_DIRECT).getRecordTypeId();
            update acc_update3;

            Account acc_update2_1 = new Account();
            acc_update2_1.Id = acc_second.Id;
            acc_update2_1.CN_Account_Status__c = 'Ready for Approval';
            update acc_update2_1;

            Account acc_update2_2 = new Account();
            acc_update2_2.Id = acc_second.Id;
            acc_update2_2.CN_Account_Status__c = 'Submitted for Approval';
            update acc_update2_2;

            Account acc_update2_3 = new Account();
            acc_update2_3.Id = acc_second.Id;
            acc_update2_3.CN_Account_Status__c = 'Approved';
            acc_update2_3.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_APPROVE_DIRECT).getRecordTypeId();
            update acc_update2_3;
            Account acc_select = [select id,recordTypeId,CN_Sync_Status__c From Account where id = :acc_update2_3.Id];

            List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
            for(Contact con : conList){
                CN_Change_Request__c cr = new CN_Change_Request__c();
                Map<String, Object> contactCR_LC_Ctrl_ResultMap = CN_Contact_Change_Request_LC_Ctrl.getContact(con.Id);
                for(String field : ((Map<String, String>)contactCR_LC_Ctrl_ResultMap.get('fieldMap')).keySet()){
                    Contact con_source = (Contact)contactCR_LC_Ctrl_ResultMap.get('sourceContact');
                    cr.put(field,con_source.get(((Map<String, String>)contactCR_LC_Ctrl_ResultMap.get('fieldMap')).get(field)));
                }
                cr.CN_Contact__c = con.Id;
                cr.CN_Is_Generate_From_Action__c = true;
                cr.New_CN_Contact_CN_Last_Name__c = 'Test CR_update';
                cr.RecordTypeId = updateContactRTId;
                crList.add(cr);
            }
            
            Test.startTest();

            insert crList;

            integer num_update = 0;
            List<CN_Change_Request__c> crList_update = new List<CN_Change_Request__c>();
            CN_Change_Request__c cr1_update = new CN_Change_Request__c();
            cr1_update.id = crList[num_update++].Id;
            cr1_update.New_CN_Contact_Type__c = '04';
            cr1_update.New_CN_Contact_License_Name__c = acc_second.Id;
            cr1_update.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_READY_FOR_APPROVAL;
            crList_update.add(cr1_update);

            CN_Change_Request__c cr2_update = new CN_Change_Request__c();
            cr2_update.id = crList[num_update++].Id;
            cr2_update.New_CN_Contact_Type__c = '04';
            cr2_update.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_READY_FOR_APPROVAL;
            crList_update.add(cr2_update);

            CN_Change_Request__c cr3_update = new CN_Change_Request__c();
            cr3_update.id = crList[num_update++].Id;
            cr3_update.CN_ShipTo_Sold_To_Party_Customer__c = acc_factory.Id;
            cr3_update.New_CN_Contact_Type__c = '04';
            cr1_update.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_READY_FOR_APPROVAL;
            crList_update.add(cr3_update);

            try {
                update crList_update;
            } catch (Exception e) {}
            

            Test.stopTest();
        }
    }

}