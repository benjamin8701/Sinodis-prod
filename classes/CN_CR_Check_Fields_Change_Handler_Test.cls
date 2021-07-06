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
            CN_Sales_MDM_UserId__c = lastNameUserIdMap.get('SalesMDM')
        );
        insert approveSetting;

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];

        System.runAs(salesRep) {
            Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
            Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
            Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
            Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
            Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();

            Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();
            Account acc = new Account();
            acc.RecordTypeId = newDirectRTId;
            acc.Name = 'TestClass_Account';
            acc.CN_License_Name_EN__c = 'TestClass_Account';
            acc.CN_Store_Name_EN__c = 'TestClass_Account';
            acc.CN_Store_Name_CN__c = 'TestClass_Account';
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
            acc.CN_Invoicing_Address_and_Phone__c = 'ABCDEF';
            acc.CN_Invoicing_Address_and_Phone__c = 'ABCDEF';
            acc.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            acc.CN_Account_Status__c = 'New';
            acc.CN_Business_Unit_UI__c = businessUnit.Id;
            acc.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc;

            Account acc_second = new Account();
            acc_second.RecordTypeId = newDirectRTId;
            acc_second.Name = '测试二';
            acc_second.CN_License_Name_EN__c = '测试二';
            acc_second.CN_Store_Name_EN__c = '测试二';
            acc_second.CN_Store_Name_CN__c = '测试二';
            acc_second.CN_Sales_District__c = '001';
            //acc_second.CN_Customer_Group__c = '01';
            acc_second.CN_Category__c = 'BAPA';
            acc_second.CN_Subcategory__c = 'Access Bakery';
            acc_second.CN_Province_CN__c = province.Id;
            acc_second.CN_City_CN__c = city.Id;
            acc_second.CN_Post_Code__c = '100000';
            acc_second.CN_Delivery_Plant__c = 'P011';
            acc_second.CN_Payment_Terms__c = 'D000';
            acc_second.CN_Invoicing_Name_Bill_To_Party__c = 'D000';
            acc_second.CN_Tax_Registration_No__c = '10000011';
            acc_second.CN_Invoice_Type__c = 'General Invoice';
            acc_second.CN_Invoicing_Address_and_Phone__c = 'ABC';
            acc_second.CN_Invoicing_Address_and_Phone__c = 'ABC';
            acc_second.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            acc_second.CN_Account_Status__c = 'New';
            acc_second.CN_Business_Unit_UI__c = businessUnit.Id;
            acc_second.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc_second;

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

            CN_Document__c doc_b2 = new CN_Document__c();
            doc_b2.CN_Account__c = acc_second.Id;
            doc_b2.CN_Document_Type__c = Constants.CN_DOCUMENT_TYPE_BUSINESS_LICENSE;
            doc_b2.CN_Is_File_Upload__c = true;
            insert doc_b2;

            CN_Document__c doc_f2 = new CN_Document__c();
            doc_f2.CN_Account__c = acc_second.Id;
            doc_f2.CN_Document_Type__c = Constants.CN_DOCUMENT_TYPE_FAPIAO_INFORMATION;
            doc_f2.CN_Is_File_Upload__c = true;
            insert doc_f2;

            Id conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();
            Contact con2 = new Contact();
            con2.RecordTypeId = conRTId;
            con2.AccountId = acc_second.Id;
            con2.CN_Contact_Type__c = '01;02';
            con2.Title = 'Contact Title2';
            con2.CN_Bill_To_Address__c = 'Bill to Address2';
            con2.LastName = 'Test acc_second Contact 01';
            con2.CN_Contact_Name_EN__c = 'Test Contact Name 01';
            con2.CN_Department_Of_Contact_Person__c = '0002';
            con2.MobilePhone = '15755555225';
            insert con2;

            Integer num = 3;
            List<Contact> conList = new List<Contact>();
            for(integer n = 0 ; n < num ; n++){
                Contact con = new Contact();
                con.RecordTypeId = conRTId;
                con.AccountId = acc.Id;
                con.CN_Contact_Type__c = '01;02';
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
            sh.CN_Sold_To_Party_Customer__c = acc.Id;
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
            acc_update1.Id = acc.Id;
            acc_update1.CN_Account_Status__c = 'Ready for Approval';
            update acc_update1;

            Account acc_update2 = new Account();
            acc_update2.Id = acc.Id;
            acc_update2.CN_Account_Status__c = 'Submitted for Approval';
            update acc_update2;

            Account acc_update3 = new Account();
            acc_update3.Id = acc.Id;
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
            system.debug('acc_select.recordtypeId:    ' + acc_select.recordtypeId);
            system.debug('acc_select.syncstatus:    ' + acc_select.CN_Sync_Status__c);



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
            cr1_update.New_CN_Contact_Type__c = '01;02;04';
            cr1_update.New_CN_Contact_License_Name__c = acc_second.Id;
            cr1_update.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_READY_FOR_APPROVAL;
            crList_update.add(cr1_update);

            CN_Change_Request__c cr2_update = new CN_Change_Request__c();
            cr2_update.id = crList[num_update++].Id;
            cr2_update.New_CN_Contact_Type__c = '01;02;04';
            crList_update.add(cr2_update);

            update crList_update;



            Test.stopTest();
        }
    }

}