public without sharing class CN_Product_Description_Check_Handler implements Triggers.Handler{
        
    Map<Id,Profile> systemProfiles = new Map<Id,Profile>([Select Id from Profile Where name in ( 'System Integration','System Administrator')]);
    public void handle(){
        
        if(systemProfiles.containskey(userinfo.getProfileId())){
            return;
        }
        
        Map<Id,String> userBrandsMap = new Map<Id,String>();
        for(CN_Brand_Owner_Control__c boc:[Select Id,CN_Brand_Owner__c,CN_Brands__c From CN_Brand_Owner_Control__c Limit 20000]){
            userBrandsMap.put(boc.CN_Brand_Owner__c,boc.CN_Brands__c);
        }        
        system.debug('userBrandsMap==>'+userBrandsMap);

        for(Product2 prd:(List<Product2>)trigger.new){
            Product2 oldPrd = (Product2) trigger.oldMap.get(prd.Id);
            if(prd.CN_SKU_Description_CN__c != oldPrd.CN_SKU_Description_CN__c || prd.CN_SKU_Description_EN__c != oldPrd.CN_SKU_Description_EN__c){
                if(userBrandsMap.containskey(userinfo.getUserId())){
                    if(!userBrandsMap.get(userinfo.getUserId()).contains(prd.CN_Brand__c)){
                        system.debug('here1==>'+prd.CN_Brand__c);
                        prd.addError(system.Label.CN_Product_Desc_Change);
                    }
                }else{
                    system.debug('here2==>'+prd.CN_Brand__c);
                    prd.addError(system.Label.CN_Product_Desc_Change);
                }
            }
        }
        
    }
}