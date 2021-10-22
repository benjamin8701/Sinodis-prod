/**************************************************************************************************
 * Name           : CN_CR_Prevent_Delete_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2021-06-09
 * Modify History : 
 **************************************************************************************************/
@isTest
public class CN_CR_Prevent_Delete_Handler_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void handleBeforeDelete() {
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
            Id newContactRTId = Schema.SObjectType.CN_Change_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CR_RT_API_NAME_NEW_CONTACT).getRecordTypeId();
            CN_Change_Request__c cr = new CN_Change_Request__c();
            cr.RecordTypeId = newContactRTId;
            cr.New_CN_Contact_Type__c = '04';
            cr.New_CN_Contact_License_Name__c = acc_factory.Id;
            cr.New_CN_Contact_Title__c = 'CR Contact Title';
            cr.New_CN_Contact_Dept_Of_Contact_Person__c = '0002';
            cr.New_CN_Contact_CN_First_Name__c = 'Contact 01';
            cr.New_CN_Contact_CN_Last_Name__c = 'Test CR';
            cr.New_CN_Contact_Name_EN__c = 'Test CR Contact Name 01';
            cr.New_CN_Contact_Mobile__c = '15755555551';
            cr.New_CN_Contact_Billing_To_Address__c = 'CR Bill to Address';
            cr.CN_Is_Generate_From_Action__c = true;
            insert cr;

            CN_Change_Request__c cr_update = new CN_Change_Request__c();
            cr_update.Id = cr.Id;
            cr_update.CN_Change_Request_Status__c = Constants.CN_CR_STATUS_READY_FOR_APPROVAL;
            update cr_update;

            Test.startTest();
            CN_Change_Request__c cr_delete = new CN_Change_Request__c();
            cr_delete.id = cr.Id;
            try{
                delete cr_delete;
            }catch(Exception e){}
            Test.stopTest();

        }
    }
}