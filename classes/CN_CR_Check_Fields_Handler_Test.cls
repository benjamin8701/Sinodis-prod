/**************************************************************************************************
 * Name           : CN_CR_Check_Fields_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-11
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_CR_Check_Fields_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeUpdate() {

        Id updateAccountRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_ACCOUNT).getRecordTypeId();
        Id updateContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_CONTACT).getRecordTypeId();
        Id updateShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_UPDATE_SHIPTO).getRecordTypeId();
        Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
        Id newShiptoRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_SHIPTO).getRecordTypeId();

        integer num_factory = 10;
        List<Account> accList_factory = TestDataFactory.makeAccounts(10);
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        User AR = [SELECT Id FROM User WHERE lastName = 'FinanceAR'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];

        System.runAs(salesRep) {

            List<Account> accList_updateEx = new List<Account>();
            for(Account acc : accList_factory){
                Account acc_updateEx = new Account();
                acc_updateEx.Id = acc.Id;
                acc_updateEx.CN_Sync_Status__c = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
                acc_updateEx.CN_Account_Status__c = Constants.CN_ACCOUNT_ACCOUNT_STATUS_APPROVED;
                accList_updateEx.add(acc_updateEx);
            }
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = true;
            Database.SaveResult[] srList = Database.update(accList_updateEx, dml);
            
        }
        System.runAs(AR) {
            List<CN_Change_Request__c> crList = new List<CN_Change_Request__c>();
            for(Account acc : accList_factory){
                CN_Change_Request__c cr = new CN_Change_Request__c();
                Map<String, Object> AccountCR_LC_Ctrl_ResultMap = CN_Account_Change_Request_LCController.getAccount(acc.Id);
                for(String field : ((Map<String, String>)AccountCR_LC_Ctrl_ResultMap.get('fieldMap')).keySet()){
                    Account acc_source = (Account)AccountCR_LC_Ctrl_ResultMap.get('sourceAccount');
                    cr.put(field,acc_source.get( ((Map<String, String>)AccountCR_LC_Ctrl_ResultMap.get('fieldMap')).get(field)));
                }
                cr.CN_Account_Name__c = acc.Id;
                cr.New_CN_Account_License_Name_EN__c = 'TestClass_Account_update';
                cr.CN_Is_Generate_From_Action__c = true;
                cr.RecordTypeId = updateAccountRTId;
                system.debug('lastNameUserIdMap.get(FinanceAR):    '+lastNameUserIdMap.get('FinanceAR'));
                cr.New_CN_Account_Owner__c = lastNameUserIdMap.get('FinanceAR');
                crList.add(cr);
            }
            
            Test.startTest();

            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = true;
            Database.SaveResult[] srList_2 = Database.insert(crList, dml);

            integer num_update = 0;
            List<CN_Change_Request__c> crList_update = new List<CN_Change_Request__c>();
            CN_Change_Request__c cr1_update = new CN_Change_Request__c();
            cr1_update.id = crList[num_update++].Id;
            cr1_update.New_CN_Contact_Type__c = '01;02;04';
            cr1_update.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_READY_FOR_APPROVAL;
            cr1_update.New_CN_Account_Owner__c = salesRep.Id;
            crList_update.add(cr1_update);

            CN_Change_Request__c cr2_update = new CN_Change_Request__c();
            cr2_update.id = crList[num_update++].Id;
            cr2_update.New_CN_Contact_Type__c = '01;02;04';
            crList_update.add(cr2_update);

            update crList_update;



            Test.stopTest();
        }
    }

}