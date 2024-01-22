/*
 * ************************************************************************************************
 * Name : CN_Lead_Upsert_To_Mg_Callout_Test
 * Object :
 * Requirement : LD-003 Test
 * Target :
 * Refer classes :
 * Author : ZZH
 * Create Date : 2023/7/4
 * Modify History :
 * ************************************************************************************************
 */
@isTest
public class CN_Lead_Upsert_To_Mg_Callout_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    static void testSendMgLeadStatus() {
        TestDataFactory testDataFactory = new TestDataFactory();
        //testDataFactory.makeCustomSetting();  
         testDataFactory.makeTalendSetting();
         TestDataFactory testFactory = new TestDataFactory();
         //testFactory.makeAccounts(1,true);
         testFactory.makeFactoryAccount();
         List<User> userList = [SELECT Id, LastName FROM User];
         Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
         for(User usr: userList) {
             lastNameUserIdMap.put(usr.LastName, usr.Id);
         }
         
         Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
         User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
         User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));
         User SalesMDM = New User(Id = lastNameUserIdMap.get('SalesMDM'));
         User SystemIntegration = New User(Id = lastNameUserIdMap.get('System Integration'));
         CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
         insert fieldLock;
 
         
         Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
         CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
         CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
         List<Lead> leadList = new List<Lead>();

         Lead l3 = new Lead(
            recordTypeId = cnLeadRTId,
            Company = 'Test Class Lead',
            LastName  = 'Lead last Name',
            FirstName = 'Lead First Name',
            LeadSource = 'E-Commerce',
            CN_Customer_Category__c = 'Restaurant',
            Status = 'Open',
            MobilePhone = '15748484848',
            CN_Province__c = province.Id,
            CN_City__c = city.Id,
            CN_Street__c = 'Lead Visit Address',
            CN_Zip_Postal_Code__c = '123456',
            CN_Status_Change_Records__c = '旧数据',
            CN_Field_Lock__c =fieldLock.id,
            OwnerId = salesRep.Id
         );

         insert l3;

         System.debug('l3.id==========>'+l3.id);



        List<Map<String, Object>> mapList = new List<Map<String, Object>>();
        Map<String, Object> testData = new Map<String, Object>{
            'id' => l3.id,
            'uniqueId' => '200',
            'owner' => 'XIAO Cathy',
            'status' => 'Sales Qualified',
            'sale_email' => 'cathy.xiao@savencia.com.invalid',
            'transition_status' => '未转换',
            'oldStatus' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'oldStatus' => null,
                    'owner' => 'Zhu Gloria',
                    'sale_email' => null,
                    'status' => null,
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-26 21:50:23'
                },
                new Map<String, Object>{
                    'oldStatus' => 'Assigned',
                    'owner' => 'XIAO Cathy',
                    'sale_email' => 'cathy.xiao@savencia.com.invalid',
                    'status' => 'Sales Qualified',
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-30 00:42:05'
                }
            }
        };
        system.debug('testData 145=========>'+testData);
        mapList.add(testData);
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        
        Test.startTest();
        List<Lead> sendSuccess = CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatus(mapList);
        Test.stopTest();
        Database.executeBatch(new CN_Lead_Upsert_To_Mg_Batch());   
        
        System.assertEquals(1, sendSuccess.size());
    }



    @isTest
    public static void testSendMgLeadStatusRealTime() {
         TestDataFactory testFactory = new TestDataFactory();
         //testDataFactory.makeTalendSetting();
         testFactory.makeFactoryAccount();
         List<User> userList = [SELECT Id, LastName FROM User];
         Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
         for(User usr: userList) {
             lastNameUserIdMap.put(usr.LastName, usr.Id);
         }
         
         Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
         User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
         User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));
         User SalesMDM = New User(Id = lastNameUserIdMap.get('SalesMDM'));
         User SystemIntegration = New User(Id = lastNameUserIdMap.get('System Integration'));
         CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
         insert fieldLock;
 
         
         Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
         CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
         CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
         List<Lead> leadList = new List<Lead>();

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

         Lead l3 = new Lead(
            recordTypeId = cnLeadRTId,
            Company = 'Test Class Lead',
            LastName  = 'Lead last Name',
            FirstName = 'Lead First Name',
            LeadSource = 'E-Commerce',
            CN_Customer_Category__c = 'Restaurant',
            Status = 'Open',
            MobilePhone = '15748484848',
            CN_Province__c = province.Id,
            CN_City__c = city.Id,
            CN_Street__c = 'Lead Visit Address',
            CN_Zip_Postal_Code__c = '123456',
            CN_Status_Change_Records__c = '旧数据',
            CN_Field_Lock__c =fieldLock.id,
            OwnerId = salesRep.Id
         );

         insert l3;



        List<Map<String, Object>> mapList = new List<Map<String, Object>>();
        Map<String, Object> testData = new Map<String, Object>{
            'id' => l3.id,
            'uniqueId' => '200',
            'owner' => 'XIAO Cathy 200 Re',
            'status' => 'Sales Qualified',
            'sale_email' => 'cathy.xiao@savencia.com.invalid',
            'transition_status' => '未转换',
            'oldStatus' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'oldStatus' => null,
                    'owner' => 'Zhu Gloria',
                    'sale_email' => null,
                    'status' => null,
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-26 21:50:23'
                },
                new Map<String, Object>{
                    'oldStatus' => 'Assigned',
                    'owner' => 'XIAO Cathy',
                    'sale_email' => 'cathy.xiao@savencia.com.invalid',
                    'status' => 'Sales Qualified',
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-30 00:42:05'
                }
            }
        };
        System.debug('206==========206======200请求>');
        System.debug('testData==========286>'+testData);
        mapList.add(testData);
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        Test.startTest();
        CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatusRealTime(JSON.serialize(mapList));
        Test.stopTest();
        Database.executeBatch(new CN_Lead_Upsert_To_Mg_Batch());   
       
    }

    @isTest
    static void testSendMgLeadStatusWith500() {
        TestDataFactory testDataFactory = new TestDataFactory();
        testDataFactory.makeTalendSetting();
         TestDataFactory testFactory = new TestDataFactory();
         testFactory.makeFactoryAccount();
         List<User> userList = [SELECT Id, LastName FROM User];
         Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
         for(User usr: userList) {
             lastNameUserIdMap.put(usr.LastName, usr.Id);
         }
         
         Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
         User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
         User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));
         User SalesMDM = New User(Id = lastNameUserIdMap.get('SalesMDM'));
         User SystemIntegration = New User(Id = lastNameUserIdMap.get('System Integration'));
         CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
         insert fieldLock;
 
         
         Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
         CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
         CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
 
         List<Lead> leadList = new List<Lead>();
         Lead l3 = new Lead(
            recordTypeId = cnLeadRTId,
            Company = 'Test Class Lead',
            LastName  = 'Lead last Name',
            FirstName = 'Lead First Name',
            LeadSource = 'E-Commerce',
            CN_Customer_Category__c = 'Restaurant',
            Status = 'Open',
            MobilePhone = '15748484848',
            CN_Province__c = province.Id,
            CN_City__c = city.Id,
            CN_Street__c = 'Lead Visit Address',
            CN_Zip_Postal_Code__c = '123456',
            CN_Status_Change_Records__c = '旧数据',
            CN_Field_Lock__c =fieldLock.id,
            OwnerId = salesRep.Id
         );

         insert l3;



        List<Map<String, Object>> mapList = new List<Map<String, Object>>();
        Map<String, Object> testData = new Map<String, Object>{
            'id' => l3.id,
            'uniqueId' => '500',
            'owner' => 'XIAO Cathy',
            'status' => 'Sales Qualified',
            'sale_email' => 'cathy.xiao@savencia.com.invalid',
            'transition_status' => '未转换',
            'oldStatus' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'oldStatus' => null,
                    'owner' => 'Zhu Gloria',
                    'sale_email' => null,
                    'status' => null,
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-26 21:50:23'
                },
                new Map<String, Object>{
                    'oldStatus' => 'Assigned',
                    'owner' => 'XIAO Cathy',
                    'sale_email' => 'cathy.xiao@savencia.com.invalid',
                    'status' => 'Sales Qualified',
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-30 00:42:05'
                }
            }
        };
        mapList.add(testData);
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        
        Test.startTest();
        List<Lead> sendSuccess = CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatus(mapList);
        Test.stopTest();
        Database.executeBatch(new CN_Lead_Upsert_To_Mg_Batch());   
        
    }



    @isTest
    static void testSendMgLeadStatusWith503() {
        TestDataFactory testDataFactory = new TestDataFactory();
        testDataFactory.makeTalendSetting();
        // testDataFactory.makeCustomSetting();    
         TestDataFactory testFactory = new TestDataFactory();
         testFactory.makeFactoryAccount();
         List<User> userList = [SELECT Id, LastName FROM User];
         Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
         for(User usr: userList) {
             lastNameUserIdMap.put(usr.LastName, usr.Id);
         }
         
         Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
         User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
         User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));
         User SalesMDM = New User(Id = lastNameUserIdMap.get('SalesMDM'));
         User SystemIntegration = New User(Id = lastNameUserIdMap.get('System Integration'));
         CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
         insert fieldLock;
 
         
         Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
         CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
         CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
 
         List<Lead> leadList = new List<Lead>();
         Lead l3 = new Lead(
            recordTypeId = cnLeadRTId,
            Company = 'Test Class Lead',
            LastName  = 'Lead last Name',
            FirstName = 'Lead First Name',
            LeadSource = 'E-Commerce',
            CN_Customer_Category__c = 'Restaurant',
            Status = 'Open',
            MobilePhone = '15748484848',
            CN_Province__c = province.Id,
            CN_City__c = city.Id,
            CN_Street__c = 'Lead Visit Address',
            CN_Zip_Postal_Code__c = '123456',
            CN_Status_Change_Records__c = '旧数据',
            CN_Field_Lock__c =fieldLock.id,
            OwnerId = salesRep.Id
         );

         insert l3;
        List<Map<String, Object>> mapList = new List<Map<String, Object>>();
        Map<String, Object> testData = new Map<String, Object>{
            'id' => l3.id,
            'uniqueId' => '503',
            'owner' => 'XIAO Cathy',
            'status' => 'Sales Qualified',
            'sale_email' => 'cathy.xiao@savencia.com.invalid',
            'transition_status' => '未转换',
            'oldStatus' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'oldStatus' => null,
                    'owner' => 'Zhu Gloria',
                    'sale_email' => null,
                    'status' => null,
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-26 21:50:23'
                },
                new Map<String, Object>{
                    'oldStatus' => 'Assigned',
                    'owner' => 'XIAO Cathy',
                    'sale_email' => 'cathy.xiao@savencia.com.invalid',
                    'status' => 'Sales Qualified',
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-30 00:42:05'
                }
            }
        };
        mapList.add(testData);
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        
        Test.startTest();
        List<Lead> sendSuccess = CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatus(mapList);
        Test.stopTest();
        Database.executeBatch(new CN_Lead_Upsert_To_Mg_Batch());   
        
    }

    @isTest
    static void testSendMgLeadStatusWith404() {
        TestDataFactory testDataFactory = new TestDataFactory();
        testDataFactory.makeTalendSetting();
        // testDataFactory.makeCustomSetting();    
         TestDataFactory testFactory = new TestDataFactory();
         testFactory.makeFactoryAccount();
         List<User> userList = [SELECT Id, LastName FROM User];
         Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
         for(User usr: userList) {
             lastNameUserIdMap.put(usr.LastName, usr.Id);
         }
         
         Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
         User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
         User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));
         User SalesMDM = New User(Id = lastNameUserIdMap.get('SalesMDM'));
         User SystemIntegration = New User(Id = lastNameUserIdMap.get('System Integration'));
         CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
         insert fieldLock;
 
         
         Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
         CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
         CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
 
         List<Lead> leadList = new List<Lead>();
         Lead l3 = new Lead(
            recordTypeId = cnLeadRTId,
            Company = 'Test Class Lead',
            LastName  = 'Lead last Name',
            FirstName = 'Lead First Name',
            LeadSource = 'E-Commerce',
            CN_Customer_Category__c = 'Restaurant',
            Status = 'Open',
            MobilePhone = '15748484848',
            CN_Province__c = province.Id,
            CN_City__c = city.Id,
            CN_Street__c = 'Lead Visit Address',
            CN_Zip_Postal_Code__c = '123456',
            CN_Status_Change_Records__c = '旧数据',
            CN_Field_Lock__c =fieldLock.id,
            OwnerId = salesRep.Id
         );

         insert l3;



        List<Map<String, Object>> mapList = new List<Map<String, Object>>();
        Map<String, Object> testData = new Map<String, Object>{
            'id' => l3.id,
            'uniqueId' => '404',
            'owner' => 'XIAO Cathy',
            'status' => 'Sales Qualified',
            'sale_email' => 'cathy.xiao@savencia.com.invalid',
            'transition_status' => '未转换',
            'oldStatus' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'oldStatus' => null,
                    'owner' => 'Zhu Gloria',
                    'sale_email' => null,
                    'status' => null,
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-26 21:50:23'
                },
                new Map<String, Object>{
                    'oldStatus' => 'Assigned',
                    'owner' => 'XIAO Cathy',
                    'sale_email' => 'cathy.xiao@savencia.com.invalid',
                    'status' => 'Sales Qualified',
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-30 00:42:05'
                }
            }
        };
        mapList.add(testData);
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        
        Test.startTest();
        List<Lead> sendSuccess = CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatus(mapList);
        Test.stopTest();
        Database.executeBatch(new CN_Lead_Upsert_To_Mg_Batch());   
    }


    @isTest
    static void testSendMgLeadStatusWith400() {
        TestDataFactory testDataFactory = new TestDataFactory();
        testDataFactory.makeTalendSetting();
        // testDataFactory.makeCustomSetting();    
         TestDataFactory testFactory = new TestDataFactory();
         testFactory.makeFactoryAccount();
         List<User> userList = [SELECT Id, LastName FROM User];
         Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
         for(User usr: userList) {
             lastNameUserIdMap.put(usr.LastName, usr.Id);
         }
         
         Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
         User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
         User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));
         User SalesMDM = New User(Id = lastNameUserIdMap.get('SalesMDM'));
         User SystemIntegration = New User(Id = lastNameUserIdMap.get('System Integration'));
         CN_Field_Lock__c fieldLock = new CN_Field_Lock__c(CN_Need_Send_MG_Flag__c = 1);
         insert fieldLock;
 
         
         Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
         CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
         CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
 
         List<Lead> leadList = new List<Lead>();
         Lead l3 = new Lead(
            recordTypeId = cnLeadRTId,
            Company = 'Test Class Lead',
            LastName  = 'Lead last Name',
            FirstName = 'Lead First Name',
            LeadSource = 'E-Commerce',
            CN_Customer_Category__c = 'Restaurant',
            Status = 'Open',
            MobilePhone = '15748484848',
            CN_Province__c = province.Id,
            CN_City__c = city.Id,
            CN_Street__c = 'Lead Visit Address',
            CN_Zip_Postal_Code__c = '123456',
            CN_Status_Change_Records__c = '旧数据',
            CN_Field_Lock__c =fieldLock.id,
            OwnerId = salesRep.Id
         );

         insert l3;


        List<Map<String, Object>> mapList = new List<Map<String, Object>>();
        Map<String, Object> testData = new Map<String, Object>{
            'id' => l3.id,
            'uniqueId' => '400',
            'owner' => 'XIAO Cathy',
            'status' => 'Sales Qualified',
            'sale_email' => 'cathy.xiao@savencia.com.invalid',
            'transition_status' => '未转换',
            'oldStatus' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'oldStatus' => null,
                    'owner' => 'Zhu Gloria',
                    'sale_email' => null,
                    'status' => null,
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-26 21:50:23'
                },
                new Map<String, Object>{
                    'oldStatus' => 'Assigned',
                    'owner' => 'XIAO Cathy',
                    'sale_email' => 'cathy.xiao@savencia.com.invalid',
                    'status' => 'Sales Qualified',
                    'uniqueId' => '1027',
                    'updateDate' => '2023-12-30 00:42:05'
                }
            }
        };
        mapList.add(testData);
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        System.debug('601 ---400 request');
        Test.startTest();
        List<Lead> sendSuccess = CN_Lead_Upsert_To_Mg_Callout.sendMgLeadStatus(mapList);
        Test.stopTest();
        Database.executeBatch(new CN_Lead_Upsert_To_Mg_Batch());   
    }

    
}