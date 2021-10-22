/**************************************************************************************************
 * Name           : CN_Mass_Change_Acc_Owner_LC_Ctrl_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Mass_Change_Acc_Owner_LC_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void CN_Mass_Change_Acc_Owner_LC_Ctrl_Change_Owner_Test() {
        Map<String, String> paramMap = new Map<String, String>();

        paramMap.put('UserNumber', 'Test0001');
        paramMap.put('changeTypeList', 'Change Owner');
        paramMap.put('changeUserNumber', 'Test00012');

        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account acc_factory = [SELECT Id, Name, CN_Customer_Code__c FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        acc_factory.CN_Customer_Code__c = acc_factory.Name;
        acc_factory.CN_Account_Status__c = 'Approved';
        acc_factory.CN_Sync_Status__c = 'Fail';
        acc_factory.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_APPROVE_DIRECT).getRecordTypeId();
        update acc_factory;
        //testFactory.approveAccount(new List<Account>{acc_factory});

        String customerCode = acc_factory.Name;
        System.debug(customerCode);
        Test.startTest();

        Map<String, List<String>> titleMap = new Map<String, List<String>>();
        titleMap.put('Account', new List<String>{'Id', 'Name', 'CN_Customer_Code__c', 'Ownerid', 'CN_Sinodis_Finance_AR__c', 'CN_Route_To_Market__c', 'CN_Account_Status__c', 'CN_Sync_Status__c'});
        titleMap.put('Contact', new List<String>());
        CN_Mass_Change_Account_Owner_LC_Ctrl.getTitleAura(titleMap);

        List<String> titleList = new List<String>();
        titleList.add('Account');
        titleList.add('Contact');
        CN_Mass_Change_Account_Owner_LC_Ctrl.getTitle(titleList);
        CN_Mass_Change_Account_Owner_LC_Ctrl.fetchUser();

        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, false, '');
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, false, customerCode);

        paramMap.put('UserNumber', '');

        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, false, '');
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, false, customerCode);

        paramMap.put('UserNumber', 'Test0001');

        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, customerCode);

        Account acc1 = new Account();
        acc1.Id = acc_factory.Id;
        acc1.CN_Account_Status__c = 'Approved';
        acc1.CN_Sync_Status__c = 'Success';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_APPROVE_DIRECT).getRecordTypeId();
        update acc1;

        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, customerCode);
        
        Account acc2 = new Account();
        acc2.Id = acc_factory.Id;
        acc2.CN_Account_Status__c = 'Ready for Approval';
        acc2.CN_Sync_Status__c = '';
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_EDIT_DIRECT).getRecordTypeId();
        update acc2;
        
        System.debug([SELECT Id, RecordType.DeveloperName, CN_Account_Status__c FROM Account]);

        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, customerCode);

        Test.stopTest();
    }

    @isTest
    private static void CN_Mass_Change_Acc_Owner_LC_Ctrl_Change_Owner_Test2() {
        Map<String, String> paramMap = new Map<String, String>();

        paramMap.put('UserNumber', 'Test0001');
        paramMap.put('changeTypeList', 'Change Owner');
        paramMap.put('changeUserNumber', 'Test00012');

        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account acc_factory = [SELECT Id, Name, CN_Customer_Code__c FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        String customerCode = acc_factory.Name;
        System.debug(customerCode);
        Test.startTest();

        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, '');

        Test.stopTest();
    }

    @isTest
    private static void CN_Mass_Change_Acc_Owner_LC_Ctrl_Change_FinAR_Test() {
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('UserNumber', 'Test0002');
        paramMap.put('changeTypeList', 'Change Finance AR');
        paramMap.put('changeUserNumber', 'Test0021');

        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account acc_factory = [SELECT Id, Name, CN_Customer_Code__c FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        acc_factory.CN_Customer_Code__c = acc_factory.Name;
        acc_factory.CN_Account_Status__c = 'Approved';
        acc_factory.CN_Sync_Status__c = 'Fail';
        acc_factory.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_APPROVE_DIRECT).getRecordTypeId();
        update acc_factory;
        String customerCode = acc_factory.Name;
        System.debug(customerCode);
        Test.startTest();

        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, false, '');
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, false, customerCode);

        paramMap.put('UserNumber', '');

        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, false, '');
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, false, customerCode);

        paramMap.put('UserNumber', 'Test0002');
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, customerCode);

        Account acc1 = new Account();
        acc1.Id = acc_factory.Id;
        acc1.CN_Account_Status__c = 'Approved';
        acc1.CN_Sync_Status__c = 'Success';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_APPROVE_DIRECT).getRecordTypeId();
        update acc1;

        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, customerCode);

        Test.stopTest();
    }

    @isTest
    private static void CN_Mass_Change_Acc_Owner_LC_Ctrl_Change_FinAR_Test2() {
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('UserNumber', 'Test0002');
        paramMap.put('changeTypeList', 'Change Finance AR');
        paramMap.put('changeUserNumber', 'Test0021');

        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account acc_factory = [SELECT Id, Name, CN_Customer_Code__c FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        acc_factory.CN_Customer_Code__c = acc_factory.Name;
        update acc_factory;
        String customerCode = acc_factory.Name;
        System.debug(customerCode);
        Test.startTest();
        
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, '');

        Test.stopTest();
    }

    @isTest
    private static void CN_Mass_Change_Acc_Owner_LC_Ctrl_Exception_Test() {
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('UserNumber', 'Test0001');
        paramMap.put('changeTypeList', '');
        paramMap.put('changeUserNumber', 'Test00012');

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account acc_factory = [SELECT Id, Name, CN_Customer_Code__c FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        acc_factory.CN_Sinodis_Finance_AR__c = lastNameUserIdMap.get('FinanceAR');
        testFactory.approveAccount(new List<Account>{acc_factory});
        String customerCode = acc_factory.Name;
        System.debug(customerCode);
        Test.startTest();
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, false, customerCode);

        System.debug([SELECT Id,Owner.CN_User_Personnel_Number__c,CN_Customer_Code__c FROM Account]);

        paramMap.put('changeTypeList', 'Change Owner');
        paramMap.put('changeUserNumber', 'Test0001200');
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, customerCode);

        paramMap.put('changeTypeList', 'Change Owner');
        paramMap.put('UserNumber', 'Test0001200');
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, customerCode);

        paramMap.put('changeTypeList', 'Change Finance AR');
        paramMap.put('changeUserNumber', 'Test000200');
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, customerCode);

        paramMap.put('changeTypeList', 'Change Finance AR');
        paramMap.put('UserNumber', 'Test000200');
        CN_Mass_Change_Account_Owner_LC_Ctrl.searchAccount(paramMap, true, customerCode);
        Test.stopTest();
    }
}