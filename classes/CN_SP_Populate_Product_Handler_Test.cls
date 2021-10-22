/**************************************************************************************************
 * Name           : CN_SP_Populate_Product_Handler_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-10-12
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_SP_Populate_Product_Handler_Test {

    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_SP_Populate_Product_Handler_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        List<Account> accListFactory = testFactory.makeFactoryAccount();

        Id SalesPerforRTId = Schema.SObjectType.CN_Sales_Performance__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_SP_RT_API_NAME_PERFORMANCE).getRecordTypeId();
        List<Product2> SKUList = [SELECT Id, Name, CN_SKU_Code__c FROM Product2];

        Test.startTest();

        CN_Sales_Performance__c sp = new CN_Sales_Performance__c(
            CN_Material_SAP__c = SKUList[0].CN_SKU_Code__c,
            RecordTypeId = SalesPerforRTId,
            CN_Customer__c = accListFactory[0].Id
        );
        insert sp;

        sp.CN_Material_SAP__c = SKUList[1].CN_SKU_Code__c;
        update sp;

        Test.stopTest();
    }
}