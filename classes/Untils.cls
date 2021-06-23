public without sharing class Untils {
    public static Boolean isTriggerEnabled() {
        Trigger_Switcher_Setting__c setting = Trigger_Switcher_Setting__c.getInstance();
        return setting.EnableTrigger__c;
    }
    public static Boolean checkObjectCreatePermission(String ObjectName) {
        Boolean hasCreatePermission = false;
        if(String.isNotBlank(ObjectName)) {
            hasCreatePermission = Schema.getGlobalDescribe().get(ObjectName).getDescribe().isCreateable();
        }
        return hasCreatePermission;   
    }
    // FROM Knowledge Article Number 000331873
    public static Boolean isSandbox(){
        String host = URL.getSalesforceBaseUrl().getHost();
        String server = host.substring(0,host.indexOf('.'));

        if(server.contains('--')) {
            return true;
        }
        if(server == 'tapp0') {
            return true;
        }
        if(server.length()>2) {
            if(server.substring(0,2) == 'cs') {
                try {
                    Integer.valueOf(server.substring(2,server.length()));
                } catch(exception e) {
                    return false;
                }
                return true;
            }
        }
        return false;
    }
    
    static public DateTime calculateBusinessTime(DateTime startDateTime,Integer hours,String businessHoursName){
		BusinessHours bh = [SELECT Id,Name FROM BusinessHours WHERE Name = :businessHoursName];
        return BusinessHours.add(bh.id, startDateTime,hours*3600000);
	}
}