/**************************************************************************************************
 * Name           : CN_CR_Contact_Type_Check_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-10-14
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_CR_Contact_Type_Check_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void handleBeforeUpdateTest() {
        TestDataFactory testFactory = new TestDataFactory();

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
            Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
            Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
            Id contactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CN_CONTACT_RT_API_NAME).getRecordTypeId();

            Account acc = new Account();
            acc.RecordTypeId = newDirectRTId;
            acc.Name = 'TestAccount';
            acc.CN_License_Name_EN__c = 'TestAccount';
            acc.CN_Store_Name_EN__c = 'TestAccount';
            acc.CN_Store_Name_CN__c = 'TestAccount';
            acc.CN_Sales_District__c = '001';
            acc.CN_Litigation_City__c = 'Dalian大连';
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


            List<Contact> con_List = new List<Contact>();
            Integer num_contact = 3;
            for(Integer n=0 ; n<num_contact ; n++ ){
                Contact con = new Contact();
                con.recordTypeId = contactRTId;
                con.AccountId = acc.Id;
                con.Title = 'CEO';
                con.CN_Department_Of_Contact_Person__c = '0001';
                con.CN_Contact_Name_EN__c = 'Test Contact';
                con.LastName = 'Contact';
                con.MobilePhone = '13013001300';
                con.CN_Bill_To_Address__c = 'ABCDE';
                con_List.add(con);
            }
            con_List[0].CN_Contact_Type__c = '01;04';
            con_List[1].CN_Contact_Type__c = '04';
            con_List[2].CN_Contact_Type__c = '02';
            
            insert con_List;
            
            Test.startTest();
            testFactory.approveAccount(acc);

            CN_Change_Request__c cr = new CN_Change_Request__c();
            cr.RecordTypeId = newContactRTId;
            cr.New_CN_Contact_Type__c = '01';
            cr.New_CN_Contact_License_Name__c = acc.Id;
            cr.New_CN_Contact_Title__c = 'CR Contact Title';
            cr.New_CN_Contact_Dept_Of_Contact_Person__c = '0002';
            cr.New_CN_Contact_CN_First_Name__c = 'Contact 01';
            cr.New_CN_Contact_CN_Last_Name__c = 'Test CR';
            cr.New_CN_Contact_Name_EN__c = 'Test CR Contact Name 01';
            cr.New_CN_Contact_Mobile__c = '15755555551';
            cr.New_CN_Contact_Billing_To_Address__c = 'CR Bill to Address';
            cr.CN_Is_Generate_From_Action__c = true;

            try {
                insert cr;
            } catch (Exception e ) {}

            List<CN_Change_Request__c> crList_insert = new List<CN_Change_Request__c>();
            for(Integer n=0; n<num_contact ; n++){
                CN_Change_Request__c cr_insert = new CN_Change_Request__c();
                Map<String, Object> contactCR_LC_Ctrl_ResultMap = CN_Contact_Change_Request_LC_Ctrl.getContact(con_List[n].Id);
                for(String field : ((Map<String, String>)contactCR_LC_Ctrl_ResultMap.get('fieldMap')).keySet()){
                    Contact con_source = (Contact)contactCR_LC_Ctrl_ResultMap.get('sourceContact');
                    cr_insert.put(field,con_source.get(((Map<String, String>)contactCR_LC_Ctrl_ResultMap.get('fieldMap')).get(field)));
                }
                cr_insert.RecordTypeId = updateContactRTId;
                cr_insert.CN_Is_Generate_From_Action__c = true;
                cr_insert.CN_Contact__c = con_List[n].Id;
                cr_insert.New_CN_Contact_CN_Last_Name__c = 'Test CR_update';
                crList_insert.add(cr_insert);
            }
            crList_insert[0].New_CN_Contact_Type__c = '04';
            crList_insert[1].New_CN_Contact_Type__c = '01;02';
            crList_insert[2].New_CN_Contact_Type__c = '04';

            try {
                insert crList_insert;
            } catch (Exception e ) {}
            

            Integer num_cr = 3;
            List<CN_Change_Request__c> crList_insert2 = new List<CN_Change_Request__c>();
            for(Integer n=0 ; n< num_cr ;n++){
                CN_Change_Request__c cr_insert2 = new CN_Change_Request__c();
                cr_insert2.RecordTypeId = newContactRTId;
                cr_insert2.New_CN_Contact_License_Name__c = acc.Id;
                cr_insert2.New_CN_Contact_Title__c = 'CR Contact Title';
                cr_insert2.New_CN_Contact_Dept_Of_Contact_Person__c = '0002';
                cr_insert2.New_CN_Contact_CN_First_Name__c = 'Contact 10141141';
                cr_insert2.New_CN_Contact_CN_Last_Name__c = 'Test CR';
                cr_insert2.New_CN_Contact_Name_EN__c = 'Test CR Contact Name 01';
                cr_insert2.New_CN_Contact_Mobile__c = '15755555551';
                cr_insert2.New_CN_Contact_Billing_To_Address__c = 'CR Bill to Address';
                cr_insert2.CN_Is_Generate_From_Action__c = true;
                crList_insert2.add(cr_insert2);
            }
            crList_insert2[0].New_CN_Contact_Type__c = '04';
            crList_insert2[1].New_CN_Contact_Type__c = '01';
            crList_insert2[2].New_CN_Contact_Type__c = '02';
            Constants.CN_CR_TRIGGER_ON = false;
            insert crList_insert2;
            Constants.CN_CR_TRIGGER_ON = true;

            CN_Change_Request__c cr_update1 = new CN_Change_Request__c(
                Id = crList_insert2[0].Id,
                RecordTypeId = updateContactRTId,
                New_CN_Contact_Type__c = '01'
            );
            try {
                update cr_update1;
            } catch (Exception e) {}
            CN_Change_Request__c cr_update2 = new CN_Change_Request__c(
                Id = crList_insert2[1].Id,
                RecordTypeId = updateContactRTId,
                New_CN_Contact_Type__c = '04'
            );
            try {
                update cr_update2;
            } catch (Exception e) {}
            CN_Change_Request__c cr_update3 = new CN_Change_Request__c(
                Id = crList_insert2[2].Id,
                RecordTypeId = updateContactRTId,
                New_CN_Contact_Type__c = '04'
            );
            try {
                update cr_update3;
            } catch (Exception e) {}
            

            Test.stopTest();
        }
    }
}