/**************************************************************************************************
 * Name           : CN_ST_Send_To_SAP_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-18
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_ST_Send_To_SAP_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeDelete_500() {
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
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/500';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/500';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/500';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/500';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

        User salesMDM = [SELECT Id FROM User WHERE lastName = 'salesMDM'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        CN_Group__c gr = [SELECT Id FROM CN_Group__c WHERE CN_Group_Code__c = 'drink group'][0];
        

        System.runAs(salesMDM) {

            CN_Business_Unit__c bu = new CN_Business_Unit__c();
            bu.Name = 'Test BusinessUnit';
            bu.CN_Business_Unit_Code__c = '00001';
            bu.CN_City_API__c = 'Shanghai';
            bu.CurrencyIsoCode = 'CNY';
            insert bu;
            
            CN_Sales_Team__c st = new CN_Sales_Team__c();
            st.Name = 'Test SalesTeam';
            st.CN_Sales_Team_Code__c = '00001';
            st.CN_City_API__c = 'Shanghai';
            st.CN_Business_Unit__c = bu.Id;
            insert st;
            
            test.startTest();

            try{
                CN_ST_Send_To_SAP_LC_Ctrl.getBUInfoAndCheckEditPermisison(st.id);
                Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
                CN_ST_Send_To_SAP_LC_Ctrl.sendSalesTeam(st.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeDelete_200_Sync_Success() {
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
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CHS/200';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CHS/200';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/200';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/200';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

        User salesMDM = [SELECT Id FROM User WHERE lastName = 'salesMDM'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        CN_Group__c gr = [SELECT Id FROM CN_Group__c WHERE CN_Group_Code__c = 'drink group'][0];
        

        System.runAs(salesMDM) {

            CN_Business_Unit__c bu = new CN_Business_Unit__c();
            bu.Name = 'Test BusinessUnit';
            bu.CN_Business_Unit_Code__c = '00001';
            bu.CurrencyIsoCode = 'CNY';
            bu.CN_City_API__c = 'Shanghai';
            insert bu;
            
            CN_Sales_Team__c st = new CN_Sales_Team__c();
            st.Name = 'Test SalesTeam';
            st.CN_Sales_Team_Code__c = '00001';
            st.CN_City_API__c = 'Shanghai';
            st.CN_Business_Unit__c = bu.Id;
            insert st;
            
            test.startTest();

            try{
                CN_ST_Send_To_SAP_LC_Ctrl.getBUInfoAndCheckEditPermisison(st.id);
                Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
                CN_ST_Send_To_SAP_LC_Ctrl.sendSalesTeam(st.id);
            }catch(Exception e){}
            try{
                CN_ST_Send_To_SAP_LC_Ctrl.getBUInfoAndCheckEditPermisison(null);
            }catch(Exception e){}
            try{
                CN_ST_Send_To_SAP_LC_Ctrl.sendSalesTeam(null);
            }catch(Exception e){}
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeDelete_200_Sync_Fail() {
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
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CHE/200';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CHE/200';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/200';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/200';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

        User salesMDM = [SELECT Id FROM User WHERE lastName = 'salesMDM'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        CN_Group__c gr = [SELECT Id FROM CN_Group__c WHERE CN_Group_Code__c = 'drink group'][0];
        

        System.runAs(salesMDM) {

            CN_Business_Unit__c bu = new CN_Business_Unit__c();
            bu.Name = 'Test BusinessUnit';
            bu.CN_Business_Unit_Code__c = '00001';
            bu.CurrencyIsoCode = 'CNY';
            bu.CN_City_API__c = 'Shanghai';
            insert bu;

            CN_Sales_Team__c st = new CN_Sales_Team__c();
            st.Name = 'Test SalesTeam';
            st.CN_Sales_Team_Code__c = '00001';
            st.CN_City_API__c = 'Shanghai';
            st.CN_Business_Unit__c = bu.Id;
            insert st;
            
            test.startTest();

            try{
                CN_ST_Send_To_SAP_LC_Ctrl.getBUInfoAndCheckEditPermisison(st.id);
                Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
                CN_ST_Send_To_SAP_LC_Ctrl.sendSalesTeam(st.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeDelete_200_Sent() {
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
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/200';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/200';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/200';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/200';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/200';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

        User salesMDM = [SELECT Id FROM User WHERE lastName = 'salesMDM'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        CN_Group__c gr = [SELECT Id FROM CN_Group__c WHERE CN_Group_Code__c = 'drink group'][0];
        

        System.runAs(salesMDM) {

            CN_Business_Unit__c bu = new CN_Business_Unit__c();
            bu.Name = 'Test BusinessUnit';
            bu.CN_Business_Unit_Code__c = '00001';
            bu.CurrencyIsoCode = 'CNY';
            bu.CN_City_API__c = 'Shanghai';
            insert bu;
            
            CN_Sales_Team__c st = new CN_Sales_Team__c();
            st.Name = 'Test SalesTeam';
            st.CN_Sales_Team_Code__c = '00001';
            st.CN_City_API__c = 'Shanghai';
            st.CN_Business_Unit__c = bu.Id;
            insert st;
            
            test.startTest();

            try{
                CN_ST_Send_To_SAP_LC_Ctrl.getBUInfoAndCheckEditPermisison(st.id);
                Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
                CN_ST_Send_To_SAP_LC_Ctrl.sendSalesTeam(st.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeDelete_400() {
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
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/400';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/400';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/500';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/500';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

        User salesMDM = [SELECT Id FROM User WHERE lastName = 'salesMDM'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        CN_Group__c gr = [SELECT Id FROM CN_Group__c WHERE CN_Group_Code__c = 'drink group'][0];
        

        System.runAs(salesMDM) {

            CN_Business_Unit__c bu = new CN_Business_Unit__c();
            bu.Name = 'Test BusinessUnit';
            bu.CN_Business_Unit_Code__c = '00001';
            bu.CurrencyIsoCode = 'CNY';
            bu.CN_City_API__c = 'Shanghai';
            insert bu;
            
            CN_Sales_Team__c st = new CN_Sales_Team__c();
            st.Name = 'Test SalesTeam';
            st.CN_Sales_Team_Code__c = '00001';
            st.CN_City_API__c = 'Shanghai';
            st.CN_Business_Unit__c = bu.Id;
            insert st;
            
            test.startTest();

            try{
                CN_ST_Send_To_SAP_LC_Ctrl.getBUInfoAndCheckEditPermisison(st.id);
                Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
                CN_ST_Send_To_SAP_LC_Ctrl.sendSalesTeam(st.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeDelete_401() {
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
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/401';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/401';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/500';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/500';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

        User salesMDM = [SELECT Id FROM User WHERE lastName = 'salesMDM'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        CN_Group__c gr = [SELECT Id FROM CN_Group__c WHERE CN_Group_Code__c = 'drink group'][0];
        

        System.runAs(salesMDM) {

            CN_Business_Unit__c bu = new CN_Business_Unit__c();
            bu.Name = 'Test BusinessUnit';
            bu.CN_Business_Unit_Code__c = '00001';
            bu.CurrencyIsoCode = 'CNY';
            bu.CN_City_API__c = 'Shanghai';
            insert bu;
            
            CN_Sales_Team__c st = new CN_Sales_Team__c();
            st.Name = 'Test SalesTeam';
            st.CN_Sales_Team_Code__c = '00001';
            st.CN_City_API__c = 'Shanghai';
            st.CN_Business_Unit__c = bu.Id;
            insert st;
            
            test.startTest();

            try{
                CN_ST_Send_To_SAP_LC_Ctrl.getBUInfoAndCheckEditPermisison(st.id);
                Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
                CN_ST_Send_To_SAP_LC_Ctrl.sendSalesTeam(st.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    @isTest
    private static void handleBeforeDelete_404() {
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
        talendSetting.Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sandbox_Customer_Hierarchy_Endpoint__c = 'http://127.0.0.1/CH/404';
        talendSetting.Sanbox_Change_Request_Endpoint__c = 'http://127.0.0.1/CR/500';
        talendSetting.Sanbox_Sales_Order_Update_Endpoint__c = 'http://127.0.0.1/SO/500';
        talendSetting.Sandbox_Password__c = 'password';
        talendSetting.Sandbox_Send_To_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.Sandbox_User_Name__c = 'Name';
        talendSetting.Send_to_Account_Endpoint__c = 'http://127.0.0.1/ACC/500';
        talendSetting.User_Name__c = 'Name';
        talendSetting.Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        talendSetting.Sandbox_Quote_Endpoint__c = 'http://127.0.0.1/Quote/200';
        insert talendSetting;

        User salesMDM = [SELECT Id FROM User WHERE lastName = 'salesMDM'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        CN_Group__c gr = [SELECT Id FROM CN_Group__c WHERE CN_Group_Code__c = 'drink group'][0];
        

        System.runAs(salesMDM) {

            CN_Business_Unit__c bu = new CN_Business_Unit__c();
            bu.Name = 'Test BusinessUnit';
            bu.CN_Business_Unit_Code__c = '00001';
            bu.CurrencyIsoCode = 'CNY';
            bu.CN_City_API__c = 'Shanghai';
            insert bu;
            
            CN_Sales_Team__c st = new CN_Sales_Team__c();
            st.Name = 'Test SalesTeam';
            st.CN_Sales_Team_Code__c = '00001';
            st.CN_City_API__c = 'Shanghai';
            st.CN_Business_Unit__c = bu.Id;
            insert st;
            
            test.startTest();


            try{
                CN_ST_Send_To_SAP_LC_Ctrl.getBUInfoAndCheckEditPermisison(st.id);
                Test.setMock(HTTPCalloutMock.class, new TestHttpMock());
                CN_ST_Send_To_SAP_LC_Ctrl.sendSalesTeam(st.id);
            }catch(Exception e){}
            
            test.stopTest();
        }
    }

    
}