/**************************************************************************************************
 * Name           : CN_Chef_UT_Report_Batch_Test
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Dezheng Du
 * Create Date    : 2022-01-07
 * Modify History : 
 **************************************************************************************************/
@isTest
private class CN_Chef_UT_Report_Batch_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.makeBaseData();
    }

    @isTest
    private static void CN_Chef_UT_Report_Batch_Test() {
        TestDataFactory testFactory = new TestDataFactory();
        testFactory.makeFactoryAccount();
        Account acc_factory = [SELECT Id, OwnerId FROM Account WHERE CN_License_Name_EN__c = 'TestAccount_Factory'][0];


        List<User> userList = [SELECT Id, LastName FROM User WHERE lastName in ('Sales1', 'Sales3', 'ChefManager', 'Chef')];
        Map<String, User> lastNameUserMap = new Map<String, User>();
        for(User usr: userList) {
            lastNameUserMap.put(usr.LastName, usr);
        }
        User chef = lastNameUserMap.get('Chef');
        User chefManager = lastNameUserMap.get('ChefManager');
        Id chefRequest1on1NewRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_1ON1_NEW_RT_API_NAME).getRecordTypeId();
        Id chefRequestSelfRTId = Schema.SObjectType.CN_Chef_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.CN_CHEF_REQUEST_CHEF_SELF_RT_API_NAME).getRecordTypeId();

        Date today = Date.today();
        
        Date startDate = Date.newInstance(today.year(),today.addMonths(3).month(),28);
        Date endDate = Date.newInstance(today.year(),today.addMonths(4).month(),3);

        List<CN_Chef_Request__c> crList = new List<CN_Chef_Request__c>();
        //Normal Chef Request
        CN_Chef_Request__c cr1 = new CN_Chef_Request__c(
            CN_Event_Location__c = 'SH Chef Studio',
            CN_Event_Theme__c = 'Test Chef Request',
            CN_Start_Date__c = Date.today().addMonths(3),
            CN_End_Date__c = Date.today().addMonths(3).addDays(13),
            CN_Event_Type__c = '1-on-1 service',
            RecordTypeId = chefRequest1on1NewRTId
        );
        crList.add(cr1);
        // OFF Chef Request
        CN_Chef_Request__c cr2 = new CN_Chef_Request__c(
            CN_Event_Location__c = 'SH Chef Studio',
            CN_Event_Theme__c = 'Test Chef Request',
            CN_Start_Date__c = Date.today().addMonths(3),
            CN_End_Date__c = Date.today().addMonths(3).addDays(13),
            CN_Event_Type__c = 'OFF', 
            RecordTypeId = chefRequestSelfRTId
        );
        crList.add(cr2);
        System.runAs(chef) {
            insert crList;
        }

        System.runAs(chefManager) {
            List<CN_Chefs_Assigned__c> caList = new List<CN_Chefs_Assigned__c>();
            CN_Chefs_Assigned__c ca1 = new CN_Chefs_Assigned__c(
                CN_Chef_Request__c = cr1.Id,
                CN_Chef__c = chef.Id,
                CN_Chef_Role__c	= 'Leading Chef',
                CN_Chef_Work_Start_Date__c = Date.today().addMonths(3),
                CN_Chef_Work_End_Date__c = Date.today().addMonths(3).addDays(13)
            );
            caList.add(ca1);
            CN_Chefs_Assigned__c ca2 = new CN_Chefs_Assigned__c(
                CN_Chef_Request__c = cr1.Id,
                CN_Chef__c = chef.Id,
                CN_Chef_Role__c	= 'Leading Chef',
                CN_Chef_Work_Start_Date__c = Date.today().addMonths(3),
                CN_Chef_Work_End_Date__c = Date.today().addMonths(3).addDays(13)
            );
            caList.add(ca2);
            CN_Chefs_Assigned__c ca3 = new CN_Chefs_Assigned__c(
                CN_Chef_Request__c = cr1.Id,
                CN_Chef__c = chef.Id,
                CN_Chef_Role__c	= 'Leading Chef',
                CN_Chef_Work_Start_Date__c = startDate,
                CN_Chef_Work_End_Date__c = endDate
            );
            caList.add(ca3);
            //CN_Event_Type__c = 'OFF' && month of startDate and end date are same
            CN_Chefs_Assigned__c ca4 = new CN_Chefs_Assigned__c(
                CN_Chef_Request__c = cr2.Id,
                CN_Chef__c = chef.Id,
                CN_Chef_Role__c	= 'Leading Chef',
                CN_Chef_Work_Start_Date__c = startDate,
                CN_Chef_Work_End_Date__c = startDate.addDays(1)
            );
            caList.add(ca4);
            insert caList;
        }



        //运行batch
        Test.startTest();

        CN_Chef_UT_Report_Batch batch = new CN_Chef_UT_Report_Batch();
        Database.executeBatch(batch);

        String runningYearMonth = String.valueOf(today.year()) + String.valueOf(today.month()).leftPad(2, '0');
        CN_Chef_UT_Report_Batch batch_parameter  = new CN_Chef_UT_Report_Batch(runningYearMonth);
        Database.executeBatch(batch_parameter);

        String queryString = 'SELECT Id, RecordType.DeveloperName, CN_Is_OFF__c, CN_Event_Type__c, CN_Is_Work_Date_within_Same_Month__c, CN_Start_Date_Year_Month__c, CN_End_Date_Year_Month__c, CN_Chef__c, CN_Start_Date_to_Month_End_Days__c, CN_End_Date_to_Month_Start_Days__c, CN_Chef_Working_Days__c, CN_Chef_Work_Start_Date__c, CN_Chef_Work_End_Date__c FROM CN_Chefs_Assigned__c';
        CN_Chef_UT_Report_Batch batch_parameter2  = new CN_Chef_UT_Report_Batch(runningYearMonth,queryString);
        Database.executeBatch(batch_parameter2);

        CN_Chef_UT_Report_SCH batch_SCH = new CN_Chef_UT_Report_SCH();
        System.schedule('CN_Chef_UT_Report_SCH' + Datetime.now(), '20 30 8 10 2 ?', batch_SCH);

        Test.stopTest();
    }
}