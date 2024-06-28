/**************************************************************************************************
 * Name           : CN_User_Upsert_To_Mg_Batch_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2024-04-3
 * Modify History : 
 **************************************************************************************************/
@isTest
public class CN_User_Upsert_To_Mg_Batch_Test {
    static List<Lead> Leads = new List<Lead>();
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
        Trigger_Switcher_Setting__c setting = new Trigger_Switcher_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            EnableFlow__c = true,
            EnableTrigger__c = true,
            EnableValidationRule__c = false
        );
        insert setting;

        Talend_Setting__c talendSetting = new Talend_Setting__c(
            Sandbox_MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress',
            Sandbox_MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact',
            Sandbox_MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode',
            Sandbox_MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus',
            Sandbox_MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead',
            MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress',
            MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact',
            MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode',
            MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus',
            MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead',

            Sandbox_MG_Send_WeChat_Message__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_sendWeChatMessage',
            Sandbox_MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus',
            MG_Send_WeChat_Message__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_sendWeChatMessage',
            MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus',

            Sandbox_MG_Update_Case_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_multiupdate',
            Sandbox_MG_Update_Campaign__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_saveSfEvent',
            MG_Update_Campaign__c = 'http://127.0.0.1',
            Sandbox_MG_Update_CampaignMember__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_syncCustomerSegments',
            MG_Update_CampaignMember__c = 'http://127.0.0.1',

            Change_Request_Endpoint__c = 'http://127.0.0.1',
            Password__c = 'http://127.0.0.1',
            Sales_Order_Update_Endpoint__c = 'http://127.0.0.1',
            Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1',
            Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1',
            Sandbox_Password__c = 'http://127.0.0.1',
            Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1',
            Sandbox_User_Name__c = 'http://127.0.0.1',
            Send_to_Account_Endpoint__c = 'http://127.0.0.1',
            User_Name__c = 'http://127.0.0.1',
            Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1',
            Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1',
            Quote_Endpoint__c = 'http://127.0.0.1',
            Sandbox_Quote_Endpoint__c = 'http://127.0.0.1'
    );
    insert talendSetting;    
    }


    @isTest
    private static void handleBeforeUpdateTest() {
        TestDataFactory testDataFactory = new TestDataFactory();
        //testDataFactory.makeCustomSetting();
         //testDataFactory.makeTalendSetting();
         Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
    
        User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
        System.runAs(salesRep){
            CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
            insert fieldLock;
            Constants.CN_LEAD_STATUS_SEND_MG_HANDLER_TRIGGER_ON = false;
            Lead l1 = new Lead(
                CN_UniqueId__c = '200',
                Company = 'Test Class Lead',
                LastName  = 'Lead_Test_01',
                FirstName = 'Lead First Name',
                LeadSource = 'E-Commerce',
                CN_Customer_Category__c = 'Restaurant',
                Status = 'Open',
                MobilePhone = '15748484848',
                CN_Status_Change_Records__c = '[{"oldStatus":null,"owner":"Zhu Gloria","sale_email":null,"status":null,"uniqueId":"200","updateDate":"2023-12-05 17:35:18"}]',
                CN_Street__c = 'Lead Visit Address',
                CN_Zip_Postal_Code__c = '123456',
                OwnerId = salesRep.Id,
                CN_Field_Lock__c = null

            );
            insert l1; 
            

            // Lead l2 = new Lead(
            //     CN_UniqueId__c = '200',
            //     Company = 'Test Class Lead2',
            //     LastName  = 'Lead_Test_01',
            //     FirstName = 'Lead First Name',
            //     LeadSource = 'E-Commerce',
            //     CN_Customer_Category__c = 'Restaurant',
            //     Status = 'Open',
            //     MobilePhone = '15748484848',
            //     CN_Status_Change_Records__c = '[{"oldStatus":null,"owner":"Zhu Gloria","sale_email":null,"status":null,"uniqueId":"200","updateDate":"2023-12-05 17:35:18"}]',
            //     CN_Street__c = 'Lead Visit Address',
            //     CN_Zip_Postal_Code__c = '123456',
            //     OwnerId = salesRep.Id,
            //     CN_Field_Lock__c = null

            // );
            // insert l2; 
            System.debug('salesRep.salesRepId: ' + salesRep.Id);
            salesRep.Email = 'test@example.com'; 
            salesRep.IsActive = true;
            System.debug('l1.OwnerId: ' + l1.OwnerId);

        }
        
        Test.startTest();
        try{
        // 更新 User 对象需要在 System.runAs 块之外进行
        update salesRep;
        }catch(Exception ex){
            System.debug('Batch job failed: ' + ex.getMessage());
        }
        Test.stopTest();
        
        System.debug('salesRep.Email: ' + salesRep.Email);
        
        // 如果需要进行后续操作，请在 Test.stopTest() 之后执行
        
        // 如果需要进行后续操作，请在 Test.stopTest() 之后执行
        try {
            Database.executeBatch(new CN_User_Upsert_To_Mg_Batch());
        } catch (Exception ex) {
            System.debug('Batch job failed: ' + ex.getMessage());
        }
    }
}