global with sharing class GaodeMapController {
    public String title{
        get{
            return '周边详情';
        }
    }
    public String getKey(){
        CN_Gaode_Setting__c setting = CN_Gaode_Setting__c.getInstance();
        return setting.JS_Key__c;
    }

	@RemoteAction
    global static String getAccount(Decimal lon,Decimal lat) {
        
        List<Account> accountList = [Select Id,Name,
                                     	CN_Gaode_Geolocation__Longitude__s,CN_Gaode_Geolocation__Latitude__s,
                                     	CN_Customer_Journey__c,CN_Account_Layer__c
                                     	From Account 
                                     	Where CN_Customer_Journey__c in ('Prospect','Customer')
                                        //And Createddate = Today
                                        And DISTANCE(CN_Gaode_Geolocation__c, GEOLOCATION(:lat,:lon), 'km') < 5
                                    ];
        system.debug('lon==>'+lon);
        system.debug('lat==>'+lat);
        system.debug('accountList==>'+accountList.size());
        CN_Gaode_Setting__c setting = CN_Gaode_Setting__c.getInstance(); 
        Map<String,String> accTypeMap = new Map<String,String>();
        accTypeMap.put('Layer 100',setting.Layer100_Icon_Name__c);
        accTypeMap.put('Layer 80',setting.Layer80_Icon_Name__c);
        accTypeMap.put('Layer 50',setting.Layer50_Icon_Name__c);
        accTypeMap.put('Layer 20',setting.Layer20_Icon_Name__c);
        accTypeMap.put('Prospect',setting.Prospect_Icon_Name__c);
		accTypeMap.put('Undefined',setting.Undefined_Icon_Name__c);        
		system.debug('accTypeMap==>'+accTypeMap);
        List<accinfo> accinfoList = new List<accinfo>();
        for(Account a:accountList){
            String iconUrl = '';
            String tire = '';
            if(a.CN_Customer_Journey__c == 'Prospect'){
                iconUrl = '/resource/GaodeMap_Icon/'+accTypeMap.get(a.CN_Customer_Journey__c);
                tire = 'P';
            }else if(String.isBlank(a.CN_Account_Layer__c)){
                iconUrl = '/resource/GaodeMap_Icon/'+accTypeMap.get('Undefined');
                tire = 'U';
            }else{
                iconUrl = '/resource/GaodeMap_Icon/'+accTypeMap.get(a.CN_Account_Layer__c);
                tire = a.CN_Account_Layer__c;
            }

            String url = getLexOriginUrl()+'/'+a.Id;            
            //String url = URL.getSalesforceBaseURL().toExternalForm()+'/'+a.Id;
            system.debug('url==>'+url);
            accinfoList.add(new accinfo(a.Name,a.CN_Gaode_Geolocation__Latitude__s,a.CN_Gaode_Geolocation__Longitude__s,url,iconUrl,tire));
        }
        system.debug('accinfoList==>'+accinfoList);
        return JSON.serialize(accinfoList);
        
        
    }
    public class accinfo{
        public String name{get;set;}
        public Decimal lat{get;set;}
        public Decimal lon{get;set;}
        public String url{get;set;}
        public String iconUrl{get;set;}
        public String tire{get;set;}
        public accinfo(String name,Decimal lat,Decimal lon,String url,String iconUrl,String tire){
            this.name = name;
            this.lat = lat;
            this.lon = lon;
			this.url = url;
            this.iconUrl = iconUrl;
            this.tire = tire;          
        }
    }
    public static String getLexOriginUrl() {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';
    }
}