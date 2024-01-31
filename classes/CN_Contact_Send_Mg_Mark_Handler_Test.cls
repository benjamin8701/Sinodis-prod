/*
 * ************************************************************************************************
 * Name : CN_Contact_Send_Mg_Mark_Handler_Test
 * Object :
 * Requirement : CT-014 Test
 * Target :
 * Refer classes :
 * Author : ZZH
 * Create Date : 2024/1/1
 * Modify History :
 * ************************************************************************************************
 */
@isTest
public class CN_Contact_Send_Mg_Mark_Handler_Test {

    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    
    @isTest
    static void testHandleBeforeInsert1() {

        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account account = [SELECT Id, Name, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];

        Contact con = new Contact();
        con.AccountId = account.Id;
        con.CN_Contact_Type__c = '02';
        con.Title = 'CEO';
        con.CN_Department_Of_Contact_Person__c = '0001';
        con.CN_Contact_Name_EN__c = account.Name + 'Test Contact1';
        con.LastName = 'Contact1';
        con.MobilePhone = '13013001301';
        con.CN_Bill_To_Address__c = 'ABCDE1';
        con.CN_MG_Contact_ID__c = account.CN_MG_Account_ID__c;
        insert con;

    }

    @isTest
    static void testHandleBeforeInsert2() {

        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account account = [SELECT Id, Name, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
        account.CN_Account_Source__c = 'Customer Service Hotline';
        update account;

        Contact con = new Contact();
        con.AccountId = account.Id;
        con.CN_Contact_Type__c = '02';
        con.Title = 'CEO';
        con.CN_Department_Of_Contact_Person__c = '0001';
        con.CN_Contact_Name_EN__c = account.Name + 'Test Contact1';
        con.LastName = 'Contact1';
        con.MobilePhone = '13013001301';
        con.CN_Bill_To_Address__c = 'ABCDE1';
        con.CN_MG_Contact_ID__c = account.CN_MG_Account_ID__c;
        insert con;

    }

    @isTest
    static void testHandleBeforeInsert3() {

        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account account = [SELECT Id, Name, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
        account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
        update account;

        Contact con = new Contact();
        con.AccountId = account.Id;
        con.CN_Contact_Type__c = '02';
        con.Title = 'CEO';
        con.CN_Department_Of_Contact_Person__c = '0001';
        con.CN_Contact_Name_EN__c = account.Name + 'Test Contact1';
        con.LastName = 'Contact1';
        con.MobilePhone = '13013001301';
        con.CN_Bill_To_Address__c = 'ABCDE1';
        con.CN_MG_Contact_ID__c = account.CN_MG_Account_ID__c;
        insert con;

    }
    
    @isTest
    static void testHandleBeforeUpdate1() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account account = [SELECT Id, Name, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
        account.CN_Account_Source__c = null;
        update account;

        Contact contact =  [select id,Name,CN_MG_Contact_Id__c  from Contact WHERE CN_MG_Contact_ID__c = '1'];
        contact.LastName = 'TestUpdate';
        contact.AccountId = account.Id;
        update contact;
    }

    @isTest
    static void testHandleBeforeUpdate2() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account account = [SELECT Id, Name, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
        account.CN_Account_Source__c = 'Customer Service Hotline';
        update account;

        Contact contact =  [select id,Name,CN_MG_Contact_Id__c  from Contact WHERE CN_MG_Contact_ID__c = '1'];
        contact.LastName = 'TestUpdate';
        contact.AccountId = account.Id;
        update contact;
    }

    @isTest
    static void testHandleBeforeUpdate3() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        Contact contact =  [select id,Name,CN_MG_Contact_Id__c  from Contact WHERE CN_MG_Contact_ID__c = '1'];
        contact.LastName = 'TestUpdate';
        contact.AccountId = null;
        update contact;
    }

    @isTest
    static void testHandleBeforeUpdate4() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account account = [SELECT Id, Name, CN_MG_Account_ID__c FROM Account WHERE CN_MG_Account_ID__c = '1'];
        account.CN_Account_Source__c = Constants.CN_ACCOUNT_SOURCE_ECOMMERCE;
        update account;

        Contact contact =  [select id,Name,CN_MG_Contact_Id__c  from Contact WHERE CN_MG_Contact_ID__c = '1'];
        contact.LastName = 'TestUpdate';
        contact.AccountId = account.Id;
        update contact;
    }
}