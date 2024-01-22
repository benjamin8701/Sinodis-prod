/**************************************************************************************************
 * Name           : CN_CR_Write_Back_To_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-10
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_CR_Write_Back_To_Handler_Test {
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
            EnableValidationRule__c = false
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
            Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
            Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
            Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
            Id appUpdateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_ACCOUNT).getRecordTypeId();
            Id appUpdateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_CONTACT).getRecordTypeId();
            Id appUpdateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_SHIPTO).getRecordTypeId();

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

            Id conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();
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
            insert con;

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
            acc_update3.CN_Account_Status__c = 'Approved';
            update acc_update3;

            List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
            CN_Change_Request__c cr1 = new CN_Change_Request__c();
            Map<String, Object> AccountCR_LC_Ctrl_ResultMap = CN_Account_Change_Request_LCController.getAccount(acc.Id);
            for(String field : ((Map<String, String>)AccountCR_LC_Ctrl_ResultMap.get('fieldMap')).keySet()){
                Account acc_source = (Account)AccountCR_LC_Ctrl_ResultMap.get('sourceAccount');
                cr1.put(field,acc_source.get( ((Map<String, String>)AccountCR_LC_Ctrl_ResultMap.get('fieldMap')).get(field)));
            }
            cr1.CN_Account_Name__c = acc.Id;
            cr1.New_CN_Account_License_Name_EN__c = 'TestClass_Account_update';
            cr1.CN_Is_Generate_From_Action__c = true;
            cr1.RecordTypeId = updateAccountRTId;
            crList.add(cr1);

            CN_Change_Request__c cr2 = new CN_Change_Request__c();
            Map<String, Object> contactCR_LC_Ctrl_ResultMap = CN_Contact_Change_Request_LC_Ctrl.getContact(con.Id);
            for(String field : ((Map<String, String>)contactCR_LC_Ctrl_ResultMap.get('fieldMap')).keySet()){
                Contact con_source = (Contact)contactCR_LC_Ctrl_ResultMap.get('sourceContact');
                cr2.put(field,con_source.get(((Map<String, String>)contactCR_LC_Ctrl_ResultMap.get('fieldMap')).get(field)));
            }
            cr2.CN_Contact__c = con.Id;
            cr2.CN_Is_Generate_From_Action__c = true;
            cr2.New_CN_Contact_CN_Last_Name__c = 'Test CR_update';
            cr2.RecordTypeId = updateContactRTId;
            crList.add(cr2);

            CN_Change_Request__c cr3 = new CN_Change_Request__c();
            Map<String, Object> shipToCR_LC_Ctrl_ResultMap = CN_Shipto_Change_Request_LC_Ctrl.getShipTo(sh.Id);
            for(String field : ((Map<String, String>)shipToCR_LC_Ctrl_ResultMap.get('fieldMap')).keySet()){
                CN_Ship_to_Party__c shipTo_source = (CN_Ship_to_Party__c)shipToCR_LC_Ctrl_ResultMap.get('sourceShipTo');
                cr3.put(field,shipTo_source.get( ((Map<String, String>)shipToCR_LC_Ctrl_ResultMap.get('fieldMap')).get(field))) ;
            }
            cr3.CN_Account_Name__c = acc.Id;
            cr3.CN_Ship_To_Party__c = sh.Id;
            cr3.CN_Is_Generate_From_Action__c = true;
            cr3.New_CN_ShipTo_Contact_Name__c = 'CR Contact Name_update';
            cr3.RecordTypeId = updateShiptoRTId;
            crList.add(cr3);

            insert crLIst;

            Test.startTest();
            List<CN_Change_Request__c> CRList_update = new List<CN_Change_Request__c>();
            for(CN_Change_Request__c cr : crList){
                CN_Change_Request__c cr_update = new CN_Change_Request__c();
                cr_update.id = cr.Id;
                cr_update.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_READY_FOR_APPROVAL;
                CRList_update.add(cr_update);
            }
            try{
                update CRList_update;
            }catch(Exception e){}
                
            

            List<CN_Change_Request__c> CRList_update2 = new List<CN_Change_Request__c>();
            for(CN_Change_Request__c cr : crList){
                CN_Change_Request__c cr_update = new CN_Change_Request__c();
                cr_update.id = cr.Id;
                cr_update.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_SUBMITTED_FOR_APPROVAL;
                cr_update.CN_Approve_Step__c = 'step1';
                cr_update.CN_Sync_Status__c  = Constants.CN_CR_SYNC_STATUS_SUCCESS;
                CRList_update2.add(cr_update);
            }
            List<CN_Change_Request__c> crList_Select = [Select id,CN_Sync_Status__c from CN_Change_Request__c where id = :CRList_update2[0].id ];
            system.debug('crList_Select[0]  :   ' + crList_Select[0].CN_Sync_Status__c);
            update CRList_update2;
            List<CN_Change_Request__c> crList_Select2 = [Select id,CN_Sync_Status__c from CN_Change_Request__c where id = :CRList_update2[0].id ];
            system.debug('crList_Select2[0]  :   ' + crList_Select2[0].CN_Sync_Status__c);
            system.debug('CN_Sync_Status__c  :   ' + cr3.CN_Sync_Status__c);
                
            

            List<CN_Change_Request__c> CRList_update3 = new List<CN_Change_Request__c>();
            for(CN_Change_Request__c cr : crList){
                CN_Change_Request__c cr_update = new CN_Change_Request__c();
                cr_update.id = cr.Id;
                cr_update.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_APPROVALED;
                if(cr.recordtypeId == updateAccountRTId){
                    cr_update.recordTypeId = appUpdateAccountRTId;
                }else if(cr.recordtypeId == updateContactRTId){
                    cr_update.recordTypeId = appUpdateContactRTId;
                }else if(cr.recordtypeId == updateShiptoRTId){
                    cr_update.recordTypeId = appUpdateShiptoRTId;
                }
                CRList_update3.add(cr_update);
            }
            
                update CRList_update3;
            

            Test.stopTest();
        }
    }

    //add by leo
    @isTest
    private static void handleWriteBackContactType() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeAccounts(10,false);
        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        Account acc = [SELECT Id FROM Account WHERE CN_MG_Account_ID__c = '1'];
        acc.CN_Sync_Status__c = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
        update acc;

        Id crRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_APPD_UPDATE_CONTACT).getRecordTypeId();
        Contact contact = [SELECT Id FROM Contact WHERE CN_MG_Contact_ID__c = '1'];
        System.runAs(salesRep){
            CN_Change_Request__c cr = new CN_Change_Request__c();

            Map<String, Object> cR_LC_Ctrl_ResultMap = CN_Contact_Change_Request_LC_Ctrl.getContact(contact.Id);
            for(String field : ((Map<String, String>)cR_LC_Ctrl_ResultMap.get('fieldMap')).keySet()){
                Contact con_source = (Contact)cR_LC_Ctrl_ResultMap.get('sourceContact');
                cr.put(field,con_source.get(((Map<String, String>)cR_LC_Ctrl_ResultMap.get('fieldMap')).get(field)));
            }

            Trigger_Switcher_Setting__c setting = new Trigger_Switcher_Setting__c(
                    SetupOwnerId = UserInfo.getOrganizationId(),
                    EnableFlow__c = true,
                    EnableTrigger__c = true,
                    EnableValidationRule__c = false
            );
            insert setting;

            cr.CN_Is_Generate_From_Action__c = true;
            cr.RecordTypeId = crRTId;
            cr.OwnerId = salesRep.Id;
            cr.CN_Contact_Type__c = '01;02';
            cr.New_CN_Contact_Type__c = '02';
            cr.CN_External_Id__c = contact.Id;
            cr.CN_Contact__c = contact.Id;
            insert cr;

            try {
                cr.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_APPROVALED;
                update cr;
            } catch (Exception e) {

            }

            try {
                cr.CN_Contact_Type__c = '02';
                cr.New_CN_Contact_Type__c = '01;02';
                update cr;
            } catch (Exception e) {

            }
        }


    }
}