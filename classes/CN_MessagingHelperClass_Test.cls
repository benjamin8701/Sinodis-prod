@isTest
public class CN_MessagingHelperClass_Test {

    @isTest
    public static void errorpath() {
        
        Map<String, String> postData = new Map<String, String> {
        };

        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/MessagingApi/errorpath';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json;charset=UTF-8');
        request.requestBody = Blob.valueOf(JSON.serialize(postData));
        RestContext.request = request;
        RestContext.response = new RestResponse();

        CN_MessagingHelperClass.Post();
        Test.stopTest();
    }

    @isTest
    public static void returnJWT() {
        
        Map<String, String> postData = new Map<String, String> {
            'uid' => 'KJYHVVUCrl74vd4X6K+LhA=='
        };

        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/MessagingApi/returnJWT';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json;charset=UTF-8');
        request.requestBody = Blob.valueOf(JSON.serialize(postData));
        RestContext.request = request;
        RestContext.response = new RestResponse();

        CN_MessagingHelperClass.Post();
        Test.stopTest();
    }
    
    @isTest
    public static void feedback() {
        Case ca = new Case (
            //Consultation_category__c = '产品咨询',
            Origin = 'Web',
            RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CN_Service_Online').getRecordTypeId()
        );
        insert ca;
        Test.startTest();

        Map<String, String> postData = new Map<String, String> {
            'Id'        => ca.Id,
            'value'     => '2',
            'suggestion'=> 'abc'
        };

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/MessagingApi/feedback';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json;charset=UTF-8');
        request.requestBody = Blob.valueOf(JSON.serialize(postData));
        RestContext.request = request;
        RestContext.response = new RestResponse();

        CN_MessagingHelperClass.Post();
        Test.stopTest();
    }
    
    @isTest
    public static void feedback_err() {
        Test.startTest();

        Map<String, String> postData = new Map<String, String> {
            'Id'        => '1',
            'value'     => '2',
            'suggestion'=> 'abc'
        };

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/MessagingApi/feedback';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json;charset=UTF-8');
        request.requestBody = Blob.valueOf(JSON.serialize(postData));
        RestContext.request = request;
        RestContext.response = new RestResponse();

        CN_MessagingHelperClass.Post();
        Test.stopTest();
    }
    
    @isTest
    public static void LCC_MessagingSession_SalesOrder_Test() {

        Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeId = newDirectRTId;
        acc.Name = 'TestClass_Account';
        acc.CN_License_Name_EN__c = 'TestClass_Account';
        acc.CN_Store_Name_EN__c = 'TestClass_Account';
        acc.CN_Store_Name_CN__c = 'TestClass_Account';
        acc.CN_Sales_District__c = '001';
        //acc.CN_Customer_Group__c = '01';
        acc.CN_Category__c = 'BAPA';
        acc.CN_Subcategory__c = 'Access Bakery';
        //acc.CN_Province_CN__c = province.Id;
        //acc.CN_City_CN__c = city.Id;
        acc.CN_Post_Code__c = '100000';
        acc.CN_Delivery_Plant__c = 'P011';
        acc.CN_Payment_Terms__c = 'D000';
        acc.CN_Invoicing_Name_Bill_To_Party__c = 'D000';
        acc.CN_Tax_Registration_No__c = '10000000';
        acc.CN_Invoice_Type__c = 'General Invoice';
        acc.CN_Invoicing_Address_EN__c = 'ABCDEF';
        acc.CN_Reference_Day__c = 'Delivery_Day';
        acc.CN_Sync_Status__c  = Constants.CN_ACCOUNT_SYNC_STATUS_SUCCESS;
        acc.CN_Account_Status__c = 'New';
        //acc.CN_Business_Unit_UI__c = businessUnit.Id;
        //acc.CN_Sales_Team_UI__c = salesTeam.Id;
        insert acc;

        CN_Sales_Order__c  order = new CN_Sales_Order__c();
        order.CN_Sold_To_Account_Name__c = acc.Id;
        order.CN_Up_Code__c = '0000' + 1;
        insert order;

        Product2 product = new Product2();
        product.IsActive = true;
        product.Name = 'TestProduct00001';
        product.ProductCode = 'P00001';
        product.CN_SKU_Code__c = 'P00001';
        insert product;

        List<CN_Sales_Order_Item__c> orderItemList = new List<CN_Sales_Order_Item__c>();
        CN_Sales_Order_Item__c orderItem1 = new CN_Sales_Order_Item__c();
        orderItem1.CN_Order_Number__c = order.Id;
        orderItem1.CN_Up_Code__c = '0000' + 1 + '1';
        orderItem1.CN_Material_Number__c = product.Id;
        orderItemList.add(orderItem1);

        CN_Sales_Order_Item__c orderItem2 = new CN_Sales_Order_Item__c();
        orderItem2.CN_Order_Number__c = order.Id;
        orderItem2.CN_Up_Code__c = '0000' + 1 + '2';
        orderItem2.CN_Material_Number__c = product.Id;
        orderItemList.add(orderItem2);
    
        insert orderItemList;
        
        List<CN_Sales_Order_Item__c> testlog = [SELECT CN_Material_Number__c, CN_Order_Quantity__c, CN_Order_Number__r.CN_Sold_To_Account_Name__c FROM CN_Sales_Order_Item__c 
        WHERE CN_Order_Number__r.CN_Sold_To_Account_Name__c = :acc.Id];

        System.debug(testlog);

        Test.startTest();

        CN_MessagingSession_LCC_SalesOrder.getInitData('');

        Test.stopTest();
    }
}