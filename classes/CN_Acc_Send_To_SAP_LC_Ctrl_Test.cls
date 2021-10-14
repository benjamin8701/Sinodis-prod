/**************************************************************************************************
 * Name           : CN_Acc_Send_To_SAP_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Acc_Send_To_SAP_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void controllerTest_200() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        

        Talend_Setting__c talendSetting = new Talend_Setting__c();
        talendSetting.Change_Request_Endpoint__c = 'http://127.0.0.1/CR/200';
        talendSetting.Password__c = 'password';
        talendSetting.Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/200';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/200';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/200';
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.User_Name__c = 'Name';
        insert talendSetting;

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        
        String accId = '';
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
            acc.CN_Customer_Code__c = 'TestAccount';
            insert acc;
            accId = acc.Id;
        }
            Test.startTest();
            CN_Account_Send_To_SAP_LC_Ctrl.getAccountInfoAndCheckEditPermisison(accId);
            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            CN_Account_Send_To_SAP_LC_Ctrl.sendAccount(accId);

            try {
                CN_Account_Send_To_SAP_LC_Ctrl.getAccountInfoAndCheckEditPermisison('');
            } catch (Exception e) {
                
            }
            try {
                CN_Account_Send_To_SAP_LC_Ctrl.getAccountInfoAndCheckEditPermisison('001000000000000');
            } catch (Exception e) {
                
            }
            try {
                CN_Account_Send_To_SAP_LC_Ctrl.sendAccount('');
            } catch (Exception e) {
                
            }
            try {
                CN_Account_Send_To_SAP_LC_Ctrl.sendAccount('001000000000000');
            } catch (Exception e) {
                
            }
            Test.stopTest();
    }
    @isTest
    private static void controllerTest_500() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        Talend_Setting__c talendSetting = new Talend_Setting__c();
        talendSetting.Change_Request_Endpoint__c = 'http://127.0.0.1/CR/500';
        talendSetting.Password__c = 'password';
        talendSetting.Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/500';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/500';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/500';
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.User_Name__c = 'Name';
        insert talendSetting;

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        
        String accId = '';
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
            acc.CN_Customer_Code__c = 'TestAccount';
            insert acc;
            accId = acc.Id;
        }
            Test.startTest();
            CN_Account_Send_To_SAP_LC_Ctrl.getAccountInfoAndCheckEditPermisison(accId);
            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            CN_Account_Send_To_SAP_LC_Ctrl.sendAccount(accId);

            Test.stopTest();
    }
    @isTest
    private static void controllerTest_400() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        Talend_Setting__c talendSetting = new Talend_Setting__c();
        talendSetting.Change_Request_Endpoint__c = 'http://127.0.0.1/CR/400';
        talendSetting.Password__c = 'password';
        talendSetting.Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/400';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/400';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/400';
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/400';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/400';
        talendSetting.User_Name__c = 'Name';
        insert talendSetting;

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        
        String accId = '';
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
            acc.CN_Customer_Code__c = 'TestAccount';
            insert acc;
            accId = acc.Id;
        }
            Test.startTest();
            CN_Account_Send_To_SAP_LC_Ctrl.getAccountInfoAndCheckEditPermisison(accId);
            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            CN_Account_Send_To_SAP_LC_Ctrl.sendAccount(accId);

            Test.stopTest();
    }
    @isTest
    private static void controllerTest_401() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        Talend_Setting__c talendSetting = new Talend_Setting__c();
        talendSetting.Change_Request_Endpoint__c = 'http://127.0.0.1/CR/401';
        talendSetting.Password__c = 'password';
        talendSetting.Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/401';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/401';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/401';
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/401';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/401';
        talendSetting.User_Name__c = 'Name';
        insert talendSetting;

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        
        String accId = '';
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
            acc.CN_Customer_Code__c = 'TestAccount';
            insert acc;
            accId = acc.Id;
        }
            Test.startTest();
            CN_Account_Send_To_SAP_LC_Ctrl.getAccountInfoAndCheckEditPermisison(accId);
            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            CN_Account_Send_To_SAP_LC_Ctrl.sendAccount(accId);

            Test.stopTest();
    }
    @isTest
    private static void controllerTest_404() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        Talend_Setting__c talendSetting = new Talend_Setting__c();
        talendSetting.Change_Request_Endpoint__c = 'http://127.0.0.1/CR/404';
        talendSetting.Password__c = 'password';
        talendSetting.Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/404';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/404';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/404';
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/404';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/404';
        talendSetting.User_Name__c = 'Name';
        insert talendSetting;

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        
        String accId = '';
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
            acc.CN_Customer_Code__c = 'TestAccount';
            insert acc;
            accId = acc.Id;
        }
            Test.startTest();
            CN_Account_Send_To_SAP_LC_Ctrl.getAccountInfoAndCheckEditPermisison(accId);
            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            CN_Account_Send_To_SAP_LC_Ctrl.sendAccount(accId);

            Test.stopTest();
    }
}