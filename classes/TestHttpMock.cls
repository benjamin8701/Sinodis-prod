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
        if(url.contains('gaode')){
            res.setBody('{"status":"1","info":"OK","infocode":"10000","count":"1","geocodes":[{"formatted_address":"辽宁省大连市沙河口区星巴克咖啡","country":"中国","province":"辽宁省","citycode":"0411","city":"大连市","district":"沙河口区","township":[],"neighborhood":{"name":[],"type":[]},"building":{"name":[],"type":[]},"adcode":"210204","street":[],"number":[],"location":"121.544772,38.884784","level":"兴趣点"}]}');
            res.setStatusCode(200);
        } else if(url.contains('SO')){
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
        }else if(url.contains('CH')){
            if(url.contains('200')) {
                if(url.contains('CHE')){
                    res.setBody('{"CN_Up_Code__c" : "00001","CN_Sync_Time__c" : "2021-04-20T00:00:00.000Z", "CN_Sync_Status__c" : "E","CN_Sync_Error_Message__c" : ""}');
                }else if(url.contains('CHS')){
                    res.setBody('{"CN_Up_Code__c" : "00001","CN_Sync_Time__c" : "2021-04-20T00:00:00.000Z", "CN_Sync_Status__c" : "S","CN_Sync_Error_Message__c" : ""}');
                }else{
                    res.setBody('{"CN_Up_Code__c" : "00001","CN_Sync_Time__c" : "2021-04-20T00:00:00.000Z", "CN_Sync_Status__c" : "Sent","CN_Sync_Error_Message__c" : ""}');
                }
                res.setStatusCode(200);
            } else if(url.contains('500')) {
                res.setBody('{"CN_Up_Code__c" : "00001","CN_Sync_Time__c" : "2021-04-20T00:00:00.000Z","CN_Sync_Error_Message__c" : ""}');
                res.setStatusCode(500);
            } else if(url.contains('400')) {
                res.setBody('{"CN_Up_Code__c" : "00001","CN_Sync_Time__c" : "2021-04-20T00:00:00.000Z","CN_Sync_Error_Message__c" : ""}');
                res.setStatusCode(400);
            } else if(url.contains('401')) {
                res.setBody('{"CN_Up_Code__c" : "00001","CN_Sync_Time__c" : "2021-04-20T00:00:00.000Z","CN_Sync_Error_Message__c" : ""}');
                res.setStatusCode(401);
            } else if(url.contains('404')) {
                res.setBody('{"CN_Up_Code__c" : "00001","CN_Sync_Time__c" : "2021-04-20T00:00:00.000Z","CN_Sync_Error_Message__c" : ""}');
                res.setStatusCode(404);
            }
        } else if(url.contains('Quote')){
            if(url.contains('200')) {
                String parameters = url.split('\\?')[1];
                String SKUCode = parameters.split('&')[0].split('=')[1];
                String flag = parameters.split('&')[1].split('=')[1];
                res.setBody('{"results":[{"CN_Material_Number_API__c":"' + SKUCode + '","CN_Sync_Status__c":"' + flag + '","CN_Sync_Time__c":"2021-10-28T09:24:12.000Z","CN_Sync_Error_Message__c":""}]}');
                res.setStatusCode(200);
            }
        }else if(url.contains('MG')){
            //AC-009
            if (url.contains('updateShippingAddress')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());
                if (body.get('ship_to_address_id') != null){
                    if(body.get('ship_to_address_id') == '503'){
                        res.setStatusCode(503);
                    }else if(body.get('ship_to_address_id') == '500'){
                        res.setStatusCode(500);
                    }else if(body.get('ship_to_address_id') == '404'){
                        res.setStatusCode(404);
                    }else if(body.get('ship_to_address_id') == 'Err'){
                        res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":{"address_id":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}}]}');
                        res.setStatusCode(200);
                    }else{
                        res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":{"address_id":"' + body.get('ship_to_address_id') + '"}}]}');
                        res.setStatusCode(200);
                    }
                }else{
                    res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":{"address_id":"999"}}]}');
                    res.setStatusCode(200);
                }

            }
            //LD-003
            if (url.contains('updateLeadStatus')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());
                System.debug(body);
                System.debug('url===========>'+url);
                if (body.get('uniqueId') != null){
                    if(body.get('uniqueId') == '503'){
                        res.setStatusCode(503);
                    }else if(body.get('uniqueId') == '500'){
                        res.setStatusCode(500);
                    }else if(body.get('uniqueId') == '404'){
                        res.setStatusCode(404);
                    }
                    else if(body.get('uniqueId') == '400'){
                        res.setStatusCode(400);
                    }
                    else {
                        res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":{"uniqueId":"' + body.get('uniqueId') + '"}}]}');
                        res.setStatusCode(200);
                    }
                }else{
                    if(url.contains('200')){
                        res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":{"uniqueId":"' + body.get('uniqueId') + '"}}]}');
                        res.setStatusCode(200);
                    }
                    else if(url.contains('500')){
                        res.setBody('{"code":500,"message":[{"code":1,"msg":"OK","retData":{"uniqueId":"' + body.get('uniqueId') + '"}}]}');
                        res.setStatusCode(500);
                    }
                    else{
                        res.setBody('{"code":400,"message":[{"code":1,"msg":"OK","retData":{"uniqueId":""}}]}');
                        res.setStatusCode(400);
                    }
                }
            }

            //CT-014
            if (url.contains('SaveCompanyContact')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());
                if (body.get('contact_id') != null){
                    if(body.get('contact_id') == '503'){
                        res.setStatusCode(503);
                    }else if(body.get('contact_id') == '500'){
                        res.setStatusCode(500);
                    }else if(body.get('contact_id') == '404'){
                        res.setStatusCode(404);
                    }else{
                        res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":{"contact_id":"' + body.get('contact_id') + '","mg_billing_id":"1"}}]}');
                        res.setStatusCode(200);
                    }
                }else{
                    res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":{"contact_id":"1","mg_billing_id":"1"}}]}');
                    res.setStatusCode(200);
                }
            }

            //AC-017
            if (url.contains('SaveCustomerCode')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());
                System.debug(JSON.serialize(body));
                if(body.get('mg_account_id') == '503'){
                    res.setStatusCode(503);
                }else if(body.get('mg_account_id') == '500'){
                    res.setStatusCode(500);
                }else if(body.get('mg_account_id') == '404'){
                    res.setStatusCode(404);
                }else{
                    res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":[]}]}');
                    res.setStatusCode(200);
                }
            }

            //AC-018
            if (url.contains('updateCompanyStatus')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());
                if(body.get('account_id') == '503'){
                    res.setStatusCode(503);
                }else if(body.get('account_id') == '500'){
                    res.setStatusCode(500);
                }else if(body.get('account_id') == '404'){
                    res.setStatusCode(404);
                }else{
                    res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":[]}]}');
                    res.setStatusCode(200);
                }
            }

            //AC-010
            if (url.contains('approvallead')) {
                Map<String,Object> bodyData = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());
                Map<String,Object> body = (Map<String,Object>)bodyData.get('data');
                System.debug(JSON.serialize(body));
                System.debug(String.valueOf(body.get('union_id')));
                if(String.valueOf(body.get('union_id')) == '503'){
                    res.setStatusCode(503);
                }else if(String.valueOf(body.get('union_id')) == '500'){
                    res.setStatusCode(500);
                }else if(String.valueOf(body.get('union_id')) == '404'){
                    res.setStatusCode(404);
                }else{
                    res.setBody('{"code":200,"message":[{"code":1,"msg":"OK","retData":[]}]}');
                    res.setStatusCode(200);
                }
                System.debug('TestHttpMock' + res.getStatusCode());
            }
            //AR-002
            if (url.contains('sendWeChatMessage')) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.getBody());
                //Map<String,Object> body = (Map<String,Object>)bodyData.get('data');
                system.debug('body======>'+body);
                System.debug(JSON.serialize(body));
                System.debug(String.valueOf(body.get('area')));
                if (body.get('area') == '200'){
                    if(body.get('warehouse') == '200'){
                        res.setStatusCode(200);
                        res.setBody('{"code":0,"message":[{"code":0,"msg":"Success","retData":{}}]}');
                    }else if(body.get('warehouse') == '201'){
                        res.setStatusCode(200);
                        res.setBody('{"code":1,"message":[{"code":1,"msg":"Success","retData":{}}]}');
                    }
                }else{
                    if(body.get('area') == '500'){
                        res.setBody('{"code":500,"message":[{"code":1,"msg":"OK","retData":{}]}');
                        res.setStatusCode(500);
                    }
                    else if(body.get('area') == '404'){
                        res.setBody('{"code":404,"message":[{"code":1,"msg":"OK","retData":{}]}');
                        res.setStatusCode(404);
                    }
                    else if(body.get('area') == '503'){
                        res.setBody('{"code":503,"message":[{"code":1,"msg":"OK","retData":{}]}');
                        res.setStatusCode(503);
                    }
                }
            }

            //File
            if(url.contains('file')){
                Blob body = Blob.toPdf('test');
                res.setBodyAsBlob(body);
                if(url.contains('500')){
                    res.setStatusCode(500);
                }else if(url.contains('404')){
                    res.setStatusCode(404);
                }else if(url.contains('503')){
                    res.setStatusCode(503);
                }else {
                    res.setStatusCode(200);
                }
            }

        } else{
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