/**************************************************************************************************
 * Name           : CN_OrderTreeUpsert_WS_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_OrderTreeUpsert_WS_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }
    @isTest
    private static void postTest() {
        TestDataFactory testDataFactory = new TestDataFactory();
        Account acc = testDataFactory.makeAccounts(1,false)[0];
        acc.CN_Customer_Code__c = 'ACC00001';
        update acc;
        CN_Ship_to_Party__c stp = [SELECT Id, CN_UP_Code__c FROM CN_Ship_to_Party__c WHERE CN_Sold_To_Party_Customer__c =: acc.Id][0];
        stp.CN_UP_Code__c  = 'STP00001';
        update stp;
        System.debug(stp.CN_UP_Code__c);
        System.debug(acc.CN_Customer_Code__c);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestURI = '/services/apexrest/OrderTreeUpsert/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"attributes":{"type":"CN_Sales_Order__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"ABCD","CN_SAP_Create_By__c":"99999","CN_SAP_Create_Date__c":"2021-05-11","CN_Sales_Order_Type__c.CN_Sales_Order_Type_External_ID__c":"OR1","CN_Sold_To_Account_Name__c.CN_Customer_Code__c":"' + acc.CN_Customer_Code__c + '","CN_Delivery_Account_Name__c.CN_UP_Code__c":"' + stp.CN_UP_Code__c + '","CN_AR_Person__c.CN_Personnel_Number__c":"Test0002","CN_Sales_Person_Name__c.CN_Personnel_Number__c":"Test0001","CN_PO_Number__c":"123456","CN_Requested_Delivery_Date__c":"2021-05-11","CN_Delivery_Block__c":"01","CN_Billing_Block__c":"01","CN_Payment_Terms__c":"D090","CN_Incoterms1__c":"CIP","CN_Incoterms2__c":"12343","CN_Order_Reason__c.CN_Order_Reason_External_ID__c":"010","CN_Sales_Organization__c":"S010-Sinodis Sales Org","CN_Distribution_Channel__c":"WS","CN_Division__c":"01","CN_Overall_Status__c":"Not Relevant","CN_Rejection_Status__c":"Not Relevant","CN_Delivery_Status__c":"Not Relevant","CN_Credit_Status__c":"A","CN_Overall_Blocked_Status__c":"Not Relevant","CN_Order_Net_Value__c":123456,"CN_Tax_Amount__c":123456,"CN_Currency__c":"CNY","CN_Order_Reference_No__c":"1234567","Sales_Order_Note__r":{"records":[{"attributes":{"type":"CN_Sales_Order_Note__c","externalField":"CN_Up_Code__c"},"CN_Note_Type__c":"","CN_Note__c":"Evans","CN_Up_Code__c":"001"},{"attributes":{"type":"CN_Sales_Order_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"002","CN_Note__c":"Evans"},{"attributes":{"type":"CN_Sales_Order_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"003","CN_Note__c":"Smith"},{"attributes":{"type":"CN_Sales_Order_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"004","CN_Note__c":"Evans"}]},"Sales_Order_Item__r":{"records":[{"attributes":{"type":"CN_Sales_Order_Item__c","externalField":"CN_Up_Code__c"},"CN_Material_Number__c.CN_SKU_Code__c":"P00001","CN_Up_Code__c":"09876543232","CN_Order_Quantity__c":1,"CN_Sales_Unit__c":"123","CN_Plant__c":"P096","CN_Item_Reject_Reason__c":"","CN_Discount_Rate__c":0.5,"CN_List_Price__c":500,"CN_Confirmed_Value__c":500,"CN_Uploading_Point__c":"500","CN_Net_Weight__c":500,"CN_Gross_Weight__c":600,"CN_Weight_Unit__c":"ABC","CN_Net_Value__c":500,"CN_Tax_Amount__c":500,"CN_Currency__c":"CNY","CN_DN_Number__c":"012345","CN_Overall_Status__c":"Not Relevant","CN_Delilvery_Status__c":"Not Relevant","Sales_Order_Item_Note__r":{"records":[{"attributes":{"type":"CN_Sales_Order_Item_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"002345","CN_Item_Note__c":"Smith"},{"attributes":{"type":"CN_Sales_Order_Item_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"002346","CN_Item_Note__c":"Smith"}]},"Schedule_Line__r":{"records":[{"attributes":{"type":"CN_Schedule_Line__c","externalField":"CN_SAP_Schedule_Line_Number__c"},"CN_SAP_Schedule_Line_Number__c":"5433","CN_Delivery_Date__c":"2021-05-11"},{"attributes":{"type":"CN_Schedule_Line__c","externalField":"CN_SAP_Schedule_Line_Number__c"},"CN_SAP_Schedule_Line_Number__c":"677898","CN_Delivery_Date__c":"2021-05-11"}]}},{"attributes":{"type":"CN_Sales_Order_Item__c","externalField":"CN_Up_Code__c"},"CN_Material_Number__c.CN_SKU_Code__c":"P00001","CN_Up_Code__c":"43564356","CN_Order_Quantity__c":1,"CN_Sales_Unit__c":"123","CN_Plant__c":"P096","CN_Item_Reject_Reason__c":"","CN_Discount_Rate__c":0.5,"CN_List_Price__c":500,"CN_Confirmed_Value__c":500,"CN_Uploading_Point__c":"500","CN_Net_Weight__c":500,"CN_Gross_Weight__c":600,"CN_Net_Value__c":500,"CN_Tax_Amount__c":500,"CN_Currency__c":"CNY","CN_DN_Number__c":"012345","CN_Overall_Status__c":"Not Relevant","CN_Delilvery_Status__c":"Not Relevant","Schedule_Line__r":{"records":[{"attributes":{"type":"CN_Schedule_Line__c","externalField":"CN_SAP_Schedule_Line_Number__c"},"CN_SAP_Schedule_Line_Number__c":"5433111","CN_Delivery_Date__c":"2021-05-11"},{"attributes":{"type":"CN_Schedule_Line__c","externalField":"CN_SAP_Schedule_Line_Number__c"},"CN_SAP_Schedule_Line_Number__c":"6778981111","CN_Delivery_Date__c":"2021-05-11"}]}}]}}');
        RestContext.request = request;
        RestContext.response= res;
        CN_OrderTreeUpsert_WS.post();
    }
    @isTest
    private static void postTest_Error() {
        TestDataFactory testDataFactory = new TestDataFactory();
        Account acc = testDataFactory.makeAccounts(1,false)[0];
        acc.CN_Customer_Code__c = 'ACC00001';
        update acc;
        CN_Ship_to_Party__c stp = [SELECT Id, CN_UP_Code__c FROM CN_Ship_to_Party__c WHERE CN_Sold_To_Party_Customer__c =: acc.Id][0];
        stp.CN_UP_Code__c  = 'STP00001';
        update stp;
        System.debug(stp.CN_UP_Code__c);
        System.debug(acc.CN_Customer_Code__c);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestURI = '/services/apexrest/OrderTreeUpsert/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('111{"attributes":{"type":"CN_Sales_Order__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"ABCD","CN_SAP_Create_By__c":"99999","CN_SAP_Create_Date__c":"2021-05-11","CN_Sales_Order_Type__c.CN_Sales_Order_Type_External_ID__c":"OR1","CN_Sold_To_Account_Name__c.CN_Customer_Code__c":"' + acc.CN_Customer_Code__c + '","CN_Delivery_Account_Name__c.CN_UP_Code__c":"","CN_AR_Person__c.CN_Personnel_Number__c":"Test0002","CN_Sales_Person_Name__c.CN_Personnel_Number__c":"Test0001","CN_PO_Number__c":"123456","CN_Requested_Delivery_Date__c":"2021-05-11","CN_Delivery_Block__c":"01","CN_Billing_Block__c":"01","CN_Payment_Terms__c":"D090","CN_Incoterms1__c":"CIP","CN_Incoterms2__c":"12343","CN_Order_Reason__c.CN_Order_Reason_External_ID__c":"010","CN_Sales_Organization__c":"S010-Sinodis Sales Org","CN_Distribution_Channel__c":"WS","CN_Division__c":"01","CN_Overall_Status__c":"Not Relevant","CN_Rejection_Status__c":"Not Relevant","CN_Delivery_Status__c":"Not Relevant","CN_Credit_Status__c":"A","CN_Overall_Blocked_Status__c":"Not Relevant","CN_Order_Net_Value__c":123456,"CN_Tax_Amount__c":123456,"CN_Currency__c":"CNY","CN_Order_Reference_No__c":"1234567","Sales_Order_Note__r":{"records":[{"attributes":{"type":"CN_Sales_Order_Note__c","externalField":"CN_Up_Code__c"},"CN_Note_Type__c":"","CN_Note__c":"Evans","CN_Up_Code__c":"001"},{"attributes":{"type":"CN_Sales_Order_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"002","CN_Note__c":"Evans"},{"attributes":{"type":"CN_Sales_Order_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"003","CN_Note__c":"Smith"},{"attributes":{"type":"CN_Sales_Order_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"004","CN_Note__c":"Evans"}]},"Sales_Order_Item__r":{"records":[{"attributes":{"type":"CN_Sales_Order_Item__c","externalField":"CN_Up_Code__c"},"CN_Material_Number__c.CN_SKU_Code__c":"P00001","CN_Up_Code__c":"09876543232","CN_Order_Quantity__c":1,"CN_Sales_Unit__c":"123","CN_Plant__c":"P096","CN_Item_Reject_Reason__c":"","CN_Discount_Rate__c":0.5,"CN_List_Price__c":500,"CN_Confirmed_Value__c":500,"CN_Uploading_Point__c":"500","CN_Net_Weight__c":500,"CN_Gross_Weight__c":600,"CN_Weight_Unit__c":"ABC","CN_Net_Value__c":500,"CN_Tax_Amount__c":500,"CN_Currency__c":"CNY","CN_DN_Number__c":"012345","CN_Overall_Status__c":"Not Relevant","CN_Delilvery_Status__c":"Not Relevant","Sales_Order_Item_Note__r":{"records":[{"attributes":{"type":"CN_Sales_Order_Item_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"002345","CN_Item_Note__c":"Smith"},{"attributes":{"type":"CN_Sales_Order_Item_Note__c","externalField":"CN_Up_Code__c"},"CN_Up_Code__c":"002346","CN_Item_Note__c":"Smith"}]},"Schedule_Line__r":{"records":[{"attributes":{"type":"CN_Schedule_Line__c","externalField":"CN_SAP_Schedule_Line_Number__c"},"CN_SAP_Schedule_Line_Number__c":"5433","CN_Delivery_Date__c":"2021-05-11"},{"attributes":{"type":"CN_Schedule_Line__c","externalField":"CN_SAP_Schedule_Line_Number__c"},"CN_SAP_Schedule_Line_Number__c":"677898","CN_Delivery_Date__c":"2021-05-11"}]}},{"attributes":{"type":"CN_Sales_Order_Item__c","externalField":"CN_Up_Code__c"},"CN_Material_Number__c.CN_SKU_Code__c":"P00001","CN_Up_Code__c":"43564356","CN_Order_Quantity__c":1,"CN_Sales_Unit__c":"123","CN_Plant__c":"P096","CN_Item_Reject_Reason__c":"","CN_Discount_Rate__c":0.5,"CN_List_Price__c":500,"CN_Confirmed_Value__c":500,"CN_Uploading_Point__c":"500","CN_Net_Weight__c":500,"CN_Gross_Weight__c":600,"CN_Net_Value__c":500,"CN_Tax_Amount__c":500,"CN_Currency__c":"CNY","CN_DN_Number__c":"012345","CN_Overall_Status__c":"Not Relevant","CN_Delilvery_Status__c":"Not Relevant","Schedule_Line__r":{"records":[{"attributes":{"type":"CN_Schedule_Line__c","externalField":"CN_SAP_Schedule_Line_Number__c"},"CN_SAP_Schedule_Line_Number__c":"5433111","CN_Delivery_Date__c":"2021-05-11"},{"attributes":{"type":"CN_Schedule_Line__c","externalField":"CN_SAP_Schedule_Line_Number__c"},"CN_SAP_Schedule_Line_Number__c":"6778981111","CN_Delivery_Date__c":"2021-05-11"}]}}]}}');
        RestContext.request = request;
        RestContext.response= res;
        CN_OrderTreeUpsert_WS.post();
    }
}