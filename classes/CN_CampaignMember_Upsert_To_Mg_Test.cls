/*
 * ************************************************************************************************
 * Name : CN_CampaignMember_Upsert_To_Mg_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Zhang Zhihao
 * Create Date : 2024/4/2
 * Modify History :
 * ************************************************************************************************
 */
@IsTest
public class CN_CampaignMember_Upsert_To_Mg_Test {
    @TestSetup
	static void makeData(){
		TestDataFactory.makeBaseData();
	}


    @IsTest
	private static void insertOrDeleteTest(){
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        testFactory.makeTalendSetting();
        Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Contact con_factory = [SELECT Id, Name FROM Contact WHERE AccountId =: acc_factory.Id];

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        List<Product2> SKUList = [SELECT Id FROM Product2];

        Campaign cam = testFactory.makeCampaign();
        insert cam;

        CN_Campaign_Product__c cp = new CN_Campaign_Product__c();
        cp.CN_Campaign__c = cam.Id;
        cp.CN_Product__c = SKUList[0].Id;
        insert cp;

        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.CampaignId = cam.Id;
        cms.Label = Constants.CN_CM_STATUS_ATTENDED;
        // cms.SortOrder = 1;
        cms.IsDefault = true;
        cms.HasResponded = true;
        insert cms;

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cam.Id;
        cm.AccountId = acc_factory.Id;
        cm.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm;

        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = cam.Id;
        cm1.ContactId = con_factory.Id;
        cm1.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm1;
       
        List<CampaignMember> deletList = new List<CampaignMember>();
        deletList.add(cm1);
        if(deletList.size()>0){
            delete deletList;
        }

      



    }

    // @IsTest
	// private static void AfterUpdateHandle(){
    //     TestDataFactory testFactory = new TestDataFactory();
    //     testFactory.makeCustomSetting();
    //     testFactory.makeAccounts(2,true);
    //     testFactory.makeTalendSetting();
    //     Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
    //     Account acc_factory1 = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][1];
    //     Contact con_factory = [SELECT Id, Name FROM Contact WHERE AccountId =: acc_factory.Id];
    //     System.debug('acc_factory1===>'+acc_factory1.id);

    //     List<User> userList = [SELECT Id, LastName FROM User];
    //     Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
    //     for(User usr: userList) {
    //         lastNameUserIdMap.put(usr.LastName, usr.Id);
    //     }

    //     Campaign cam = testFactory.makeCampaign();
    //     insert cam;

    //     CampaignMember cm = new CampaignMember();
    //     cm.CampaignId = cam.Id;
    //     cm.AccountId = acc_factory.Id;
    //     cm.Status = Constants.CN_CM_STATUS_ATTENDED;
    //     insert cm;


    //     cm.AccountId = acc_factory1.id;
    //     upsert cm;
       
    // }




    @IsTest
	private static void timedTask(){
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        testFactory.makeTalendSetting();
        Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        List<Campaign> camps = new List<Campaign>();
        Campaign camTest = new Campaign();
        Id camRTId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('CN_Campaign').getRecordTypeId();
        camTest.RecordTypeId = camRTId;
        camTest.Name = '200';
        camTest.Status = 'Planned';
        camTest.Type = 'Corporate Event';
        camTest.StartDate = Date.today().addMonths(3);
        camTest.EndDate = Date.today().addMonths(3).addDays(13);
        camTest.CN_Execution_Type__c = 'Public Demonstration';
        camTest.CN_Channel__c = 'KA';
        camTest.CN_Customer_Category__c = 'BAPA';
        camTest.CN_Product_Category__c = 'Dairy';
        camTest.CN_Product_Type__c = 'CHEESE';
        camTest.CN_Brand__c = '5J';
        insert camTest;      

        
        List<CampaignMember> capms = new List<CampaignMember>();
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = camTest.Id;
        cm.AccountId = acc_factory.Id;
        cm.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm;

        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
		Database.executeBatch(new CN_CampaignMember_Upsert_To_Mg_Batch());


    }



    @IsTest
	private static void test200(){
        Talend_Setting__c talendSetting = new Talend_Setting__c(
            Sandbox_MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/200',
            Sandbox_MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/200',
            Sandbox_MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/200',
            Sandbox_MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/200',
            Sandbox_MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/200',
            MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/200',
            MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/200',
            MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/200',
            MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/200',
            MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/200',
            MG_Send_WeChat_Message__c = 'http://127.0.0.1/200',
            Sandbox_MG_Send_WeChat_Message__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_sendWeChatMessage/200',
            Sandbox_MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/200',
            MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/200',
            MG_Update_Case_Status__c = 'http://127.0.0.1/200',
            Sandbox_MG_Update_Case_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_multiupdate/200',
            Sandbox_MG_Update_Campaign__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_saveSfEvent/200',
            MG_Update_Campaign__c = 'http://127.0.0.1/200',
            Sandbox_MG_Update_CampaignMember__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_syncCustomerSegments/200',
            MG_Update_CampaignMember__c = 'http://127.0.0.1/200',
            Change_Request_Endpoint__c = 'http://127.0.0.1/200',
            Password__c = 'http://127.0.0.1/200',
            Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/200',
            Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/200',
            Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/200',
            Sandbox_Password__c = 'http://127.0.0.1/200',
            Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/200',
            Sandbox_User_Name__c = 'http://127.0.0.1/200',
            Send_to_Account_Endpoint__c = 'http://127.0.0.1/200',
            User_Name__c = 'http://127.0.0.1/200',
            Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/200',
            Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/200',
            Quote_Endpoint__c = 'http://127.0.0.1/200',
            Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/200'
        );
    
        insert talendSetting;
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        // testFactory.makeTalendSetting();
        Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Contact con_factory = [SELECT Id, Name FROM Contact WHERE AccountId =: acc_factory.Id];


        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        List<Product2> SKUList = [SELECT Id FROM Product2];

        Campaign cam = testFactory.makeCampaign();
        insert cam;

        CN_Campaign_Product__c cp = new CN_Campaign_Product__c();
        cp.CN_Campaign__c = cam.Id;
        cp.CN_Product__c = SKUList[0].Id;
        insert cp;

        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.CampaignId = cam.Id;
        cms.Label = Constants.CN_CM_STATUS_ATTENDED;
        // cms.SortOrder = 1;
        cms.IsDefault = true;
        cms.HasResponded = true;
        insert cms;

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cam.Id;
        cm.AccountId = acc_factory.Id;
        cm.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm;
        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());

    }

    
    @IsTest
	private static void test500(){
        Talend_Setting__c talendSetting = new Talend_Setting__c(
        Sandbox_MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/500',
        Sandbox_MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/500',
        Sandbox_MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/500',
        Sandbox_MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/500',
        Sandbox_MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/500',
        MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/500',
        MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/500',
        MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/500',
        MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/500',
        MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/500',
        MG_Send_WeChat_Message__c = 'http://127.0.0.1/500',
        Sandbox_MG_Send_WeChat_Message__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_sendWeChatMessage/500',
        Sandbox_MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/500',
        MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/500',
        MG_Update_Case_Status__c = 'http://127.0.0.1/500',
        Sandbox_MG_Update_Case_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_multiupdate/500',
        Sandbox_MG_Update_Campaign__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_saveSfEvent/500',
        MG_Update_Campaign__c = 'http://127.0.0.1/500',
        Sandbox_MG_Update_CampaignMember__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_syncCustomerSegments/500',
        MG_Update_CampaignMember__c = 'http://127.0.0.1/500',
        Change_Request_Endpoint__c = 'http://127.0.0.1/500',
        Password__c = 'http://127.0.0.1/500',
        Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/500',
        Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/500',
        Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/500',
        Sandbox_Password__c = 'http://127.0.0.1/500',
        Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/500',
        Sandbox_User_Name__c = 'http://127.0.0.1/500',
        Send_to_Account_Endpoint__c = 'http://127.0.0.1/500',
        User_Name__c = 'http://127.0.0.1/500',
        Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/500',
        Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/500',
        Quote_Endpoint__c = 'http://127.0.0.1/500',
        Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/500'
);
    
        insert talendSetting;
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        // testFactory.makeTalendSetting();
        Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Contact con_factory = [SELECT Id, Name FROM Contact WHERE AccountId =: acc_factory.Id];


        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        List<Product2> SKUList = [SELECT Id FROM Product2];

        Campaign cam = testFactory.makeCampaign();
        insert cam;

        CN_Campaign_Product__c cp = new CN_Campaign_Product__c();
        cp.CN_Campaign__c = cam.Id;
        cp.CN_Product__c = SKUList[0].Id;
        insert cp;

        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.CampaignId = cam.Id;
        cms.Label = Constants.CN_CM_STATUS_ATTENDED;
        // cms.SortOrder = 1;
        cms.IsDefault = true;
        cms.HasResponded = true;
        insert cms;

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cam.Id;
        cm.AccountId = acc_factory.Id;
        cm.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm;
        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());

    }


    @IsTest
	private static void test404(){
        Talend_Setting__c talendSetting = new Talend_Setting__c(
            Sandbox_MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/404',
            Sandbox_MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/404',
            Sandbox_MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/404',
            Sandbox_MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/404',
            Sandbox_MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/404',
            MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/404',
            MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/404',
            MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/404',
            MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/404',
            MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/404',
            MG_Send_WeChat_Message__c = 'http://127.0.0.1/404',
            Sandbox_MG_Send_WeChat_Message__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_sendWeChatMessage/404',
            Sandbox_MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/404',
            MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/404',
            MG_Update_Case_Status__c = 'http://127.0.0.1/404',
            Sandbox_MG_Update_Case_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_multiupdate/404',
            Sandbox_MG_Update_Campaign__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_saveSfEvent/404',
            MG_Update_Campaign__c = 'http://127.0.0.1/404',
            Sandbox_MG_Update_CampaignMember__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_syncCustomerSegments/404',
            MG_Update_CampaignMember__c = 'http://127.0.0.1/404',
            Change_Request_Endpoint__c = 'http://127.0.0.1/404',
            Password__c = 'http://127.0.0.1/404',
            Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/404',
            Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/404',
            Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/404',
            Sandbox_Password__c = 'http://127.0.0.1/404',
            Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/404',
            Sandbox_User_Name__c = 'http://127.0.0.1/404',
            Send_to_Account_Endpoint__c = 'http://127.0.0.1/404',
            User_Name__c = 'http://127.0.0.1/404',
            Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/404',
            Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/404',
            Quote_Endpoint__c = 'http://127.0.0.1/404',
            Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/404'
    );
    
        insert talendSetting;
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        // testFactory.makeTalendSetting();
        Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Contact con_factory = [SELECT Id, Name FROM Contact WHERE AccountId =: acc_factory.Id];


        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        List<Product2> SKUList = [SELECT Id FROM Product2];

        Campaign cam = testFactory.makeCampaign();
        insert cam;

        CN_Campaign_Product__c cp = new CN_Campaign_Product__c();
        cp.CN_Campaign__c = cam.Id;
        cp.CN_Product__c = SKUList[0].Id;
        insert cp;

        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.CampaignId = cam.Id;
        cms.Label = Constants.CN_CM_STATUS_ATTENDED;
        // cms.SortOrder = 1;
        cms.IsDefault = true;
        cms.HasResponded = true;
        insert cms;

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cam.Id;
        cm.AccountId = acc_factory.Id;
        cm.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm;
        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());

    }


    @IsTest
	private static void test400(){
        Talend_Setting__c talendSetting = new Talend_Setting__c(
        Sandbox_MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/400',
        Sandbox_MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/400',
        Sandbox_MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/400',
        Sandbox_MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/400',
        Sandbox_MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/400',
        MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/400',
        MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/400',
        MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/400',
        MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/400',
        MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/400',
        MG_Send_WeChat_Message__c = 'http://127.0.0.1/400',
        Sandbox_MG_Send_WeChat_Message__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_sendWeChatMessage/400',
        Sandbox_MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/400',
        MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/400',
        MG_Update_Case_Status__c = 'http://127.0.0.1/400',
        Sandbox_MG_Update_Case_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_multiupdate/400',
        Sandbox_MG_Update_Campaign__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_saveSfEvent/400',
        MG_Update_Campaign__c = 'http://127.0.0.1/400',
        Sandbox_MG_Update_CampaignMember__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_syncCustomerSegments/400',
        MG_Update_CampaignMember__c = 'http://127.0.0.1/400',
        Change_Request_Endpoint__c = 'http://127.0.0.1/400',
        Password__c = 'http://127.0.0.1/400',
        Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/400',
        Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/400',
        Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/400',
        Sandbox_Password__c = 'http://127.0.0.1/400',
        Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/400',
        Sandbox_User_Name__c = 'http://127.0.0.1/400',
        Send_to_Account_Endpoint__c = 'http://127.0.0.1/400',
        User_Name__c = 'http://127.0.0.1/400',
        Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/400',
        Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/400',
        Quote_Endpoint__c = 'http://127.0.0.1/400',
        Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/400'
);
    
        insert talendSetting;
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        // testFactory.makeTalendSetting();
        Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Contact con_factory = [SELECT Id, Name FROM Contact WHERE AccountId =: acc_factory.Id];


        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        List<Product2> SKUList = [SELECT Id FROM Product2];

        Campaign cam = testFactory.makeCampaign();
        insert cam;

        CN_Campaign_Product__c cp = new CN_Campaign_Product__c();
        cp.CN_Campaign__c = cam.Id;
        cp.CN_Product__c = SKUList[0].Id;
        insert cp;

        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.CampaignId = cam.Id;
        cms.Label = Constants.CN_CM_STATUS_ATTENDED;
        // cms.SortOrder = 1;
        cms.IsDefault = true;
        cms.HasResponded = true;
        insert cms;

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cam.Id;
        cm.AccountId = acc_factory.Id;
        cm.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm;
        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());

    }



    @IsTest
	private static void test503(){
        Talend_Setting__c talendSetting = new Talend_Setting__c(
        Sandbox_MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/503',
        Sandbox_MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/503',
        Sandbox_MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/503',
        Sandbox_MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/503',
        Sandbox_MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/503',
        MG_Update_Shipping_Address__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateShippingAddress/503',
        MG_Save_Company_Contact__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCompanyContact/503',
        MG_Save_Customer_Code__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_SaveCustomerCode/503',
        MG_Update_Company_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateCompanyStatus/503',
        MG_Approval_Lead__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_approvallead/503',
        MG_Send_WeChat_Message__c = 'http://127.0.0.1/503',
        Sandbox_MG_Send_WeChat_Message__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_sendWeChatMessage/503',
        Sandbox_MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/503',
        MG_Update_Lead_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_updateLeadStatus/503',
        MG_Update_Case_Status__c = 'http://127.0.0.1/503',
        Sandbox_MG_Update_Case_Status__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_multiupdate/503',
        Sandbox_MG_Update_Campaign__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_saveSfEvent/503',
        MG_Update_Campaign__c = 'http://127.0.0.1/503',
        Sandbox_MG_Update_CampaignMember__c = 'https://talenddevap01.sinodis.com:8443/services/sf2mg/tiger_MG_syncCustomerSegments/503',
        MG_Update_CampaignMember__c = 'http://127.0.0.1/503',
        Change_Request_Endpoint__c = 'http://127.0.0.1/503',
        Password__c = 'http://127.0.0.1/503',
        Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/503',
        Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/503',
        Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/503',
        Sandbox_Password__c = 'http://127.0.0.1/503',
        Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/503',
        Sandbox_User_Name__c = 'http://127.0.0.1/503',
        Send_to_Account_Endpoint__c = 'http://127.0.0.1/503',
        User_Name__c = 'http://127.0.0.1/503',
        Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/503',
        Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/503',
        Quote_Endpoint__c = 'http://127.0.0.1/503',
        Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/503'
);
    
        insert talendSetting;
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        // testFactory.makeTalendSetting();
        Account acc_factory = [SELECT Id, Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        Contact con_factory = [SELECT Id, Name FROM Contact WHERE AccountId =: acc_factory.Id];


        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        List<Product2> SKUList = [SELECT Id FROM Product2];

        Campaign cam = testFactory.makeCampaign();
        insert cam;

        CN_Campaign_Product__c cp = new CN_Campaign_Product__c();
        cp.CN_Campaign__c = cam.Id;
        cp.CN_Product__c = SKUList[0].Id;
        insert cp;

        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.CampaignId = cam.Id;
        cms.Label = Constants.CN_CM_STATUS_ATTENDED;
        // cms.SortOrder = 1;
        cms.IsDefault = true;
        cms.HasResponded = true;
        insert cms;

        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cam.Id;
        cm.AccountId = acc_factory.Id;
        cm.Status = Constants.CN_CM_STATUS_ATTENDED;
        insert cm;
        Test.setMock(HTTPCalloutMock.class, new TestHttpMock());

    }



}