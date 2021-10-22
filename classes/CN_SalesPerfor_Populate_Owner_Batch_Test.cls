/**************************************************************************************************
 * Name           : CN_SalesPerfor_Populate_Owner_Batch_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_SalesPerfor_Populate_Owner_Batch_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_SalesPerfor_Populate_Owner_Batch_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();

        Account acc_factory = [SELECT Id FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }

        Id SalesPerforRTId = Schema.SObjectType.CN_Sales_Performance__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SP_RT_API_NAME_PERFORMANCE).getRecordTypeId();
        List<Product2> SKUList = [SELECT Id, Name, CN_SKU_Code__c FROM Product2];

        Test.startTest();

        CN_Sales_Performance__c sp = new CN_Sales_Performance__c(
            CN_Material_SAP__c = SKUList[0].CN_SKU_Code__c,
            RecordTypeId = SalesPerforRTId,
            CN_Customer__c = acc_factory.Id
        );
        insert sp;
        
        acc_factory.ownerId = lastNameUserIdMap.get('Sales2');
        update acc_factory;

        CN_Sales_Performance__c sp1 = [Select Id,CN_Is_Customer_Owner_Changed__c,CN_Customer_Owner__c,Owner.Name, CN_Customer__r.Owner.Name,RecordType.DeveloperName From CN_Sales_Performance__c];
        System.debug(sp1.Owner.Name);
        System.debug(sp1.CN_Customer__r.Owner.Name);
        System.debug(sp1.RecordType.DeveloperName);
        System.debug(sp1.CN_Is_Customer_Owner_Changed__c);
        CN_SalesPerfor_Populate_Owner_SCH sch = new CN_SalesPerfor_Populate_Owner_SCH();
        System.schedule('CN_SalesPerfor_Populate_Owner_SCH' + Datetime.now(), '20 30 8 10 2 ?', sch);

        Test.stopTest();
    }
}