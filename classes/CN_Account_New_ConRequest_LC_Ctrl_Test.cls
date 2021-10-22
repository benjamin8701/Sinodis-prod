/**************************************************************************************************
 * Name           : CN_Account_New_ConRequest_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Account_New_ConRequest_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeUpdate() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        
        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        System.runAs(salesRep) {

            Account acc_update1 = new Account();
            acc_update1.Id = acc_factory.Id;
            acc_update1.CN_Account_Status__c = 'Ready for Approval';
            update acc_update1;

            Account acc_update2 = new Account();
            acc_update2.Id = acc_factory.Id;
            acc_update2.CN_Account_Status__c = 'Submitted for Approval';
            update acc_update2;

            Account acc_update3 = new Account();
            acc_update3.Id = acc_factory.Id;
            acc_update3.CN_Account_Status__c = 'Approved';
            acc_update3.CN_Sync_Status__c = 'Success';
            acc_update3.CN_Approve_Step__c = '';
            update acc_update3;

            CN_Change_Request__c cr = new CN_Change_Request__c();
            Map<String, Object> Account_new_ConRequest_LC_Ctrl_ResultMap = CN_Account_New_Contact_Request_LC_Ctrl.getContact(acc_factory.Id);
            Object crRTId = Account_new_ConRequest_LC_Ctrl_ResultMap.get('crRTId');
            Account acc_source = (Account)Account_new_ConRequest_LC_Ctrl_ResultMap.get('sourceAccount');
            cr.recordtypeId = (String)crRTId;
            cr.New_CN_Contact_License_Name__c = acc_source.id;
            cr.New_CN_Contact_Type__c = '04';
            cr.New_CN_Contact_Title__c = 'contact title';
            cr.CN_Is_Generate_From_Action__c = true;
            cr.New_CN_Contact_CN_First_Name__c = 'Test';
            cr.New_CN_Contact_CN_Last_Name__c = 'Test CR_update';
            cr.New_CN_Contact_Dept_Of_Contact_Person__c = '0001';
            cr.New_CN_Contact_Name_EN__c = 'Contact Name EN';
            cr.New_CN_Contact_Mobile__c = '15755555555';
            cr.New_CN_Contact_Billing_To_Address__c = 'Billing to address';

            test.startTest();
            
            insert cr;

            test.stopTest();

        }
    }
}