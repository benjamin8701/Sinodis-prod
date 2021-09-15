/**************************************************************************************************
* Name           : CN_Account_Gaode_Geolocation_Batch
* Object         : 
* Requirement    : 
* Target         : 
* Refer classes  :
* Author         : Wan Houchen
* Create Date    : 2021-08-03
* Modify History : 
**************************************************************************************************/
global class CN_Account_Gaode_Geolocation_Batch implements Schedulable,Database.Batchable<SObject>, Database.AllowsCallouts{
    
    global void execute(SchedulableContext sc){
        CN_Account_Gaode_Geolocation_Batch caggb = new CN_Account_Gaode_Geolocation_Batch();
        Database.executeBatch(caggb, 10);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('===start==');
        String query = ' SELECT Id,CN_Visit_Addr_CN__c From Account ';
        query += ' Where CN_Need_Sync_Geolocation__c = true and CN_Visit_Addr_CN__c != null ';
        query += ' Order by Lastmodifieddate Desc ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        system.debug('===execute==');
        CN_Gaode_Setting__c setting = CN_Gaode_Setting__c.getInstance();        
        List<Account> needUpdate = new List<Account>();
        Http http;        
        for(Account a:scope){            
            http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            String endpoint = setting.Geolocation_Endpoint__c;
            endpoint += '?key='+ setting.Web_Key__c+'&address='+a.CN_Visit_Addr_CN__c+'&output=JSON';
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            res = http.send(req);
            if(res.getStatusCode() == 200){               
                Map <String, Object> root = (Map <String, Object>) JSON.deserializeUntyped(res.getBody());
                String status = String.valueof(root.get('info'));
                Integer count = Integer.valueof(root.get('count'));
                system.debug('status==>'+status);
                system.debug('count==>'+count);
                Account acc = new Account();
                acc.Id = a.Id;
                acc.CN_Need_Sync_Geolocation__c = false;
                acc.CN_Gaode_Response_Status__c = status;
                if('OK'.equalsIgnoreCase(status) && count>0){
                    List <Object> geocodes = (List<Object>) root.get('geocodes');                                
                    Map <String, Object> geocode = (Map <String, Object>) geocodes[0];
                    system.debug('objectMap==>'+geocode.get('location'));
                    List<String> lonlat = String.valueof(geocode.get('location')).split(',');
                    acc.CN_Gaode_Geolocation__Longitude__s = Decimal.valueof(lonlat[0]);
                    acc.CN_Gaode_Geolocation__Latitude__s = Decimal.valueOf(lonlat[1]) ;                    
                } 
                needUpdate.add(acc); 
            }
            /*
            if(res.getStatusCode() == 200){                
                //response contains 'number' which is invalid in sfdc
                String resBody = res.getBody().replace('number','number_Z');
                GaodeResponse gr = (GaodeResponse)json.deserializeStrict(resBody, GaodeResponse.class);
                system.debug('gr==>'+gr.info);
                Account acc = new Account();
                acc.Id = a.Id;
                acc.CN_Need_Sync_Geolocation__c = false;
                acc.CN_Gaode_Response_Status__c = gr.info;
                
                if(gr.info == 'OK' && gr.count != '0'){                    
                	if(gr.geocodes[0].location.contains(',')){
                        List<String> lonlat = gr.geocodes[0].location.split(',');
                        acc.CN_Gaode_Geolocation__Longitude__s = Decimal.valueof(lonlat[0]);
                        acc.CN_Gaode_Geolocation__Latitude__s = Decimal.valueOf(lonlat[1]) ;
                        acc.CN_Gaode_Geolocation_Lon__c = Decimal.valueof(lonlat[0]);
                        acc.CN_Gaode_Geolocation_Lat__c = Decimal.valueOf(lonlat[1]);
                
                		}                                                                    
                	}
                needUpdate.add(acc);                
            	}
            */
            
        }
        system.debug('needUpdate==>'+needUpdate);
        if(needUpdate.size()>0){
            update needUpdate;
        }
        
    }  
    global void finish(Database.BatchableContext BC){
        system.debug('===finish==');
    }
    
    
}