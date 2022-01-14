/**************************************************************************************************
 * Name           : CN_Chefs_Assigned_Chef_UT_OFF_Handler
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Qiu Chen
 * Create Date    : 2021-12-28
 * Modify History : 
 **************************************************************************************************/
public without sharing class CN_Chefs_Assigned_Chef_UT_OFF_Handler implements Triggers.Handler {
    public void handle() {
        if(Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
        if(Trigger.isAfter && Trigger.isDelete) {
            handleAfterDelete();
        }
        if(Trigger.isAfter && Trigger.isUndelete) {
            handleAfterInsert();
        }
    }

    public void handleAfterDelete() {
        List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();
        for(CN_Chefs_Assigned__c ca: (List<CN_Chefs_Assigned__c>)Trigger.old) {
            if('OFF'.equals(ca.CN_Self_Work_Type__c)) {
                caList.add(ca);
            }
        }
        if(caList.size() > 0) {
            cleanAggrgatedOFFDays(caList);
        }
    }

    public void cleanAggrgatedOFFDays(List<CN_Chefs_Assigned__c> caList) {
        Set<String> startYearMonthSet = new Set<String>();
        Set<String> endYearMonthSet = new Set<String>();
        Set<String> chefIdSet = new Set<String>();
        for(CN_Chefs_Assigned__c ca: caList) {
            startYearMonthSet.add(String.valueOf(ca.CN_Chef_Work_Start_Date__c.year()) + String.valueOf(ca.CN_Chef_Work_Start_Date__c.month()).leftPad(2, '0'));
            endYearMonthSet.add(String.valueOf(ca.CN_Chef_Work_End_Date__c.year()) + String.valueOf(ca.CN_Chef_Work_End_Date__c.month()).leftPad(2, '0'));
            chefIdSet.add(ca.CN_Chef__c);
        }

        Map<String, Map<String, Decimal>> yearMonthChefOFFDaysMap = generateYearMonthChefOFFDaysMapForClean(caList);
        System.debug('yearMonthChefOFFDaysMap');
        System.debug(yearMonthChefOFFDaysMap);
        List<CN_Chef_UT_OFF__c> chefUTOFFList = getChefUTOFFMap(chefIdSet, startYearMonthSet, endYearMonthSet);
        List<CN_Chef_UT_OFF__c> chefUTOFFListForUpsert= generateChefUTOFF(chefUTOFFList, yearMonthChefOFFDaysMap);
        if(chefUTOFFListForUpsert.size() > 0) {
            upsert chefUTOFFListForUpsert CN_External_Id__c;
        }
    }

    public Map<String, Map<String, Decimal>> generateYearMonthChefOFFDaysMapForClean(List<CN_Chefs_Assigned__c> caList) {
        Map<String, Map<String, Decimal>> yearMonthChefOFFDaysMap = new Map<String, Map<String, Decimal>>();
        for(CN_Chefs_Assigned__c ca: caList) {
            if(ca.CN_Is_Work_Date_within_Same_Month__c) {
                if(yearMonthChefOFFDaysMap.containsKey(ca.CN_Start_Date_Year_Month__c)) {
                    Map<String, Decimal> chefIdOFFDaysMap = yearMonthChefOFFDaysMap.get(ca.CN_Start_Date_Year_Month__c);
                    if(chefIdOFFDaysMap.containsKey(ca.CN_Chef__c)) {
                        chefIdOFFDaysMap.put(ca.CN_Chef__c, chefIdOFFDaysMap.get(ca.CN_Chef__c) + ca.CN_Chef_Working_Days__c);
                    } else {
                        chefIdOFFDaysMap.put(ca.CN_Chef__c, ca.CN_Chef_Working_Days__c);
                    }
                    yearMonthChefOFFDaysMap.put(ca.CN_Start_Date_Year_Month__c, chefIdOFFDaysMap);
                } else {
                    yearMonthChefOFFDaysMap.put(ca.CN_Start_Date_Year_Month__c, new Map<String, Decimal>{ca.CN_Chef__c => ca.CN_Chef_Working_Days__c});
                }
            } else {

                if(yearMonthChefOFFDaysMap.containsKey(ca.CN_Start_Date_Year_Month__c)) {
                    Map<String, Decimal> chefIdOFFDaysMap = yearMonthChefOFFDaysMap.get(ca.CN_Start_Date_Year_Month__c);
                    if(chefIdOFFDaysMap.containsKey(ca.CN_Chef__c)) {
                        chefIdOFFDaysMap.put(ca.CN_Chef__c, chefIdOFFDaysMap.get(ca.CN_Chef__c) + ca.CN_Start_Date_to_Month_End_Days__c);
                    } else {
                        chefIdOFFDaysMap.put(ca.CN_Chef__c, ca.CN_Start_Date_to_Month_End_Days__c);
                    }
                    yearMonthChefOFFDaysMap.put(ca.CN_Start_Date_Year_Month__c, chefIdOFFDaysMap);
                } else {
                    yearMonthChefOFFDaysMap.put(ca.CN_Start_Date_Year_Month__c, new Map<String, Decimal>{ca.CN_Chef__c => ca.CN_Start_Date_to_Month_End_Days__c});
                }

                if(yearMonthChefOFFDaysMap.containsKey(ca.CN_End_Date_Year_Month__c)) {
                    Map<String, Decimal> chefIdOFFDaysMap = yearMonthChefOFFDaysMap.get(ca.CN_End_Date_Year_Month__c);
                    if(chefIdOFFDaysMap.containsKey(ca.CN_Chef__c)) {
                        chefIdOFFDaysMap.put(ca.CN_Chef__c, chefIdOFFDaysMap.get(ca.CN_Chef__c) + ca.CN_End_Date_to_Month_Start_Days__c);
                    } else {
                        chefIdOFFDaysMap.put(ca.CN_Chef__c, ca.CN_End_Date_to_Month_Start_Days__c);
                    }
                    yearMonthChefOFFDaysMap.put(ca.CN_Start_Date_Year_Month__c, chefIdOFFDaysMap);
                } else {
                    yearMonthChefOFFDaysMap.put(ca.CN_End_Date_Year_Month__c, new Map<String, Decimal>{ca.CN_Chef__c => ca.CN_End_Date_to_Month_Start_Days__c});
                }
            }
        }
        return yearMonthChefOFFDaysMap;
    }

    public List<CN_Chef_UT_OFF__c> getChefUTOFFMap(Set<String> chefIdSet, Set<String> endYearMonthSet, Set<String> startYearMonthSet) {
        Set<String> yearMonthSet = new Set<String>();
        yearMonthSet.addAll(startYearMonthSet);
        yearMonthSet.addAll(endYearMonthSet);
        List<CN_Chef_UT_OFF__c> cuoList = [SELECT Id,
                                                CN_External_Id__c,
                                                CN_Chef__c,
                                                CN_Total_OFF_Days__c,
                                                CN_YearMonth__c
                                            FROM CN_Chef_UT_OFF__c
                                            WHERE CN_Chef__c =: chefIdSet
                                                AND CN_YearMonth__c =: yearMonthSet];
        return cuoList;
    }

    public List<CN_Chef_UT_OFF__c> generateChefUTOFF(List<CN_Chef_UT_OFF__c> chefUTOFFList, Map<String, Map<String, Decimal>> yearMonthChefOFFDaysMap) {
        List<CN_Chef_UT_OFF__c> cuoList = new List<CN_Chef_UT_OFF__c>();
        for(CN_Chef_UT_OFF__c cuo: chefUTOFFList) {
            CN_Chef_UT_OFF__c newCuo = new CN_Chef_UT_OFF__c();
            newCuo.Id = cuo.Id;
            newCuo.CN_Total_OFF_Days__c = cuo.CN_Total_OFF_Days__c - yearMonthChefOFFDaysMap.get(cuo.CN_YearMonth__c).get(cuo.CN_Chef__c);
            newCuo.CN_External_Id__c = cuo.CN_External_Id__c;
            cuoList.add(newCuo);
        }
        return cuoList;
    }

    public void handleAfterInsert() {
        System.debug('handleAfterInsert Start');
        List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();
        for(CN_Chefs_Assigned__c ca: (List<CN_Chefs_Assigned__c>)Trigger.new) {
            if('OFF'.equals(ca.CN_Self_Work_Type__c)) {
                caList.add(ca);
            }
        }
        if(caList.size() > 0) {
            aggregateOFFDays(caList);
            //linkChefUTOFF(caList);
        }
    }

    public void aggregateOFFDays(List<CN_Chefs_Assigned__c> caList) {
        System.debug('aggregateOFFDays Start');
        Set<String> startYearMonthSet = new Set<String>();
        Set<String> endYearMonthSet = new Set<String>();
        Set<String> chefIdSet = new Set<String>();
        for(CN_Chefs_Assigned__c ca: caList) {
            startYearMonthSet.add(String.valueOf(ca.CN_Chef_Work_Start_Date__c.year()) + String.valueOf(ca.CN_Chef_Work_Start_Date__c.month()).leftPad(2, '0'));
            endYearMonthSet.add(String.valueOf(ca.CN_Chef_Work_End_Date__c.year()) + String.valueOf(ca.CN_Chef_Work_End_Date__c.month()).leftPad(2, '0'));
            chefIdSet.add(ca.CN_Chef__c);
        }

        Map<String, Map<String, Decimal>> yearMonthChefOFFDaysMap = generateYearMonthChefOFFDaysMap(chefIdSet, startYearMonthSet, endYearMonthSet);
        System.debug('yearMonthChefOFFDaysMap');
        System.debug(yearMonthChefOFFDaysMap);
        Set<String> yearMonthSet = yearMonthChefOFFDaysMap.keySet();
        Map<String, String> yearMonthIdMap = getChefUTMap(yearMonthSet);
        List<CN_Chef_UT_OFF__c> cuoList = generateChefUTOFFList(yearMonthChefOFFDaysMap, yearMonthIdMap);
        if(cuoList.size() > 0) {
            upsert cuoList CN_External_Id__c;
        }
    }

    public Map<String, Map<String, Decimal>> generateYearMonthChefOFFDaysMap(Set<String> chefIdSet, Set<String> startYearMonthSet, Set<String> endYearMonthSet) {
        Map<String, Map<String, Decimal>> yearMonthChefOFFDaysMap = new Map<String, Map<String, Decimal>>();
        List<CN_Chefs_Assigned__c> caQueryList = [SELECT Id,
                                                        CN_Chef_Working_Days__c,
                                                        CN_Chef__c,
                                                        CN_Start_Date_Year_Month__c,
                                                        CN_End_Date_Year_Month__c,
                                                        CN_Is_Work_Date_within_Same_Month__c,
                                                        CN_Start_Date_to_Month_End_Days__c,
                                                        CN_End_Date_to_Month_Start_Days__c
                                                    FROM CN_Chefs_Assigned__c
                                                    WHERE CN_Chef__c =: chefIdSet
                                                        AND CN_Is_Chef_Request_Confirmed__c = TRUE
                                                        AND CN_Self_Work_Type__c = 'OFF'
                                                        AND CN_Is_OFF__c = TRUE
                                                        AND (CN_Start_Date_Year_Month__c =: startYearMonthSet
                                                        OR CN_End_Date_Year_Month__c =: endYearMonthSet)];
        System.debug('startYearMonthSet');
        System.debug(startYearMonthSet);
        System.debug('endYearMonthSet');
        System.debug(endYearMonthSet);
        System.debug('chefIdSet');
        System.debug(chefIdSet);
        System.debug('caQueryList');
        System.debug(caQueryList);
        if(caQueryList.size() > 0) {
            for(CN_Chefs_Assigned__c ca: caQueryList) {        

                if(ca.CN_Is_Work_Date_within_Same_Month__c) {
                    if(yearMonthChefOFFDaysMap.containsKey(ca.CN_Start_Date_Year_Month__c)) {
                        Map<String, Decimal> chefIdOFFDaysMap = yearMonthChefOFFDaysMap.get(ca.CN_Start_Date_Year_Month__c);
                        if(chefIdOFFDaysMap.containsKey(ca.CN_Chef__c)) {
                            chefIdOFFDaysMap.put(ca.CN_Chef__c, chefIdOFFDaysMap.get(ca.CN_Chef__c) + ca.CN_Chef_Working_Days__c);
                        } else {
                            chefIdOFFDaysMap.put(ca.CN_Chef__c, ca.CN_Chef_Working_Days__c);
                        }
                        yearMonthChefOFFDaysMap.put(ca.CN_Start_Date_Year_Month__c, chefIdOFFDaysMap);
                    } else {
                        yearMonthChefOFFDaysMap.put(ca.CN_Start_Date_Year_Month__c, new Map<String, Decimal>{ca.CN_Chef__c => ca.CN_Chef_Working_Days__c});
                    }
                } else {

                    if(yearMonthChefOFFDaysMap.containsKey(ca.CN_Start_Date_Year_Month__c)) {
                        Map<String, Decimal> chefIdOFFDaysMap = yearMonthChefOFFDaysMap.get(ca.CN_Start_Date_Year_Month__c);
                        if(chefIdOFFDaysMap.containsKey(ca.CN_Chef__c)) {
                            chefIdOFFDaysMap.put(ca.CN_Chef__c, chefIdOFFDaysMap.get(ca.CN_Chef__c) + ca.CN_Start_Date_to_Month_End_Days__c);
                        } else {
                            chefIdOFFDaysMap.put(ca.CN_Chef__c, ca.CN_Start_Date_to_Month_End_Days__c);
                        }
                        yearMonthChefOFFDaysMap.put(ca.CN_Start_Date_Year_Month__c, chefIdOFFDaysMap);
                    } else {
                        yearMonthChefOFFDaysMap.put(ca.CN_Start_Date_Year_Month__c, new Map<String, Decimal>{ca.CN_Chef__c => ca.CN_Start_Date_to_Month_End_Days__c});
                    }

                    if(yearMonthChefOFFDaysMap.containsKey(ca.CN_End_Date_Year_Month__c)) {
                        Map<String, Decimal> chefIdOFFDaysMap = yearMonthChefOFFDaysMap.get(ca.CN_End_Date_Year_Month__c);
                        if(chefIdOFFDaysMap.containsKey(ca.CN_Chef__c)) {
                            chefIdOFFDaysMap.put(ca.CN_Chef__c, chefIdOFFDaysMap.get(ca.CN_Chef__c) + ca.CN_End_Date_to_Month_Start_Days__c);
                        } else {
                            chefIdOFFDaysMap.put(ca.CN_Chef__c, ca.CN_End_Date_to_Month_Start_Days__c);
                        }
                        yearMonthChefOFFDaysMap.put(ca.CN_End_Date_Year_Month__c, chefIdOFFDaysMap);
                    } else {
                        yearMonthChefOFFDaysMap.put(ca.CN_End_Date_Year_Month__c, new Map<String, Decimal>{ca.CN_Chef__c => ca.CN_End_Date_to_Month_Start_Days__c});
                    }
                }
            }
        }
        return yearMonthChefOFFDaysMap;
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
        }
        if(chefUTInsertList.size() > 0) {
            insert chefUTInsertList;
            for(CN_Chef_UT__c chefUT: chefUTInsertList) {
                yearMonthIdMap.put(chefUT.CN_Year__c + chefUT.CN_Month__c.leftPad(2, '0'), chefUT.Id);
            }
        }
        return yearMonthIdMap;
    }

    public List<CN_Chef_UT_OFF__c> generateChefUTOFFList(Map<String, Map<String, Decimal>> yearMonthChefOFFDaysMap, Map<String, String> yearMonthIdMap) {
        List<CN_Chef_UT_OFF__c> cuoList = new List<CN_Chef_UT_OFF__c>();
        for(String yearMonth: yearMonthChefOFFDaysMap.keySet()) {
            Map<String, Decimal> chefIdOFFDaysMap = yearMonthChefOFFDaysMap.get(yearMonth);
            for(String chefId: chefIdOFFDaysMap.keyset()) {
                String year = yearMonth.left(4);
                String month = yearMonth.right(2);
                CN_Chef_UT_OFF__c cuo = new CN_Chef_UT_OFF__c();
                cuo.CN_External_Id__c = year + '-' + month + '-' + chefId;
                cuo.CN_Chef__c = chefId;
                cuo.CN_Month__c = month;
                cuo.CN_Year__c = year;
                cuo.CN_Total_OFF_Days__c = chefIdOFFDaysMap.get(chefId);
                cuo.CN_Chef_UT__c = yearMonthIdMap.get(yearMonth);
                cuo.OwnerId = chefId;
                cuoList.add(cuo);
            }
        }
        return cuoList;
    }
}