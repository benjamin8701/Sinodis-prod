public without sharing class CN_Campaign_Generate_Opp_LC_Ctrl {

    @AuraEnabled 
    public static void generateOpp(Opportunity oppObj, Id campId){
        
        List<Campaign> campList = [SELECT Id,Name,
                                          CN_VIP__c,
                                          CN_New_Product_Launch__c,
                                          CN_All_Attended_Members_Number__c,
                                          CN_All_Members_Number__c,
                                          CN_All_SKU_Number__c
                                   FROM Campaign
                                   WHERE Id = :campId];
        if(campList.size() > 0) {
            Campaign campObj = campList[0];
            createOpp(oppObj, campId,campObj.Name);
            /*
            if(campObj.CN_VIP__c) {                
                if((campObj.CN_All_Attended_Members_Number__c + campObj.CN_All_Attended_Members_Number__c * campObj.CN_All_SKU_Number__c) > 10000) {
                    throw new AuraHandledException(System.Label.CN_Campaign_More_10000);
                } else {
                    createOpp(oppObj, campId);
                }
            } else if(campObj.CN_New_Product_Launch__c) {
                if((campObj.CN_All_Members_Number__c + campObj.CN_All_Members_Number__c * campObj.CN_All_SKU_Number__c) > 10000) {
                    throw new AuraHandledException(System.Label.CN_Campaign_More_10000);
                } else {
                    createOpp(oppObj, campId);
                }
            }
			*/
        }     
    }
 
    @AuraEnabled 
    public static Map<String, String> getStageFieldValue() {
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

    public static void createOpp(Opportunity oppObj, String campId,String campName){
        String attendedStatus = Constants.CN_CM_STATUS_ATTENDED;
        String accType = Constants.CN_CM_TYPE_ACCOUNT;
        String conType = Constants.CN_CM_TYPE_CONTACT;
        String leadType = Constants.CN_CM_TYPE_LEAD;
        List<CampaignMember> camMemList = [SELECT AccountId,
                                                  ContactId,
                                                  CampaignId,
                                                  Status,
                                                  CN_Type_Formula__c
                                           FROM CampaignMember
                                           WHERE CampaignId = :campId AND Status = :attendedStatus AND CN_Type_Formula__c != :leadType];
        Set<Id> accIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        if(camMemList.size() > 0) {
            for(CampaignMember camMem : camMemList) {
                if(camMem.CN_Type_Formula__c == accType) {
                    accIds.add(camMem.AccountId);
                } else if(camMem.CN_Type_Formula__c == conType) {
                    conIds.add(camMem.ContactId);
                }
            }
        }
        if(conIds.size() > 0) {
            List<Contact> conList = [SELECT AccountId,
                                            Id
                                     FROM Contact
                                     WHERE Id in :conIds];
            if(conList.size() > 0) {
                for(Contact con : conList) {
                    if(String.isNotBlank(con.AccountId)) {
                        accIds.add(con.AccountId);
                    }
                }
            }
        }

        Map<Id, String> accPBIdMap = new Map<Id, String>();
        List<Opportunity> oppList = new List<Opportunity>();
        if(accIds.size() > 0) {
            accPBIdMap = getPriceBook(accIds);
            Map<Id,Account> accMap = new Map<Id,Account>([Select Id,Name,OwnerId From Account Where Id in :accIds]);
            Map<Id,List<Opportunity>> accOppsMap = new Map<Id,List<Opportunity>>();
            
            for(Opportunity opp : [SELECT AccountId,Account.Name, CN_Campaign__c FROM Opportunity WHERE AccountId in :accIds AND CN_Campaign__c = :campId]){
                if(accOppsMap.containskey(opp.AccountId)){
                    accOppsMap.get(opp.AccountId).add(opp);
                }else{
                    accOppsMap.put(opp.AccountId,new List<Opportunity>{opp});
                }
            }
            for(Id accId : accIds) {
                if(accPBIdMap.containsKey(accId)) {
                    List<Opportunity> oppsearchList = accOppsMap.get(accId);
                    if(accOppsMap.get(accId)==null) {
                        Opportunity oppNewObj = new Opportunity(
                                    AccountId = accId,
                                    Name = campName + accMap.get(accId).Name,
                                    OwnerId = accMap.get(accId).OwnerId,
                                    StageName = 'Qualification',
                                    CloseDate = oppObj.CloseDate!=null ? oppObj.CloseDate : System.Today().addDays(90),
                                    Pricebook2Id = accPBIdMap.get(accId),
                                    CN_Campaign__c = campId
                                    );
                        oppList.add(oppNewObj);
                    }
                }
            }
            try {
                if(oppList.size()>10000){
                    throw new AuraHandledException(System.Label.CN_Campaign_More_10000);
                }else{
                    insert oppList;
                }
                
            } catch(DMLException e) {
                throw new DMLException('Unable to Perform the DML Operation on Opportunity : ' +e.getMessage());
                }           
            if (String.isNotBlank(campId)) {
                createOppProduct(campId, oppList);
            } 
        }
    }

    public static Map<Id, String> getPriceBook(Set<Id> accIds) {
        Map<Id, String> accPBIdMap = new Map<Id, String>();
        CN_Price_Book_Setting__c settings = CN_Price_Book_Setting__c.getInstance();
        List<Account> accList = [SELECT Id,
                                         OwnerId
                                  FROM Account
                                 WHERE Id in :accIds];
        Set<Id> ownerIds = new Set<Id>();
        if(accList.size() > 0) {
            for(Account acc : accList) {
                ownerIds.add(acc.OwnerId);
            }
        }     
        List<User> ownerList = new List<User>();
        if(ownerIds.size() > 0) {
            ownerList = [SELECT Id,
                                CN_Sales_Team__c
                         FROM User
                         WHERE Id = :ownerIds]; 
        }
        Map<Id,String> ownerPBMap = new Map<Id,Id>();
        if(ownerList.size() > 0) {
            for(User ur : ownerList) {
                String salesTeamValue;
                    salesTeamValue = ur.CN_Sales_Team__c;
                    String pricebookId;
                    if(salesTeamValue == Constants.CN_SALES_TEAM1) {
                        pricebookId = settings.CN_Price_Book1__c;
                    } else if(salesTeamValue == Constants.CN_SALES_TEAM2) {
                        pricebookId = settings.CN_Price_Book2__c;
                    } else if(salesTeamValue == Constants.CN_SALES_TEAM3) {
                        pricebookId = settings.CN_Price_Book3__c;
                    } else {
                        pricebookId = settings.CN_Price_Book1__c;
                    }
                    ownerPBMap.put(ur.Id, pricebookId);
            }
        }
        for(Account acc : accList) {
            accPBIdMap.put(acc.Id, ownerPBMap.get(acc.OwnerId));
        }
        return accPBIdMap;    
    }

    public static void createOppProduct(Id campId, List<Opportunity> oppList) {       
        List<CN_Campaign_Product__c> camProList = [SELECT CN_Product__c,
                                                          CN_Campaign__c
                                                   FROM CN_Campaign_Product__c
                                                   WHERE CN_Campaign__c = :campId];
        if(camProList.size() > 0) {
            List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
            for(CN_Campaign_Product__c camProObj : camProList) {
                for(Opportunity oppObj :oppList) {
                    OpportunityLineItem oppLineItem = new OpportunityLineItem(
                    OpportunityId = oppObj.Id,
                    Product2Id = camProObj.CN_Product__c
                );
                oppLineItemList.add(oppLineItem);
                }
            }
            if(oppLineItemList.size()>(limits.getLimitDmlRows()-limits.getDmlRows())){
				throw new AuraHandledException(System.Label.CN_Campaign_More_10000);
            }
            try {
                Database.SaveResult[] results = Database.insert(oppLineItemList, false);
                for(Database.SaveResult result : results) {
                    if(!result.isSuccess()) {
                        for(Database.Error error : result.getErrors()) {
                            List<String> errorList = new List<String>();
                            errorList.add(error.getStatusCode().name());
                            errorList.add(error.getFields().toString());
                            System.debug( String.format(System.label.CN_Campaign_Insert_Failed,errorList));
                        }
                    }
                }
            } catch(DMLException e) {
                String exceptionMessage =  e.getMessage();
                throw new DMLException( String.format(System.label.CN_Campaign_DMLException ,new List<String>{exceptionMessage}) );
            }
        }
    }
}