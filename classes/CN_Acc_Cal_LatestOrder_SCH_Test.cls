/**************************************************************************************************
 * Name           : CN_Acc_Cal_LatestOrder_SCH_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Acc_Cal_LatestOrder_SCH_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void executeTest() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        List<Account> accList = new List<Account>();
        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        Account acc_factory = [SELECT Id,Name FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];
        accList.add(acc_factory);
        testFactory.approveAccount(accList);

        CN_Sales_Order__c salesOrder = new CN_Sales_Order__c();
        salesOrder.CN_Billing_Block__c = '';
        salesOrder.CN_Credit_Status__c = '';
        salesOrder.CN_Currency__c = 'CNY';
        salesOrder.CN_Delivery_Block__c = '';
        salesOrder.CN_Delivery_Status__c = 'C';
        salesOrder.CN_Distribution_Channel__c = 'KA';
        salesOrder.CN_Division__c = '01';
        salesOrder.CN_AR_Person__r = new CN_Internal_Employee__c(CN_Personnel_Number__c = 'Test0002');
        salesOrder.CN_Incoterms1__c = 'CFR';
        salesOrder.CN_Incoterms2__c = 'CFR';
        salesOrder.CN_Order_Net_Value__c = 12345.67;
        salesOrder.CN_Order_Reason__r = new CN_Order_Reason__c(CN_Order_Reason_External_ID__c = '010');
        salesOrder.CN_Order_Reference_No__c = '1234567890';
        salesOrder.CN_PO_Number__c = '1234567890';
        salesOrder.CN_Up_Code__c = '1234567890';
        salesOrder.CN_Sales_Order_Type__r = new CN_Sales_Order_Type__c(CN_Sales_Order_Type_External_ID__c = 'OR1');
        salesOrder.CN_Sales_Organization__c = 'S010';
        salesOrder.CN_Sales_Person_Name__r = new CN_Internal_Employee__c(CN_Personnel_Number__c = 'Test0001');
        salesOrder.CN_SAP_Create_By__c = 'Test0001';
        salesOrder.CN_SAP_Create_Date__c = Date.today();
        salesOrder.CN_Sold_To_Account_Name__r = new Account(CN_Customer_Code__c = 'TestAccount_Factory');
        salesOrder.CN_Tax_Amount__c = 123456789.01;
        insert salesOrder;

        System.schedule('CN_Account_Calculate_LatestOrder_SCH' + datetime.now().getTime(), '20 30 8 10 2 ?', new CN_Account_Calculate_LatestOrder_SCH());
        Database.executeBatch(new CN_Account_Calculate_LatestOrder_Batch());
    }
}