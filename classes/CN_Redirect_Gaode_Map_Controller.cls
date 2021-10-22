public without sharing class CN_Redirect_Gaode_Map_Controller {
	
    @AuraEnabled
    public static List<Decimal> getAccountGeolocationInfo(String recordId){
        Account acc = [Select Id,Name,CN_Gaode_Geolocation__Longitude__s,CN_Gaode_Geolocation__Latitude__s from Account Where Id = :recordId];
        system.debug('acc==>'+acc.Name);
        system.debug('CN_Gaode_Geolocation__Longitude__s==>'+acc.CN_Gaode_Geolocation__Longitude__s);
        system.debug('CN_Gaode_Geolocation__Latitude__s==>'+acc.CN_Gaode_Geolocation__Latitude__s);
        if(acc.CN_Gaode_Geolocation__Longitude__s == null || acc.CN_Gaode_Geolocation__Latitude__s == null){
            throw new AuraHandledException('还未更新地理信息，请联系管理员');
        }
        return new List<Decimal>{acc.CN_Gaode_Geolocation__Longitude__s,acc.CN_Gaode_Geolocation__Latitude__s};
    }
}