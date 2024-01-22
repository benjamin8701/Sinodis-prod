/**************************************************************************************************
 * Name           : CN_Lead_MKT_Assigned_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-10-11
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Lead_MKT_Assigned_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeUpdate() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        testFactory.makeTalendSetting();
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        
        Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
        User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
        User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));
        User SalesMDM = New User(Id = lastNameUserIdMap.get('SalesMDM'));

        
        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];

        List<Lead> leadList = new List<Lead>();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        System.runAs(salesRep){
            Lead l = new Lead(
                recordTypeId = cnLeadRTId,
                Company = 'Test Class Lead',
                LastName  = 'Lead last Name',
                FirstName = 'Lead First Name',
                LeadSource = 'Website',
                CN_Customer_Category__c = 'Restaurant',
                Status = 'Open',
                MobilePhone = '15748484848',
                CN_Province__c = province.Id,
                CN_City__c = city.Id,
                CN_Street__c = 'Lead Visit Address',
                CN_Zip_Postal_Code__c = '123456',
                OwnerId = salesRep.Id
            );

            //add by  Zhang Zhihao 2023.12.21 
            Lead l2 = new Lead(
                recordTypeId = cnLeadRTId,
                Company = 'Test Class Lead2',
                LastName  = 'Lead last Name ZHU Eleven',
                FirstName = 'Lead First Name',
                LeadSource = 'E-Commerce',
                CN_Customer_Category__c = 'Restaurant',
                Status = 'Open',
                MobilePhone = '15794949494',
                CN_Province__c = province.Id,
                CN_City__c = city.Id,
                CN_Street__c = 'Lead Visit Address',
                CN_Zip_Postal_Code__c = '123456',
               // OwnerId = '0055h000002YBBtAAO'
                OwnerId= salesRep2.id
            );

            Lead l3 = new Lead(
                recordTypeId = cnLeadRTId,
                Company = 'Test Class Lead2',
                LastName  = 'Lead last Name Gong Grance',
                FirstName = 'Lead First Name',
                LeadSource = 'E-Commerce',
                CN_Customer_Category__c = 'Restaurant',
                Status = 'Open',
                MobilePhone = '15794949494',
                CN_Province__c = province.Id,
                CN_City__c = city.Id,
                CN_Street__c = 'Lead Visit Address',
                CN_Zip_Postal_Code__c = '123456',
                //OwnerId = '0055h0000042wvhAAA'
                OwnerId= SalesMDM.id

            );
            //add by  Zhang Zhihao 2023.12.21 

            leadList.add(l);
            //add by  Zhang Zhihao 2023.12.21 
            leadList.add(l2);
            leadList.add(l3);
            //add by  Zhang Zhihao 2023.12.21 
            insert leadList; 

            System.debug('leadList=====================>'+leadList[0]);
            System.debug('leadList 1=====================>'+leadList[1]);
            System.debug('leadList 2=====================>'+leadList[2]);
            List<Lead> leadList_update = new List<Lead>();
            Lead lead_update = new Lead();
            Lead lead_update2 = new Lead();
            Lead lead_update3 = new Lead();
            lead_update.Id = leadList[0].Id;
            lead_update.Status = 'MKT Qualified';

            lead_update2.Id = leadList[1].Id;
            lead_update2.OwnerId = SalesMDM.id;

            lead_update3.Id = leadList[2].Id;
            lead_update3.OwnerId = salesRep2.id;

            leadList_update.add(lead_update);
            leadList_update.add(lead_update2);
            leadList_update.add(lead_update3);

            update leadList_update;
            System.debug('leadList 1=====================>'+leadList[1]);
            System.debug('leadList 2=====================>'+leadList[2]);
        }
        Test.stopTest();
    }

     //add by  Zhang Zhihao 2023.12.21 
    @isTest
    private static void handleBeforeInsert() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        testFactory.makeTalendSetting();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        
        Id cnLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Constants.CN_Lead_RT_API_NAME).getRecordTypeId();
        User salesRep = New User(Id = lastNameUserIdMap.get('Sales1'));
        User salesRep2 = New User(Id = lastNameUserIdMap.get('Sales2'));
        User SalesMDM = New User(Id = lastNameUserIdMap.get('SalesMDM'));
        

        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];

        List<Lead> leadList = new List<Lead>();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        System.runAs(salesRep){
        
            //add by  Zhang Zhihao 2023.12.21
            Lead l2 = new Lead(
                recordTypeId = cnLeadRTId,
                Company = 'Test Class Lead2',
                LastName  = 'Lead last Name ZHU Eleven',
                FirstName = 'Lead First Name',
                LeadSource = 'E-Commerce',
                CN_Customer_Category__c = 'Restaurant',
                Status = 'Open',
                MobilePhone = '15794949494',
                CN_Province__c = province.Id,
                CN_City__c = city.Id,
                CN_Street__c = 'Lead Visit Address',
                CN_Zip_Postal_Code__c = '123456',
                OwnerId = SalesMDM.ID
            );

            Lead l3 = new Lead(
                recordTypeId = cnLeadRTId,
                Company = 'Test Class Lead2',
                LastName  = 'Lead last Name Gong Grance',
                FirstName = 'Lead First Name',
                LeadSource = 'E-Commerce',
                CN_Customer_Category__c = 'Restaurant',
                Status = 'Open',
                MobilePhone = '15794949494',
                CN_Province__c = province.Id,
                CN_City__c = city.Id,
                CN_Street__c = 'Lead Visit Address',
                CN_Zip_Postal_Code__c = '123456',
                OwnerId = salesRep.ID
            );
            //add by  Zhang Zhihao 2023.12.21 

            //add by  Zhang Zhihao 2023.12.21 
            leadList.add(l2);
            leadList.add(l3);
            //add by  Zhang Zhihao 2023.12.21 
            insert leadList; 

            System.debug('leadList=====================>'+leadList[0]);
            System.debug('leadList=====================>'+leadList[1]);
        }
        Test.stopTest();
    }
     //add by  Zhang Zhihao 2023.12.21 
}