/**************************************************************************************************
 * Name           : TestHttpMock
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-06-07
 * Modify History : 
 **************************************************************************************************/
global class TestHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String url = req.getEndpoint();
        System.debug(url);
        if(url.contains('SO')){
            if(url.contains('200')) {
                if(url.contains('SOE')){
                    res.setBody('{"CN_Up_Code__c": "00001","CN_Overall_Status__c": "A", "CN_Rejection_Status__c": "B","CN_Delivery_Status__c": "C","CN_Credit_Status__c": "","CN_Overall_Blocked_Status__c": "","CN_Sync_Status__c": "E","CN_Sync_Error_Message__c": "AAAAAAA","Sales_Order_Item__r": [ {"CN_Up_Code__c": "000011","CN_DN_Number__c": "1234567891","CN_Overall_Status__c": "A","CN_Delilvery_Status__c": "B"}, {"CN_Up_Code__c": "000012","CN_DN_Number__c": "1234567892","CN_Overall_Status__c": "B","CN_Delilvery_Status__c": "C"}]}');
                }else if(url.contains('SOS')){
                    res.setBody('{"CN_Up_Code__c": "00001","CN_Overall_Status__c": "A", "CN_Rejection_Status__c": "B","CN_Delivery_Status__c": "C","CN_Credit_Status__c": "","CN_Overall_Blocked_Status__c": "","CN_Sync_Status__c": "Sent","CN_Sync_Error_Message__c": "AAAAAAA","Sales_Order_Item__r": [ {"CN_Up_Code__c": "000011","CN_DN_Number__c": "1234567891","CN_Overall_Status__c": "A","CN_Delilvery_Status__c": "B"}, {"CN_Up_Code__c": "000012","CN_DN_Number__c": "1234567892","CN_Overall_Status__c": "B","CN_Delilvery_Status__c": "C"}]}');
                }else{
                    res.setBody('{"CN_Up_Code__c": "00001","CN_Overall_Status__c": "A", "CN_Rejection_Status__c": "B","CN_Delivery_Status__c": "C","CN_Credit_Status__c": "","CN_Overall_Blocked_Status__c": "","CN_Sync_Status__c": "S","CN_Sync_Error_Message__c": "AAAAAAA","Sales_Order_Item__r": [ {"CN_Up_Code__c": "000011","CN_DN_Number__c": "1234567891","CN_Overall_Status__c": "A","CN_Delilvery_Status__c": "B"}, {"CN_Up_Code__c": "000012","CN_DN_Number__c": "1234567892","CN_Overall_Status__c": "B","CN_Delilvery_Status__c": "C"}]}');
                }
                res.setStatusCode(200);
            } else if(url.contains('500')) {
                res.setBody('{"CN_Up_Code__c": "00002","CN_Overall_Status__c": "A", "CN_Rejection_Status__c": "B","CN_Delivery_Status__c": "C","CN_Credit_Status__c": "","CN_Overall_Blocked_Status__c": "","CN_Sync_Status__c": "S","CN_Sync_Error_Message__c": "AAAAAAA","Sales_Order_Item__r": [ {"CN_Up_Code__c": "000021","CN_DN_Number__c": "1234567891","CN_Overall_Status__c": "A","CN_Delilvery_Status__c": "B"}, {"CN_Up_Code__c": "000022","CN_DN_Number__c": "1234567892","CN_Overall_Status__c": "B","CN_Delilvery_Status__c": "C"}]}');
                res.setStatusCode(500);
            } else if(url.contains('400')) {
                res.setBody('{"CN_Up_Code__c": "00003","CN_Overall_Status__c": "A", "CN_Rejection_Status__c": "B","CN_Delivery_Status__c": "C","CN_Credit_Status__c": "","CN_Overall_Blocked_Status__c": "","CN_Sync_Status__c": "S","CN_Sync_Error_Message__c": "AAAAAAA","Sales_Order_Item__r": [ {"CN_Up_Code__c": "000031","CN_DN_Number__c": "1234567891","CN_Overall_Status__c": "A","CN_Delilvery_Status__c": "B"}, {"CN_Up_Code__c": "000032","CN_DN_Number__c": "1234567892","CN_Overall_Status__c": "B","CN_Delilvery_Status__c": "C"}]}');
                res.setStatusCode(400);
            } else if(url.contains('401')) {
                res.setBody('{"CN_Up_Code__c": "00004","CN_Overall_Status__c": "A", "CN_Rejection_Status__c": "B","CN_Delivery_Status__c": "C","CN_Credit_Status__c": "","CN_Overall_Blocked_Status__c": "","CN_Sync_Status__c": "S","CN_Sync_Error_Message__c": "AAAAAAA","Sales_Order_Item__r": [ {"CN_Up_Code__c": "000041","CN_DN_Number__c": "1234567891","CN_Overall_Status__c": "A","CN_Delilvery_Status__c": "B"}, {"CN_Up_Code__c": "000042","CN_DN_Number__c": "1234567892","CN_Overall_Status__c": "B","CN_Delilvery_Status__c": "C"}]}');
                res.setStatusCode(401);
            } else if(url.contains('404')) {
                res.setBody('{"CN_Up_Code__c": "00005","CN_Overall_Status__c": "A", "CN_Rejection_Status__c": "B","CN_Delivery_Status__c": "C","CN_Credit_Status__c": "","CN_Overall_Blocked_Status__c": "","CN_Sync_Status__c": "S","CN_Sync_Error_Message__c": "AAAAAAA","Sales_Order_Item__r": [ {"CN_Up_Code__c": "000051","CN_DN_Number__c": "1234567891","CN_Overall_Status__c": "A","CN_Delilvery_Status__c": "B"}, {"CN_Up_Code__c": "000052","CN_DN_Number__c": "1234567892","CN_Overall_Status__c": "B","CN_Delilvery_Status__c": "C"}]}');
                res.setStatusCode(404);
            }
        }else{
            if(url.contains('200')) {
                res.setBody('');
                res.setStatusCode(200);
            } else if(url.contains('500')) {
                res.setBody('');
                res.setStatusCode(500);
            } else if(url.contains('400')) {
                res.setBody('');
                res.setStatusCode(400);
            } else if(url.contains('401')) {
                res.setBody('');
                res.setStatusCode(401);
            } else if(url.contains('404')) {
                res.setBody('');
                res.setStatusCode(404);
            }
        }
        return res;
    }
}