/**************************************************************************************************
 * Name           : CN_Chefs_Assigned_Chef_UT_Item_Biz
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-12-28
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chefs_Assigned_Chef_UT_Item_Biz {
    public void cleanChefUTItems(List<CN_Chefs_Assigned__c> caList) {
        Set<Id> caIdSet = new Set<Id>();
        for(CN_Chefs_Assigned__c ca: caList) {
            caIdSet.add(ca.Id);
        }
        List<CN_Chef_UT_Item__c> cuiList = [SELECT Id FROM CN_Chef_UT_Item__c WHERE CN_Chefs_Assigned__c =: caIdSet];
        delete cuiList;
    }

    public List<CN_Chef_UT_Item__c> generateChefUTItems(List<CN_Chefs_Assigned__c> caList, Map<String, String> yearMonthChefUTOFFIdMap) {
        List<CN_Chef_UT_Item__c> cuiList = new List<CN_Chef_UT_Item__c>();
        Id cuiRTID = Schema.SObjectType.CN_Chef_UT_Item__c.getRecordTypeInfosByDeveloperName().get('CN_Chef_UT_Item').getRecordTypeId();
        for(CN_Chefs_Assigned__c ca: caList) {
            String startDateYearMonth = String.valueOf(ca.CN_Chef_Work_Start_Date__c.year()) + String.valueOf(ca.CN_Chef_Work_Start_Date__c.month()).leftPad(2, '0');
            String endDateYearMonth = String.valueOf(ca.CN_Chef_Work_End_Date__c.year()) + String.valueOf(ca.CN_Chef_Work_End_Date__c.month()).leftPad(2, '0');
            if(ca.CN_Is_Work_Date_within_Same_Month__c) {
                CN_Chef_UT_Item__c cui = new CN_Chef_UT_Item__c();
                cui.RecordTypeId = cuiRTID;
                cui.CN_Chefs_Assigned__c = ca.Id;
                cui.CN_Year_Month__c = startDateYearMonth;
                cui.CN_External_Id__c = ca.Id + '-' + startDateYearMonth;
                cui.CN_Chef_UT_OFF__c = yearMonthChefUTOFFIdMap.get(startDateYearMonth.left(4) + '-' + startDateYearMonth.right(2) + '-' + ca.CN_Chef__c);
                cui.OwnerId = ca.CN_Chef__c;
                cuiList.add(cui);
            } else {
                CN_Chef_UT_Item__c cuiStartMonth = new CN_Chef_UT_Item__c();
                cuiStartMonth.RecordTypeId = cuiRTID;
                cuiStartMonth.CN_Chefs_Assigned__c = ca.Id;
                cuiStartMonth.CN_Year_Month__c = startDateYearMonth;
                cuiStartMonth.CN_External_Id__c = ca.Id + '-' + startDateYearMonth;
                cuiStartMonth.CN_Chef_UT_OFF__c = yearMonthChefUTOFFIdMap.get(startDateYearMonth.left(4) + '-' + startDateYearMonth.right(2) + '-' + ca.CN_Chef__c);
                cuiStartMonth.OwnerId = ca.CN_Chef__c;
                CN_Chef_UT_Item__c cuiEndMonth = new CN_Chef_UT_Item__c();
                cuiEndMonth.RecordTypeId = cuiRTID;
                cuiEndMonth.CN_Chefs_Assigned__c = ca.Id;
                cuiEndMonth.CN_Year_Month__c = endDateYearMonth;
                cuiEndMonth.CN_External_Id__c = ca.Id + '-' + endDateYearMonth;
                cuiEndMonth.CN_Chef_UT_OFF__c = yearMonthChefUTOFFIdMap.get(endDateYearMonth.left(4) + '-' + endDateYearMonth.right(2) + '-' + ca.CN_Chef__c);
                cuiEndMonth.OwnerId = ca.CN_Chef__c;
                cuiList.add(cuiStartMonth);
                cuiList.add(cuiEndMonth);
            }
        }
        return cuiList;
    }

    public List<CN_Chef_UT_Item__c> generateChefUTItems(List<CN_Chefs_Assigned__c> caList) {
        Set<String> yearMonthChefIdSet = new Set<String>();
        Set<String> yearMonthSet = new Set<String>();
        for(CN_Chefs_Assigned__c ca: caList) {
            yearMonthSet.add(String.valueOf(ca.CN_Chef_Work_Start_Date__c.year()) + String.valueOf(ca.CN_Chef_Work_Start_Date__c.month()).leftPad(2, '0'));
            yearMonthSet.add(String.valueOf(ca.CN_Chef_Work_End_Date__c.year()) + String.valueOf(ca.CN_Chef_Work_End_Date__c.month()).leftPad(2, '0'));
            yearMonthChefIdSet.add(String.valueOf(ca.CN_Chef_Work_Start_Date__c.year()) + '-' +  String.valueOf(ca.CN_Chef_Work_Start_Date__c.month()).leftPad(2, '0') + '-' + ca.CN_Chef__c);
            yearMonthChefIdSet.add(String.valueOf(ca.CN_Chef_Work_End_Date__c.year()) + '-' +  String.valueOf(ca.CN_Chef_Work_End_Date__c.month()).leftPad(2, '0') + '-' + ca.CN_Chef__c);
        }
        Map<String, String> yearMonthChefUTIdMap = getChefUTMap(yearMonthSet);
        Map<String, String> yearMonthChefUTOFFIdMap = getChefUTOFFMap(yearMonthChefIdSet, yearMonthChefUTIdMap);
        List<CN_Chef_UT_Item__c> cuiList = generateChefUTItems(caList, yearMonthChefUTOFFIdMap);
        return cuiList;
    }

    public Map<String, String> getChefUTOFFMap(Set<String> yearMonthChefIdSet, Map<String, String> yearMonthChefUTIdMap) {
        Map<String, String> yearMonthChefUTOFFIdMap = new Map<String, String>();
        List<CN_Chef_UT_OFF__c> cuoList = [SELECT Id,
                                                CN_External_Id__c
                                            FROM CN_Chef_UT_OFF__c
                                            WHERE CN_External_Id__c =: yearMonthChefIdSet];
        Set<String> remainYearMonthChefIdSet = new Set<String>();
        remainYearMonthChefIdSet.addAll(yearMonthChefIdSet);
        for(CN_Chef_UT_OFF__c chefUTOFF: cuoList) {
            yearMonthChefUTOFFIdMap.put(chefUTOFF.CN_External_Id__c, chefUTOFF.Id);
            remainYearMonthChefIdSet.remove(chefUTOFF.CN_External_Id__c);
        }
        if(remainYearMonthChefIdSet.size() > 0) {
            List<CN_Chef_UT_OFF__c> chefUTOFFListForInsert = new List<CN_Chef_UT_OFF__c>();
            String chefUTOFFRTID = Schema.SObjectType.CN_Chef_UT_OFF__c.getRecordTypeInfosByDeveloperName().get('CN_Chef_UT_OFF').getRecordTypeId();
            for(String yearMonthChefId: remainYearMonthChefIdSet) {
                List<String> yearMonthChefIdList = yearMonthChefId.split('-');
                String year = yearMonthChefIdList[0];
                String month = yearMonthChefIdList[1];
                String chefId = yearMonthChefIdList[2];
                CN_Chef_UT_OFF__c cuo = new CN_Chef_UT_OFF__c();
                cuo.CN_External_Id__c = yearMonthChefId;
                cuo.CN_Chef__c = chefId;
                cuo.CN_Month__c = month;
                cuo.CN_Year__c = year;
                cuo.CN_Total_OFF_Days__c = 0;
                cuo.CN_Chef_UT__c = yearMonthChefUTIdMap.get(year + month);
                cuo.OwnerId = chefId;
                chefUTOFFListForInsert.add(cuo);
            }
            if(chefUTOFFListForInsert.size() > 0) {
                insert chefUTOFFListForInsert;
                for(CN_Chef_UT_OFF__c chefUTOFF: chefUTOFFListForInsert) {
                    yearMonthChefUTOFFIdMap.put(chefUTOFF.CN_External_Id__c, chefUTOFF.Id);
                }
            }
        }
        return yearMonthChefUTOFFIdMap;
    }

    public Map<String, String> getChefUTMap(Set<String> yearMonthSet) {
        Map<String, String> yearMonthIdMap = new Map<String, String>();
        List<CN_Chef_UT__c> chefUTList = [SELECT Id,
                                                CN_Year_Month__c
                                            FROM CN_Chef_UT__c
                                            WHERE CN_Year_Month__c =: yearMonthSet];
        Set<String> remainYearMonthSet = new Set<String>();
        remainYearMonthSet.addAll(yearMonthSet);
        List<CN_Chef_UT__c> chefUTInsertList = new List<CN_Chef_UT__c>();
        for(CN_Chef_UT__c chefUT: chefUTList) {
            yearMonthIdMap.put(chefUT.CN_Year_Month__c, chefUT.Id);
            remainYearMonthSet.remove(chefUT.CN_Year_Month__c);
        }
        if(remainYearMonthSet.size() > 0) {
            String chefUTRTID = Schema.SObjectType.CN_Chef_UT__c.getRecordTypeInfosByDeveloperName().get('CN_Chef_UT').getRecordTypeId();
            for(String yearMonth: remainYearMonthSet) {
                String year = yearMonth.left(4);
                String month = yearMonth.right(2);
                CN_Chef_UT__c chefUT = new CN_Chef_UT__c();
                chefUT.RecordTypeId = chefUTRTID;
                chefUT.CN_Year__c = year;
                chefUT.CN_Month__c = month.replace('0', '');
                chefUT.CN_Description__c = '';
                chefUT.CN_Working_Days__c = 0;
                chefUTInsertList.add(chefUT);
            }
            if(chefUTInsertList.size() > 0) {
                insert chefUTInsertList;
                for(CN_Chef_UT__c chefUT: chefUTInsertList) {
                    yearMonthIdMap.put(chefUT.CN_Year__c + chefUT.CN_Month__c.leftPad(2, '0'), chefUT.Id);
                }
            }
        }
        return yearMonthIdMap;
    }
}