/**************************************************************************************************
 * Name           : CN_Sales_Order_Send_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Sales_Order_Send_LC_Ctrl_Test {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeUpdate_500() {
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
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

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
            acc.CN_Invoicing_Address_EN__c = 'ABCDEF';
            acc.CN_Reference_Day__c = 'Delivery_Day';
            acc.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            acc.CN_Account_Status__c = 'New';
            acc.CN_Business_Unit_UI__c = businessUnit.Id;
            acc.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc;

            CN_Sales_Order__c  order = new CN_Sales_Order__c();
            order.CN_Sold_To_Account_Name__c = acc.Id;
            order.CN_Up_Code__c = '0000' + 1;
            insert order;

            List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
            CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
            orderItem1.CN_Order_Number__c = order.Id;
            orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
            orderItemList.add(orderItem1);

            CN_Sales_Order_Item__c orderItem2 = new CN_Sales_Order_Item__c();
            orderItem2.CN_Order_Number__c = order.Id;
            orderItem2.CN_Up_Code__c = '0000' + 1 + '2';
            orderItemList.add(orderItem2);
        
            insert orderItemList;

            CN_Sales_Order__c  order_update = new CN_Sales_Order__c();
            order_update.Id = order.Id;
            order_update.CN_Sync_Status__c = 'S';
            order_update.CN_Sync_Time__c = system.now().addDays(-1);
            order_update.CN_Sync_Error_Message__c = 'error';
            
            update order_update;

            test.startTest();

            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            try{
                Boolean result = CN_Sales_Order_Send_LC_Ctrl.retrieveSOStatus(order.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeUpdate_200() {
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
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

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
            acc.CN_Invoicing_Address_EN__c = 'ABCDEF';
            acc.CN_Reference_Day__c = 'Delivery_Day';
            acc.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            acc.CN_Account_Status__c = 'New';
            acc.CN_Business_Unit_UI__c = businessUnit.Id;
            acc.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc;

            CN_Sales_Order__c  order = new CN_Sales_Order__c();
            order.CN_Sold_To_Account_Name__c = acc.Id;
            order.CN_Up_Code__c = '0000' + 1;
            insert order;

            List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
            CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
            orderItem1.CN_Order_Number__c = order.Id;
            orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
            orderItemList.add(orderItem1);

            CN_Sales_Order_Item__c orderItem2 = new CN_Sales_Order_Item__c();
            orderItem2.CN_Order_Number__c = order.Id;
            orderItem2.CN_Up_Code__c = '0000' + 1 + '2';
            orderItemList.add(orderItem2);
        
            insert orderItemList;

            CN_Sales_Order__c  order_update = new CN_Sales_Order__c();
            order_update.Id = order.Id;
            order_update.CN_Sync_Status__c = 'S';
            order_update.CN_Sync_Time__c = system.now().addDays(-1);
            order_update.CN_Sync_Error_Message__c = 'error';
            
            update order_update;

            test.startTest();

            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            try{
                Boolean result = CN_Sales_Order_Send_LC_Ctrl.retrieveSOStatus(order.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeUpdate_200_sync_E() {
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

        Talend_Setting__c talendSetting = new Talend_Setting__c();
        talendSetting.Change_Request_Endpoint__c = 'http://127.0.0.1/CR/200';
        talendSetting.Password__c = 'password';
        talendSetting.Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SOE/200';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/200';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SOE/200';
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

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
            acc.CN_Invoicing_Address_EN__c = 'ABCDEF';
            acc.CN_Reference_Day__c = 'Delivery_Day';
            acc.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            acc.CN_Account_Status__c = 'New';
            acc.CN_Business_Unit_UI__c = businessUnit.Id;
            acc.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc;

            CN_Sales_Order__c  order = new CN_Sales_Order__c();
            order.CN_Sold_To_Account_Name__c = acc.Id;
            order.CN_Up_Code__c = '0000' + 1;
            insert order;

            List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
            CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
            orderItem1.CN_Order_Number__c = order.Id;
            orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
            orderItemList.add(orderItem1);

            CN_Sales_Order_Item__c orderItem2 = new CN_Sales_Order_Item__c();
            orderItem2.CN_Order_Number__c = order.Id;
            orderItem2.CN_Up_Code__c = '0000' + 1 + '2';
            orderItemList.add(orderItem2);
        
            insert orderItemList;

            CN_Sales_Order__c  order_update = new CN_Sales_Order__c();
            order_update.Id = order.Id;
            order_update.CN_Sync_Status__c = 'S';
            order_update.CN_Sync_Time__c = system.now().addDays(-1);
            order_update.CN_Sync_Error_Message__c = 'error';
            
            update order_update;

            test.startTest();

            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            try{
                Boolean result = CN_Sales_Order_Send_LC_Ctrl.retrieveSOStatus(order.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeUpdate_200_sync_Sent() {
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

        Talend_Setting__c talendSetting = new Talend_Setting__c();
        talendSetting.Change_Request_Endpoint__c = 'http://127.0.0.1/CR/200';
        talendSetting.Password__c = 'password';
        talendSetting.Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SOS/200';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/200';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SOS/200';
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

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
            acc.CN_Invoicing_Address_EN__c = 'ABCDEF';
            acc.CN_Reference_Day__c = 'Delivery_Day';
            acc.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            acc.CN_Account_Status__c = 'New';
            acc.CN_Business_Unit_UI__c = businessUnit.Id;
            acc.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc;

            CN_Sales_Order__c  order = new CN_Sales_Order__c();
            order.CN_Sold_To_Account_Name__c = acc.Id;
            order.CN_Up_Code__c = '0000' + 1;
            insert order;

            List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
            CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
            orderItem1.CN_Order_Number__c = order.Id;
            orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
            orderItemList.add(orderItem1);

            CN_Sales_Order_Item__c orderItem2 = new CN_Sales_Order_Item__c();
            orderItem2.CN_Order_Number__c = order.Id;
            orderItem2.CN_Up_Code__c = '0000' + 1 + '2';
            orderItemList.add(orderItem2);
        
            insert orderItemList;

            CN_Sales_Order__c  order_update = new CN_Sales_Order__c();
            order_update.Id = order.Id;
            order_update.CN_Sync_Status__c = 'S';
            order_update.CN_Sync_Time__c = system.now().addDays(-1);
            order_update.CN_Sync_Error_Message__c = 'error';
            
            update order_update;

            test.startTest();

            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            try{
                Boolean result = CN_Sales_Order_Send_LC_Ctrl.retrieveSOStatus(order.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeUpdate_400() {
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
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

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
            acc.CN_Invoicing_Address_EN__c = 'ABCDEF';
            acc.CN_Reference_Day__c = 'Delivery_Day';
            acc.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            acc.CN_Account_Status__c = 'New';
            acc.CN_Business_Unit_UI__c = businessUnit.Id;
            acc.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc;

            CN_Sales_Order__c  order = new CN_Sales_Order__c();
            order.CN_Sold_To_Account_Name__c = acc.Id;
            order.CN_Up_Code__c = '0000' + 1;
            insert order;

            List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
            CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
            orderItem1.CN_Order_Number__c = order.Id;
            orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
            orderItemList.add(orderItem1);

            CN_Sales_Order_Item__c orderItem2 = new CN_Sales_Order_Item__c();
            orderItem2.CN_Order_Number__c = order.Id;
            orderItem2.CN_Up_Code__c = '0000' + 1 + '2';
            orderItemList.add(orderItem2);
        
            insert orderItemList;

            CN_Sales_Order__c  order_update = new CN_Sales_Order__c();
            order_update.Id = order.Id;
            order_update.CN_Sync_Status__c = 'S';
            order_update.CN_Sync_Time__c = system.now().addDays(-1);
            order_update.CN_Sync_Error_Message__c = 'error';
            
            update order_update;

            test.startTest();

            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            try{
                Boolean result = CN_Sales_Order_Send_LC_Ctrl.retrieveSOStatus(order.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }
    @isTest
    private static void handleBeforeUpdate_401() {
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
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

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
            acc.CN_Invoicing_Address_EN__c = 'ABCDEF';
            acc.CN_Reference_Day__c = 'Delivery_Day';
            acc.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            acc.CN_Account_Status__c = 'New';
            acc.CN_Business_Unit_UI__c = businessUnit.Id;
            acc.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc;

            CN_Sales_Order__c  order = new CN_Sales_Order__c();
            order.CN_Sold_To_Account_Name__c = acc.Id;
            order.CN_Up_Code__c = '0000' + 1;
            insert order;

            List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
            CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
            orderItem1.CN_Order_Number__c = order.Id;
            orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
            orderItemList.add(orderItem1);

            CN_Sales_Order_Item__c orderItem2 = new CN_Sales_Order_Item__c();
            orderItem2.CN_Order_Number__c = order.Id;
            orderItem2.CN_Up_Code__c = '0000' + 1 + '2';
            orderItemList.add(orderItem2);
        
            insert orderItemList;

            CN_Sales_Order__c  order_update = new CN_Sales_Order__c();
            order_update.Id = order.Id;
            order_update.CN_Sync_Status__c = 'S';
            order_update.CN_Sync_Time__c = system.now().addDays(-1);
            order_update.CN_Sync_Error_Message__c = 'error';
            
            update order_update;

            test.startTest();

            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            try{
                Boolean result = CN_Sales_Order_Send_LC_Ctrl.retrieveSOStatus(order.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeUpdate_404() {
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
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

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
            acc.CN_Invoicing_Address_EN__c = 'ABCDEF';
            acc.CN_Reference_Day__c = 'Delivery_Day';
            acc.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
            acc.CN_Account_Status__c = 'New';
            acc.CN_Business_Unit_UI__c = businessUnit.Id;
            acc.CN_Sales_Team_UI__c = salesTeam.Id;
            insert acc;

            CN_Sales_Order__c  order = new CN_Sales_Order__c();
            order.CN_Sold_To_Account_Name__c = acc.Id;
            order.CN_Up_Code__c = '0000' + 1;
            insert order;

            List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
            CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
            orderItem1.CN_Order_Number__c = order.Id;
            orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
            orderItemList.add(orderItem1);

            CN_Sales_Order_Item__c orderItem2 = new CN_Sales_Order_Item__c();
            orderItem2.CN_Order_Number__c = order.Id;
            orderItem2.CN_Up_Code__c = '0000' + 1 + '2';
            orderItemList.add(orderItem2);
        
            insert orderItemList;

            CN_Sales_Order__c  order_update = new CN_Sales_Order__c();
            order_update.Id = order.Id;
            order_update.CN_Sync_Status__c = 'S';
            order_update.CN_Sync_Time__c = system.now().addDays(-1);
            order_update.CN_Sync_Error_Message__c = 'error';
            
            update order_update;

            test.startTest();

            Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
            try{
                Boolean result = CN_Sales_Order_Send_LC_Ctrl.retrieveSOStatus(order.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }
}