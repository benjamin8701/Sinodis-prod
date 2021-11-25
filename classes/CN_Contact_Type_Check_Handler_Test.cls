/**************************************************************************************************
 * Name           : CN_Contact_Type_Check_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Du Dezheng
 * Create Date    : 2021-10-14
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Contact_Type_Check_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void handleBeforeUpdateTest() {
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
            
            //Create Contact diretly ----by shuqi start
            account acc1 = new account();
            acc1.RecordTypeId = newDirectRTId;
            acc1.Name = 'Testacc1ount';
            acc1.CN_License_Name_EN__c = 'Testacc1ount';
            acc1.CN_Store_Name_EN__c = 'Testacc1ount';
            acc1.CN_Store_Name_CN__c = 'Testacc1ount';
            acc1.CN_Sales_District__c = '001';
            //acc1.CN_Customer_Group__c = '01';
            acc1.CN_Litigation_City__c = 'Dalian大连';
            acc1.CN_Category__c = 'BAPA';
            acc1.CN_Subcategory__c = 'access Bakery';
            acc1.CN_Province_CN__c = province.Id;
            acc1.CN_City_CN__c = city.Id;
            acc1.CN_Post_Code__c = '100000';
            acc1.CN_Delivery_Plant__c = 'P011';
            acc1.CN_Payment_Terms__c = 'D000';
            acc1.CN_Invoicing_Name_Bill_To_Party__c = 'D000';
            acc1.CN_Tax_Registration_No__c = '10000000';
            acc1.CN_Invoice_Type__c = 'General Invoice';
            acc1.CN_Invoicing_Address_EN__c = 'ABCDEF';
            acc1.CN_Reference_Day__c = 'Delivery_Day';
            acc1.CN_Business_Unit_UI__c = businessUnit.Id;
            acc1.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc1;
            //Create Contact diretly ----by shuqi end

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


            Test.startTest();

            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.CN_Contact_Type__c = '02';
            con.Title = 'CEO';
            con.CN_Department_Of_Contact_Person__c = '0001';
            con.CN_Contact_Name_EN__c = 'Test Contact';
            con.LastName = 'Contact';
            con.MobilePhone = '13013001300';
            con.CN_Bill_To_Address__c = 'ABCDE';
            insert con;
            
            Contact con_update = new Contact(
                Id = con.Id,
                CN_Contact_Type__c = '01;02'
            );
            update con_update;
            //Create Contact diretly ----by shuqi start
            Contact con_update1 = new Contact(
                Id = con.Id,
                AccountId = acc1.id
            );
            update con_update1;
            
            Contact con1 = new Contact();
            con1.AccountId = acc.Id;
            con1.CN_Contact_Type__c = '02';
            con1.Title = 'CEO';
            con1.CN_Department_Of_Contact_Person__c = '0001';
            con1.CN_Contact_Name_EN__c = 'Test Contact Type';
            con1.LastName = 'Contact';
            con1.MobilePhone = '12341234121';
            con1.CN_Bill_To_Address__c = 'ABCDE';
            insert con1;
            
            Contact con_update2 = new Contact(
                Id = con1.Id,
                CN_Contact_Type__c = '02;04'
            );
            update con_update2;
            
            Contact con2 = new Contact();
            con2.AccountId = acc1.Id;
            con2.CN_Contact_Type__c = '04';
            con2.Title = 'CEO';
            con2.CN_Department_Of_Contact_Person__c = '0001';
            con2.CN_Contact_Name_EN__c = 'Test Contact del';
            con2.LastName = 'Contact';
            con2.MobilePhone = '12344321121';
            con2.CN_Bill_To_Address__c = 'ABCDE';
            insert con2;
            
            Contact con_update3 = new Contact(
                Id = con2.Id,
                CN_Contact_Type__c = '02'
            );
            update con_update3;
            
            delete con2;
            //Create Contact diretly ----by shuqi end

            Test.stopTest();
        }
    }
}