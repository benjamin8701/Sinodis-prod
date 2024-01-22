/**************************************************************************************************
 * Name           : CN_Lead_Status_Send_Mg_Handler_Test
 * Object         :
 * Requirement    :
 * Target         :
 * Refer classes  :
 * Author         : Zhang Zhihao
 * Create Date    : 2023-12-25
 * Modify History :
 **************************************************************************************************/
@isTest
private class CN_Lead_Status_Send_Mg_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void UpdateHandle() {
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
          User SystemIntegration = New User(Id = lastNameUserIdMap.get('System Integration'));
          Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

          CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
          CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
          Test.setMock(HttpCalloutMock.class, new TestHttpMock());
          List<Lead> leadList = new List<Lead>();

          Test.startTest();
          System.runAs(salesRep){
              Lead l1 = new Lead(
                  recordTypeId = cnLeadRTId,
                  Company = 'Test Class Lead_l',
                  LastName  = 'Lead last Name',
                  FirstName = 'Lead First Name',
                  LeadSource = 'Social Media',
                  CN_Customer_Category__c = 'Restaurant',
                  Status = 'Open',
                  MobilePhone = '15748484848',
                  CN_Province__c = province.Id,
                  CN_City__c = city.Id,
                  CN_Street__c = 'Lead Visit Address',
                  CN_Zip_Postal_Code__c = '123456',
                  OwnerId = salesRep.Id
              );
              Lead l2 = new Lead(
                  recordTypeId = cnLeadRTId,
                  Company = 'Test Class Lead_l2',
                  LastName  = 'Lead last Name',
                  FirstName = 'Lead First Name',
                  LeadSource = 'E-Commerce',
                  CN_Customer_Category__c = 'Restaurant',
                  Status = 'Open',
                  MobilePhone = '15748484848',
                  CN_Province__c = province.Id,
                  CN_City__c = city.Id,
                  CN_Street__c = 'Lead Visit Address',
                  //CN_Field_Lock__c =null,
                  CN_Status_Change_Records__c = '',
                  CN_Zip_Postal_Code__c = '123456',
                  OwnerId = salesRep.Id
              );
               Lead l3 = new Lead(
                recordTypeId = cnLeadRTId,
                Company = 'Test Class Lead_l3',
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
                CN_Status_Change_Records__c = '{"oldStatus":null,"owner":"Zhu Gloria","sale_email":null,"status":null,"uniqueId":"983","updateDate":"2023-12-05 17:35:18"},',
                //CN_Field_Lock__c =fieldLock.id,
                OwnerId = salesRep.Id
            );
              leadList.add(l1);
              leadList.add(l2);
              leadList.add(l3);
              insert leadList;

            CN_Change_Request__c changeRequest = new CN_Change_Request__c();
            changeRequest.CN_From_Lead__c = l2.id;
            changeRequest.New_CN_Contact_License_Name__c = acc_factory.id;
            insert changeRequest;

            List<Lead> leadList_update = new List<Lead>();
            Lead lead_update1 = new Lead();
            lead_update1.Id = leadList[0].Id;
            lead_update1.Status = 'MKT Qualified';
            lead_update1.CN_Field_Lock__c = null;

            Lead lead_update2 = new Lead();
            lead_update2.Id = leadList[1].Id;
            lead_update2.Status = 'Closed - Converted';

            Lead lead_update3 = new Lead();
            lead_update3.Id = leadList[2].Id;
            lead_update3.Status = 'Closed - Converted';

            leadList_update.add(lead_update1);
            leadList_update.add(lead_update2);
            leadList_update.add(lead_update3);

            update leadList_update;
          }
        Test.stopTest();
    }

    @isTest
    private static void InsertHandle() {
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
          User SystemIntegration = New User(Id = lastNameUserIdMap.get('System Integration'));


          Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
          CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
          CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
          List<Lead> leadList = new List<Lead>();
          Test.setMock(HttpCalloutMock.class, new TestHttpMock());
          Test.startTest();
          System.runAs(salesRep){
              Lead l = new Lead(
                  recordTypeId = cnLeadRTId,
                  Company = 'Test Class Lead',
                  LastName  = 'Lead last Name_l1',
                  FirstName = 'Lead First Name',
                  LeadSource = 'Social Media',
                  CN_Customer_Category__c = 'Restaurant',
                  Status = 'Open',
                  MobilePhone = '15748484848',
                  CN_Province__c = province.Id,
                  CN_City__c = city.Id,
                  CN_Street__c = 'Lead Visit Address',
                  CN_Zip_Postal_Code__c = '123456',
                  OwnerId = salesRep.Id
              );
              Lead l2 = new Lead(
                  recordTypeId = cnLeadRTId,
                  Company = 'Test Class Lead',
                  LastName  = 'Lead last Name_l2',
                  FirstName = 'Lead First Name',
                  LeadSource = 'E-Commerce',
                  CN_Customer_Category__c = 'Restaurant',
                  Status = 'Open',
                  MobilePhone = '15748484848',
                  CN_Province__c = province.Id,
                  CN_City__c = city.Id,
                  CN_Street__c = 'Lead Visit Address',
                  CN_Zip_Postal_Code__c = '123456',
                  OwnerId = SystemIntegration.Id
              );
               Lead l3 = new Lead(
                CN_UniqueId__c ='200',
                recordTypeId = cnLeadRTId,
                Company = 'Test Class Lead',
                LastName  = 'Lead last Name_l3',
                FirstName = 'Lead First Name',
                LeadSource = 'E-Commerce',
                CN_Customer_Category__c = 'Restaurant',
                Status = 'Open',
                MobilePhone = '15748484848',
                CN_Province__c = province.Id,
                CN_City__c = city.Id,
                CN_Street__c = 'Lead Visit Address',
                CN_Zip_Postal_Code__c = '123456',
                CN_Status_Change_Records__c = '{"oldStatus":null,"owner":"Zhu Gloria","sale_email":null,"status":null,"uniqueId":"200","updateDate":"2023-12-05 17:35:18"},',
                OwnerId = salesRep.Id
            );
              leadList.add(l);
              leadList.add(l2);
              leadList.add(l3);
              insert leadList;
          }
        Test.stopTest();
    }
}