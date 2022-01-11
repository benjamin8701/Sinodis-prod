/**************************************************************************************************
 * Name           : CN_Chef_UT_Report_Batch
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Kealsalas Qiu
 * Create Date    : 2022-01-05
 * Modify History : 
 **************************************************************************************************/
global class CN_Chef_UT_Report_Batch implements Database.Batchable<SObject>,Database.Stateful{
    String runningYearMonth = '';
    String queryString = '';
    Map<String, Decimal> chefIdOFFDaysMap = new Map<String, Decimal>();

    public CN_Chef_UT_Report_Batch() {
        Date today = Date.today();
        this.runningYearMonth = String.valueOf(today.year()) + String.valueOf(today.month()).leftPad(2, '0');
        this.queryString = 'SELECT Id, RecordType.DeveloperName, CN_Is_OFF__c, CN_Event_Type__c, CN_Is_Work_Date_within_Same_Month__c, CN_Start_Date_Year_Month__c, CN_End_Date_Year_Month__c, CN_Chef__c, CN_Start_Date_to_Month_End_Days__c, CN_End_Date_to_Month_Start_Days__c, CN_Chef_Working_Days__c, CN_Chef_Work_Start_Date__c, CN_Chef_Work_End_Date__c FROM CN_Chefs_Assigned__c WHERE Createddate = TODAY OR LastmodifiedDate = TODAY OR CN_Start_Date_Year_Month__c =: runningYearMonth OR CN_End_Date_Year_Month__c =: runningYearMonth';
    }

    public CN_Chef_UT_Report_Batch(String runningYearMonth) {
        this.runningYearMonth = runningYearMonth;
        this.queryString = 'SELECT Id, RecordType.DeveloperName, CN_Is_OFF__c, CN_Event_Type__c, CN_Is_Work_Date_within_Same_Month__c, CN_Start_Date_Year_Month__c, CN_End_Date_Year_Month__c, CN_Chef__c, CN_Start_Date_to_Month_End_Days__c, CN_End_Date_to_Month_Start_Days__c, CN_Chef_Working_Days__c, CN_Chef_Work_Start_Date__c, CN_Chef_Work_End_Date__c FROM CN_Chefs_Assigned__c WHERE CN_Start_Date_Year_Month__c =: runningYearMonth OR CN_End_Date_Year_Month__c =: runningYearMonth';
    }
    public CN_Chef_UT_Report_Batch(String runningYearMonth, String queryString) {
        this.runningYearMonth = runningYearMonth;
        this.queryString = queryString;
    }
    global Database.QueryLocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator(queryString);
	}
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        CN_Chefs_Assigned_Chef_UT_Item_Biz biz = new CN_Chefs_Assigned_Chef_UT_Item_Biz();
        List<Id> caIdList = new List<Id>();
        Map<Id, CN_Chefs_Assigned__c> caMap = new Map<Id,CN_Chefs_Assigned__c>();
        for(CN_Chefs_Assigned__c ca: (List<CN_Chefs_Assigned__c>)scope) {
            caMap.put(ca.Id, ca);
            if(ca.CN_IS_OFF__c) {
                Decimal workingDays = 0;
                if(ca.CN_Is_Work_Date_within_Same_Month__c) {
                    workingDays = ca.CN_Chef_Working_Days__c;
                } else {
                    if(ca.CN_Start_Date_Year_Month__c == this.runningYearMonth) {
                        workingDays = ca.CN_Start_Date_to_Month_End_Days__c;
                    } else {
                        workingDays = ca.CN_End_Date_to_Month_Start_Days__c;
                    }
                }
                if(chefIdOFFDaysMap.containsKey(ca.CN_Chef__c)) {
                    chefIdOFFDaysMap.put(ca.CN_Chef__c, chefIdOFFDaysMap.get(ca.CN_Chef__c) + workingDays);
                } else {
                    chefIdOFFDaysMap.put(ca.CN_Chef__c, workingDays);
                }
            } else {
                caIdList.add(ca.Id);
            }
        }

        List<Id> cuiDeleteList = new List<Id>();
        List<Id> caIdListForGenerateCui = new List<Id>();
        if(caIdList.size() > 0) {
            List<CN_Chef_UT_Item__c> cuiList = [SELECT Id, CN_Chefs_Assigned__c, CN_Year_Month__c, CN_External_ID__c, CN_Chef_UT_OFF__c FROM CN_Chef_UT_Item__c WHERE CN_Chefs_Assigned__c =: caIdList];
            Map<String, List<CN_Chef_UT_Item__c>> caIdCuiListMap = new Map<String, List<CN_Chef_UT_Item__c>>();
            for(CN_Chef_UT_Item__c cui: cuiList) {
                if(caIdCuiListMap.containsKey(cui.CN_Chefs_Assigned__c)) {
                    caIdCuiListMap.get(cui.CN_Chefs_Assigned__c).add(cui);
                } else {
                    caIdCuiListMap.put(cui.CN_Chefs_Assigned__c, new List<CN_Chef_UT_Item__c>{cui});
                }
            }
            for(Id caId: caidList) {
                CN_Chefs_Assigned__c ca = caMap.get(caId);
                if(caIdCuiListMap.containsKey(caId)) {
                    if(ca.CN_Is_Work_Date_within_Same_Month__c) {
                        Boolean isFound = false;
                        for(CN_Chef_UT_Item__c cui: caIdCuiListMap.get(caId)) {
                            if(!isFound && (cui.CN_Year_Month__c == ca.CN_Start_Date_Year_Month__c || cui.CN_Year_Month__c == ca.CN_End_Date_Year_Month__c)) {
                                isFound = true;
                            } else {
                                cuiDeleteList.add(cui.Id);
                            }
                        }
                        if(!isFound) {
                            caIdListForGenerateCui.add(ca.Id);
                        }
                    } else {
                        Boolean isFoundStartMonth = false;
                        Boolean isFoundEndMonth = false;
                        for(CN_Chef_UT_Item__c cui: caIdCuiListMap.get(caId)) {
                            if(!isFoundStartMonth && cui.CN_Year_Month__c == ca.CN_Start_Date_Year_Month__c) {
                                isFoundStartMonth = true;
                            } else if(!isFoundEndMonth && cui.CN_Year_Month__c == ca.CN_End_Date_Year_Month__c) {
                                isFoundEndMonth = true;
                            } else {
                                cuiDeleteList.add(cui.Id);
                            }
                        }
                        if(!isFoundStartMonth || !isFoundEndMonth) {
                            caIdListForGenerateCui.add(ca.Id);
                        }
                    }
                } else {
                    caIdListForGenerateCui.add(ca.Id);
                }
            }
        }

        if(cuiDeleteList.size() > 0) {
            Database.delete(cuiDeleteList, false);
        }
        if(caIdListForGenerateCui.size() > 0) {
            List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();
            for(Id caId: caIdListForGenerateCui) {
                caList.add(caMap.get(caId));
            }
            List<CN_Chef_UT_Item__c> cuiList = biz.generateChefUTItems(caList);
            upsert cuiList CN_External_Id__c;
        }
    }
	global void finish(Database.BatchableContext BC) {

        List<CN_Chef_UT__c> chefUTList = [SELECT Id, CN_Year_Month__c FROM CN_Chef_UT__c WHERE CN_Year_Month__c =: runningYearMonth];
        Id chefUTId = null;
        if(chefUTList.size() == 0) {
            String chefUTRTID = Schema.SObjectType.CN_Chef_UT__c.getRecordTypeInfosByDeveloperName().get('CN_Chef_UT').getRecordTypeId();
            String year = runningYearMonth.left(4);
            String month = runningYearMonth.right(2);
            CN_Chef_UT__c chefUT = new CN_Chef_UT__c();
            chefUT.RecordTypeId = chefUTRTID;
            chefUT.CN_Year__c = year;
            chefUT.CN_Month__c = month.replace('0', '');
            chefUT.CN_Description__c = '';
            chefUT.CN_Working_Days__c = 0;
            insert chefUT;
            chefUTId = chefUT.Id;
        } else {
            chefUTId = chefUTList[0].Id;
        }


        List<User> chefList = [SELECT Id FROM User WHERE isActive = TRUE AND (Profile.Name = 'CN Chef' OR Profile.Name = 'CN Chef Manager')];
        List<CN_Chef_UT_OFF__c> chefUTOFFExsitingList = [SELECT Id, CN_Chef__c, CN_Chef_UT__c, CN_External_Id__c, CN_Total_OFF_Days__c, CN_Year__c, CN_Month__c FROM CN_Chef_UT_OFF__c WHERE CN_YearMonth__c =: this.runningYearMonth];
        Map<String, Decimal> extnernalIdOFFDaysMap = new Map<String, Decimal>();
        for(CN_Chef_UT_OFF__c cuo: chefUTOFFExsitingList) {
            String externalId = cuo.CN_Year__c + '-' + cuo.CN_Month__c.leftPad(2, '0') + '-' + cuo.CN_Chef__c;
            if(String.isNotBlank(cuo.CN_External_Id__c) && cuo.CN_Chef_UT__c != null) {
                extnernalIdOFFDaysMap.put(externalId, cuo.CN_Total_OFF_Days__c);
            }
        }


        List<CN_Chef_UT_OFF__c> chefUTOFFList = new List<CN_Chef_UT_OFF__c>();
        for(User chef: chefList) {
            String year = runningYearMonth.left(4);
            String month = runningYearMonth.right(2);
            String chefId = chef.Id;
            String yearMonthChefId = year + '-' + month + '-' + chefId;
            if(extnernalIdOFFDaysMap.containsKey(yearMonthChefId)) {
                if(chefIdOFFDaysMap.containsKey(chef.Id)) {
                    if(chefIdOFFDaysMap.get(chef.Id) == extnernalIdOFFDaysMap.get(yearMonthChefId)) {
                        continue;
                    }
                }
            }
            CN_Chef_UT_OFF__c cuo = new CN_Chef_UT_OFF__c();
            cuo.CN_External_Id__c = yearMonthChefId;
            cuo.CN_Chef__c = chefId;
            cuo.CN_Month__c = month;
            cuo.CN_Year__c = year;
            if(chefIdOFFDaysMap.containsKey(chef.Id)) {
                cuo.CN_Total_OFF_Days__c = chefIdOFFDaysMap.get(chefId);
            } else {
                cuo.CN_Total_OFF_Days__c = 0;
            }
            cuo.CN_Chef_UT__c = chefUTId;
            cuo.OwnerId = chefId;
            chefUTOFFList.add(cuo);
        }
        if(chefUTOFFList.size() > 0) {
            upsert chefUTOFFList CN_External_Id__c;
        }
	}
}