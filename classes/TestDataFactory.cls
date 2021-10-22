public class TestDataFactory {
    
    public static List<Profile> profileList = null;
    public static List<UserRole> userRoleList = null; 

    public static void makeBaseData(){
        makeRoleFuture();       //CCE的role也需要手动添加
        makeOrder();
        
        List<sObject> objectList = new List<sObject>();
        objectList.add(makeProvince('010-Beijing', '010'));
        objectList.add(makeCity('010-Beijing', '010', 'K010', '010'));
        objectList.add(makeCity('020-Beijing', '020', 'K020', '010'));
        objectList.add(makeInternalImployee('TestUser1', 'Test0001', 'TestUser1@example.com', 'Sales'));
        objectList.add(makeInternalImployee('TestUser2', 'Test0002', 'TestUser2@example.com', 'AR'));
        objectList.add(makeInternalImployee('TestUser6', 'Test0021', 'TestUser6@example.com', 'AR'));
        objectList.add(makeInternalImployee('TestUser3', 'Test00012', 'TestUser3@example.com', 'Sales'));
        objectList.add(makeInternalImployee('TestUser4', 'Test0012', 'TestUser4@example.com', 'Sales'));
        objectList.add(makeInternalImployee('TestUser5', 'Test0013', 'TestUser5@example.com', 'Sales'));


        objectList.add(makeBusinessUnit('Food Service', '0000900001'));
        objectList.add(makeBusinessUnit('RETAIL', '0000900002'));
        objectList.add(makeBusinessUnit('INTERCOMPANY', '0000900003'));

        objectList.add(makeSalesTeam('Food Service_SalesTeam1', '0000900001', '0000901001'));
        objectList.add(makeSalesTeam('Food Service_SalesTeam2', '0000900001', '0000901002'));
        objectList.add(makeSalesTeam('RETAIL_SalesTeam', '0000900002', '0000901003'));
        objectList.add(makeSalesTeam('INTERCOMPANY_SalesTeam', '0000900003', '0000901004'));

        objectList.add(makeGroup('Food Service_SalesTeam1_Group', '0000901001', 'drink group'));
        objectList.add(makeGroup('Food Service_SalesTeam2_Group', '0000901002', 'food group'));
        objectList.add(makeGroup('RETAIL_SalesTeam_Group', '0000901003', 'retail group'));
        objectList.add(makeGroup('INTERCOMPANY_SalesTeam_Group', '0000901004', 'intercompany group'));

        objectList.add(makeProduct('TestProduct00001', 'P00001'));
        objectList.add(makeProduct('TestProduct00002', 'P00002'));

        ObjectList.Add(makePriceBook('Pricebook WS', 'test pricebook description', 'WS',false));
        ObjectList.Add(makePriceBook('Pricebook DS', 'test pricebook description', 'DS',false));
        ObjectList.Add(makePriceBook('Pricebook KA', 'test pricebook description', 'KA',false));
        

        insert objectList;

        makePriceBookEntry();
        makeUserFuture();
    }

    private static User makeUser(String lastName, String prfileName, String roleName, String title, String pN, String salesTeam, String salesOffice) {
        List<Profile> proList = getProfileList();
        Map<String, String> profileMap = new Map<String, String>();
        for(Profile profile : proList) {
            profileMap.put(profile.Name, profile.Id);
        }
        List<UserRole> roleList = getUserRoleList();
        Map<String, String> roleMap = new Map<String, String>();
        for(UserRole role : userRoleList) {
            roleMap.put(role.DeveloperName, role.Id);
        }
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 

        User user = new User(
            LastName = lastName,
            Email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            Alias = uniqueName.substring(18, 23), 
            ProfileId = profileMap.get(prfileName),
            UserRoleId = roleMap.get(roleName),
            LanguageLocaleKey = 'zh_CN',
            LocaleSidKey = 'zh_CN',
            TimeZoneSidKey = 'Asia/Shanghai',
            EmailEncodingKey = 'UTF-8',
            CN_Sales_Office__c = salesOffice,
            CN_Sales_Team__c = salesTeam,
            CN_User_Personnel_Number__c = pN,
            Title = title
        );
        return user;
    }    
    
    public static User makeUser(String userId, String managerId) {
        User user = new User();
        user.Id = userId;
        user.ManagerId = managerId;
        return user;
    }

    private static CN_Province__c makeProvince(String provinceName, String provinceCode) {
        CN_Province__c province = new CN_Province__c();
        province.Province_Code__c = provinceCode;
        province.Name = provinceName;
        province.CN_Province_CN__c = provinceName;
        province.CN_Province_EN__c = provinceName;
        province.RecordTypeId = getRecordTypeId('CN_Province__c', 'CN_Province');
        return province;
    }

    private static CN_City__c makeCity(String cityName, String cityCode, String salesOffice, String provinceCode) {
        CN_City__c city = new CN_City__c();
        city.CN_City_Code__c = cityCode;
        city.Name = cityName;
        city.CN_City_CN__c = cityName;
        city.CN_City_EN__c = cityName;
        city.CN_Province__r = new CN_Province__c(Province_Code__c = provinceCode);
        city.CN_Sales_Office__c = salesOffice;
        city.RecordTypeId = getRecordTypeId('CN_City__c', 'CN_City');
        return city;
    }

    private static CN_Internal_Employee__c makeInternalImployee(String userName, String pNCode, String userEmail, String userRole) {
        CN_Internal_Employee__c internalEmployee = new CN_Internal_Employee__c();
        internalEmployee.CN_Role__c = userRole;
        internalEmployee.CN_User_Name__c = userName;
        internalEmployee.Name = userName;
        internalEmployee.CN_Personnel_Number__c = pNCode;
        internalEmployee.CN_User_Email__c = userEmail;
        internalEmployee.RecordTypeId = getRecordTypeId('CN_Internal_Employee__c', 'CN_Internal_Employee');
        return internalEmployee;
    }

    private static UserRole makeRole(String roleId, String parentRoleId) {
        UserRole role = new UserRole();
        role.Id = roleId;
        role.ParentRoleId = parentRoleId;
        return role;
    }
    private static UserRole makeRole(String roleName) {
        UserRole role = new UserRole();
        role.Name = roleName;
        role.DeveloperName = roleName;
        return role;
    }

    @future
    public static void makeRoleFuture() {
        List<sObject> objectList1 = new List<sObject>();
        objectList1.add(makeRole('CN_CM'));
        objectList1.add(makeRole('CN_RM'));
        objectList1.add(makeRole('CN_ARM'));
        objectList1.add(makeRole('CN_Manager'));
        objectList1.add(makeRole('CN_Sales'));
        insert objectList1;
        List<sObject> updateObjectList = new List<sObject>();
        List<UserRole> roleList = [SELECT Id, Name, DeveloperName, ParentRoleId FROM UserRole];
        Map<String, Id> roleNameIdMap = new Map<String, Id>();
        for(UserRole role: roleList) {
            roleNameIdMap.put(role.DeveloperName, role.Id);
        }
        updateObjectList.add(makeRole(roleNameIdMap.get('CN_CM'), roleNameIdMap.get('CN_Commercial_Director')));
        updateObjectList.add(makeRole(roleNameIdMap.get('CN_RM'), roleNameIdMap.get('CN_CM')));
        updateObjectList.add(makeRole(roleNameIdMap.get('CN_ARM'), roleNameIdMap.get('CN_RM')));
        updateObjectList.add(makeRole(roleNameIdMap.get('CN_Manager'), roleNameIdMap.get('CN_ARM')));
        updateObjectList.add(makeRole(roleNameIdMap.get('CN_Sales'), roleNameIdMap.get('CN_Manager')));
        update updateObjectList;
    }

    @future
    public static void makeUserFuture() {
        List<sObject> objectList = new List<sObject>();
        objectList.add(makeUser('CEO', 'CN Sales Lead', 'CN_CEO', 'CEO', 'Test0003', '0000901001', ''));
        objectList.add(makeUser('CFO', 'CN CFO', 'CN_Finance_Director', 'CFO', 'Test0004', '0000901001', ''));
        objectList.add(makeUser('FinanceAR', 'CN Finance AR', 'CN_Finance_AR', 'Finance AR', 'Test0002', '0000901001', ''));
        objectList.add(makeUser('FinanceAR2', 'CN Finance AR', 'CN_Finance_AR', 'Finance AR', 'Test0021', '0000901001', ''));
        objectList.add(makeUser('FinanceMDM', 'CN Finance MDM', 'CN_Finance_MDM', 'Finance MDM', 'Test0006', '0000901001', ''));
        objectList.add(makeUser('SalesMDM', 'CN Sales MDM', 'CN_Sales_MDM', 'Sales MDM', 'Test0007', '0000901001', ''));
        objectList.add(makeUser('CD', 'CN Sales Lead', 'CN_Commercial_Director', 'Commerical Director', 'Test0008', '0000901001', ''));
        objectList.add(makeUser('CM', 'CN Sales Manager', 'CN_CM', 'Channel Manager', 'Test0009', '0000901001', ''));
        objectList.add(makeUser('RM', 'CN Sales Manager', 'CN_RM', 'Regional Manager', 'Test0010', '0000901001', ''));
        objectList.add(makeUser('ARM', 'CN Sales Manager', 'CN_ARM', 'Assistant Regional Manager', 'Test0011', '0000901001', ''));
        objectList.add(makeUser('Manager', 'CN Sales Manager', 'CN_Manager', 'Manager', 'Test0012', '0000901001', ''));
        objectList.add(makeUser('Sales1', 'CN Sales', 'CN_Sales', 'Sales Rep', 'Test0001', '0000901001', 'K010'));
        objectList.add(makeUser('Sales2', 'CN Sales', 'CN_Sales', 'Sales Rep', 'Test00012', '0000901001', 'K020'));
        objectList.add(makeUser('Sales3', 'CN Sales', 'CN_Sales', 'Sales Rep', 'Test00019', '0000901001', 'K030'));
        objectList.add(makeUser('WholeSalesDevelopmentSupervisor', 'CN Sales Manager', 'CN_RM', 'Regional Manager', 'Test0013', '0000901001', 'K010'));
        objectList.add(makeUser('CCE1_KA', 'CN CCE', 'CN_CCE', '', 'Test0014', '', ''));
        objectList.add(makeUser('CCE2_DS', 'CN CCE', 'CN_CCE', '', 'Test0015', '', ''));
        objectList.add(makeUser('CCE3_WS', 'CN CCE', 'CN_CCE', '', 'Test0016', '', ''));
        objectList.add(makeUser('ChefManager', 'CN Chef Manager', 'CN_Chef_Manager', '', 'Test0017', '', ''));
        objectList.add(makeUser('Chef', 'CN Chef', 'CN_Chef', '', 'Test0018', '', ''));
        objectList.add(makeUser('QA', 'CN QA', 'CN_QA', '', 'Test0019', '', ''));
        objectList.add(makeUser('CS', 'CN C/S', 'CN_CS', '', 'Test0020', '', ''));
        system.debug('makeUserFuture objectList:          ' + objectList);
        insert objectList;

        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameIdMap.put(usr.LastName, usr.Id);
        }
        List<sObject> objectListForUpdate = new List<sObject>();
        objectListForUpdate.add(makeUser(lastNameIdMap.get('CD'), lastNameIdMap.get('CEO')));
        objectListForUpdate.add(makeUser(lastNameIdMap.get('CM'), lastNameIdMap.get('CD')));
        objectListForUpdate.add(makeUser(lastNameIdMap.get('RM'), lastNameIdMap.get('CM')));
        objectListForUpdate.add(makeUser(lastNameIdMap.get('ARM'), lastNameIdMap.get('RM')));
        objectListForUpdate.add(makeUser(lastNameIdMap.get('Manager'), lastNameIdMap.get('ARM')));
        objectListForUpdate.add(makeUser(lastNameIdMap.get('Sales1'), lastNameIdMap.get('Manager')));
        objectListForUpdate.add(makeUser(lastNameIdMap.get('Sales2'), lastNameIdMap.get('Manager')));
        objectListForUpdate.add(makeUser(lastNameIdMap.get('Sales3'), lastNameIdMap.get('CD')));
        update objectListForUpdate;

        
        List<PermissionSet> psList = [SELECT Id, Name FROM PermissionSet];
        Map<String, Id> psMap = new Map<String, Id>();
        for(PermissionSet ps: psList) {
            psMap.put(ps.Name, ps.Id);
        }

        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        psaList.add(new PermissionSetAssignment(AssigneeId = lastNameIdMap.get('CCE1_KA'), PermissionSetId = psMap.get('CN_Promotion_Manager')));
        insert psaList;

    }

    private static Id getRecordTypeId(String objectName, String recordTypeName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    private static List<Profile> getProfileList() {
        if(profileList == null) {
            profileList = [SELECT Id, Name FROM Profile];
            return profileList;
        } else {
            return profileList;
        }
    }

    private static List<UserRole> getUserRoleList() {
        if(userRoleList == null) {
            userRoleList = [SELECT Id, Name, DeveloperName, ParentRoleId FROM UserRole];
            return userRoleList;
        } else {
            return userRoleList;
        }
    }

    private static CN_Order_Reason__c makeOrderReason(String name,String currencyIsoCode,String externalId){
        CN_Order_Reason__c salesReason  = new CN_Order_Reason__c();
         salesReason.Name = name;
         salesReason.CurrencyIsoCode = currencyIsoCode;
         salesReason.CN_Order_Reason_External_ID__c = externalId;
        return salesReason;
    }

    private static CN_Sales_Order_Type__c makeOrderType(String name,String currencyIsoCode,String externalId){
        CN_Sales_Order_Type__c salesOrder  = new CN_Sales_Order_Type__c();
        salesOrder.Name = name;
        salesOrder.CurrencyIsoCode = currencyIsoCode;
        salesOrder.CN_Sales_Order_Type_External_ID__c = externalId;
        return salesOrder;
    }

    private static Product2 makeProduct(String name, String SKUCode) {
        Product2 product = new Product2();
        product.IsActive = true;
        product.Name = name;
        product.ProductCode = SKUCode;
        product.CN_SKU_Code__c = SKUCode;
        return product;
    }
    
    private static Pricebook2 makePriceBook(String name,String description,String channel,Boolean isStandard){
        Id visitRTId = Schema.SObjectType.Pricebook2.getRecordTypeInfosByDeveloperName().get(Constants.CN_PB_RT_API_NAME).getRecordTypeId();
        Pricebook2 pricebook = new Pricebook2();
        if(isStandard == true){
            pricebook.Id = Test.getStandardPricebookId();
        }else{
            pricebook.Name = name;
            pricebook.Description = description;
            pricebook.CN_Channel__c = channel;
            pricebook.IsActive = true;
            pricebook.RecordTypeId = visitRTId;
        }
        pricebook.CN_Effective_Date__c = System.today();
        pricebook.CN_Expiration_Date__c = System.today() + 2;
        return pricebook;
    }

    private static void makePriceBookEntry(){
        List<PricebookEntry> pbEntryList = new List<PricebookEntry>();
        List<PricebookEntry> pbEntryList_Standard = new List<PricebookEntry>();

        List<Pricebook2> pricebookList = [Select Id,IsStandard,CN_Channel__c From Pricebook2];
        List<Product2> productList = [Select Id,name From Product2];

        for(Product2 product : productList){
            PricebookEntry pbEntry = new PricebookEntry(
                UnitPrice  = 1,
                CN_Minimum_Price__c  = 2,
                CN_Promo_Price_P1__c = 5,
                CN_Promo_Price_P2__c = 10,
                CN_Promo_Price_P3__c = 20,
                CN_Promo_Price_P4__c = 30,
                IsActive = true,
                Pricebook2Id  = Test.getStandardPricebookId(),
                Product2Id  = product.Id
            );
            pbEntryList_Standard.add(pbEntry);
        }
        insert pbEntryList_Standard;

        for(Pricebook2 pb : pricebookList){
            for(Product2 product : productList){
                PricebookEntry pbEntry = new PricebookEntry(
                    UnitPrice  = 1,
                    CN_Minimum_Price__c  = 2,
                    CN_Promo_Price_P1__c = 5,
                    CN_Promo_Price_P2__c = 10,
                    CN_Promo_Price_P3__c = 20,
                    CN_Promo_Price_P4__c = 30,
                    IsActive = true,
                    Pricebook2Id  = pb.Id,
                    Product2Id  = product.Id
                );
                pbEntryList.add(pbEntry);
            }
        }
        
        insert pbEntryList;
    }

    public static void makeOrder(){
        List<sObject> objectList = new List<sObject>();
        objectList.add(makeOrderType('Standard order','CNY','OR1'));
        objectList.add(makeOrderType('Ret.Packaging Pickup','CNY','LA'));
        objectList.add(makeOrderReason('SO-Fax','CNY','010'));
        objectList.add(makeOrderReason('Sample-Trade marketing','CNY','027'));
        insert ObjectList;
    }

    private static CN_Business_Unit__c makeBusinessUnit(String name,String businessUnitCode){
        CN_Business_Unit__c businessUnit = new CN_Business_Unit__c();
        businessUnit.Name = name;
        businessUnit.CN_City_API__c = 'Shanghai';
        businessUnit.CN_Is_Activated__c = true;
        businessUnit.CN_Sync_Status__c = 'Success';
        businessUnit.CN_Business_Unit_Code__c = businessUnitCode;
        businessUnit.CurrencyIsoCode = 'CNY';
        return businessUnit;
    }

    private static CN_Sales_Team__c makeSalesTeam(String name,String unitCode,String salesTeamCode){
        CN_Sales_Team__c salesTeam = new CN_Sales_Team__c();
        salesTeam.Name = name;
        salesTeam.CN_City_API__c = 'Shanghai';
        salesTeam.CN_Is_Activated__c = true;
        salesTeam.CN_Sync_Status__c = 'Success';
        salesTeam.CN_Business_Unit__r = new CN_Business_Unit__c(CN_Business_Unit_Code__c = unitCode);
        salesTeam.CurrencyIsoCode = 'CNY';
        salesTeam.CN_Sales_Team_Code__c = salesTeamCode;
        return salesTeam;
    }

    private static CN_Group__c makeGroup(String name,String salesTeamCode,String groupCode){
        CN_Group__c salesgroup = new CN_Group__c();
        salesgroup.Name = name;
        salesgroup.CN_City_API__c = 'Shanghai';
        salesgroup.CN_Is_Activated__c = true;
        salesgroup.CN_Sync_Status__c = 'Success';
        salesgroup.CN_Group_Code__c = groupCode;
        salesgroup.CN_Sales_Team__r = new CN_Sales_Team__c(CN_Sales_Team_Code__c = salesTeamCode);
        salesgroup.CurrencyIsoCode = 'CNY';
        return salesgroup;
    }

    public List<Account> makeFactoryAccount(){
        makeCustomSetting();
        List<Account> accList = makeAccounts(1,true);
        return accList;
    }

    public void makeCustomSetting(){
        List<User> userList = [SELECT Id, LastName FROM User];
        Map<String, Id> lastNameUserIdMap = new Map<String, Id>();
        for(User usr: userList) {
            lastNameUserIdMap.put(usr.LastName, usr.Id);
        }
        Trigger_Switcher_Setting__c setting = new Trigger_Switcher_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            EnableFlow__c = true,
            EnableTrigger__c = true,
            EnableValidationRule__c = false
        );
        insert setting;
        
        CN_Approve_Process_Settings__c approveSetting = new CN_Approve_Process_Settings__c(
            CN_CEO_UserId__c = lastNameUserIdMap.get('CEO'),
            CN_CFO_UserId__c = lastNameUserIdMap.get('CFO'),
            CN_Finance_AR_UserId__c = lastNameUserIdMap.get('FinanceAR'),
            CN_Finance_MDM_UserId__c = lastNameUserIdMap.get('FinanceMDM'),
            CN_Sales_MDM_UserId__c = lastNameUserIdMap.get('SalesMDM'),
            CN_WholeSales_Development_Supervisor__c = lastNameUserIdMap.get('WholeSalesDevelopmentSupervisor'),
            CN_CCE1_KA__c = lastNameUserIdMap.get('CCE1_KA'),
            CN_CCE2_DS__c = lastNameUserIdMap.get('CCE2_DS'),
            CN_CCE3_WS__c = lastNameUserIdMap.get('CCE3_WS'),
            CN_MKT_Group_Email__c = 'MKTGroup@testSavencia.com',
            CN_CS_Group_Email__c = 'CSGroup@testSavencia.com'
        );
        insert approveSetting;

        CN_Quote_Number_Setting__c quoteNumberSetting = new CN_Quote_Number_Setting__c(
            CN_Quote_Number__c = 0,
            CN_DateTime__c = System.Now()
        );
        insert quoteNumberSetting;

        CN_Gaode_Setting__c gaodeSetting = new CN_Gaode_Setting__c(
            Geolocation_Endpoint__c = 'https://127.0.0.1/gaode/',
            JS_Key__c = '59b6a65f0f51fe55555fb555f4b55555',
            Layer100_Icon_Name__c = 'L100.png',
            Layer80_Icon_Name__c = 'L80.png',
            Layer50_Icon_Name__c = 'L50.png',
            Layer20_Icon_Name__c = 'L20.png',
            Prospect_Icon_Name__c = 'Undefined.png',
            Undefined_Icon_Name__c = 'Prospect.png',
            Web_Key__c = '7dc3056f733bbb2155555e555wd55555'
        );
        insert gaodeSetting;

        List<Pricebook2> pbList = [Select Id,CN_Channel__c From Pricebook2];
        CN_Price_Book_Setting__c priceBookSetting = new CN_Price_Book_Setting__c();
        for(Pricebook2 pb : pbList){
            if(pb.CN_Channel__c == 'DS'){
                priceBookSetting.CN_Price_Book1__c = pb.Id;
            }else if(pb.CN_Channel__c == 'KA'){
                priceBookSetting.CN_Price_Book2__c = pb.Id;
            }else if(pb.CN_Channel__c == 'WS'){
                priceBookSetting.CN_Price_Book3__c = pb.Id;
            }
        }
        insert priceBookSetting;
    }

    public List<Account> makeAccounts(integer num) {
        makeCustomSetting();
        return makeAccounts(num, false);
    }
    
    public List<Account> makeAccounts(integer num,Boolean isFactory){

        List<String> nameWord  = new List<String>{'测甲','试乙','上丙','海丁','春戊','夏己','秋庚','冬辛','乾甲','坤乙','震丙','巽丁','坎戊','离丁','艮己','兑庚','老辛','少甲','阳乙','阴丙'};

        User salesRep = [SELECT Id FROM User WHERE lastName = 'Sales1'][0];
        CN_Province__c province = [SELECT Id FROM CN_Province__c WHERE Province_Code__c = '010'][0];
        CN_City__c city = [SELECT Id FROM CN_City__c WHERE CN_City_Code__c = '010'][0];
        CN_Business_Unit__c businessUnit = [SELECT Id FROM CN_Business_Unit__c WHERE CN_Business_Unit_Code__c = '0000900001'][0];
        CN_Sales_Team__c salesTeam = [SELECT Id FROM CN_Sales_Team__c WHERE CN_Sales_Team_Code__c = '0000901001'][0];
        
        List<Account> accList = new List<Account>();

        System.runAs(salesRep) {
            Id newDirectRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.CN_Account_RT_API_NAME_NEW_DIRECT).getRecordTypeId();

            for(integer n = 1; n <= num ; n++){
                Account acc = new Account();
                acc.RecordTypeId = newDirectRTId;
                String accName = 'A';
                for(integer p = 0 ; p < n ; p++){
                    if(p<5){
                        accName += nameWord[p];
                    }else if(p >= 5 && p < 10){
                        accName = null;
                        accName += nameWord[p-5];
                    }else if(p >= 10 && p < 15){
                        accName = null;
                        accName += nameWord[p-10];
                    }else if(p >= 15 && p < 20){
                        accName = null;
                        accName += nameWord[p-15];
                    }
                }
                acc.Name = accName;
                if(isFactory == true){
                    acc.Name = 'TestAccount_Factory';
                    acc.CN_License_Name_EN__c = 'TestAccount_Factory';
                    acc.CN_Store_Name_EN__c = 'TestAccount_Factory';
                    acc.CN_Store_Name_CN__c = 'TestAccount_Factory';
                }else{
                    acc.CN_License_Name_EN__c = 'TestAccount';
                    acc.CN_Store_Name_EN__c = 'TestAccount';
                    acc.CN_Store_Name_CN__c = 'TestAccount';
                }
                acc.CN_Sales_District__c = '001';
                //acc.CN_Customer_Group__c = '01';
                acc.CN_Litigation_City__c = 'Dalian大连';
                acc.CN_Category__c = 'BAPA';
                acc.CN_Subcategory__c = 'Access Bakery';
                acc.CN_Province_CN__c = province.Id;
                acc.CN_City_CN__c = city.Id;
                acc.CN_Post_Code__c = '100000';
                acc.CN_Delivery_Plant__c = 'P011';
                acc.CN_Payment_Terms__c = 'D000';
                acc.CN_Invoicing_Name_Bill_To_Party__c = 'D000';
                acc.CN_Tax_Registration_No__c = '10000000';
                acc.CN_Invoice_Type__c = 'General Invoice';
                acc.CN_Invoicing_Address_and_Phone__c = 'ABCDEF';
                acc.CN_Invoicing_Address_and_Phone__c = 'ABCDEF';
                acc.CN_Business_Unit_UI__c = businessUnit.Id;
                acc.CN_Sales_Team_UI__c = salesTeam.Id;
                acc.CN_Visit_Addr_CN__c = 'Visit Address';
                accList.add(acc);
            }
            insert accList;

            system.debug('accList[0].recordTypeId'+ accList[0].recordTypeId);

            List<CN_Document__c> docList = new List<CN_Document__c>();
            for(Account acc : accList){
                CN_Document__c doc_b = new CN_Document__c();
                doc_b.CN_Account__c = acc.Id;
                doc_b.CN_Document_Type__c = Constants.CN_DOCUMENT_TYPE_BUSINESS_LICENSE;
                doc_b.CN_Is_File_Upload__c = true;
                docList.add(doc_b);

                CN_Document__c doc_f = new CN_Document__c();
                doc_f.CN_Account__c = acc.Id;
                doc_f.CN_Document_Type__c = Constants.CN_DOCUMENT_TYPE_FAPIAO_INFORMATION;
                doc_f.CN_Is_File_Upload__c = true;
                docList.add(doc_f);
            }
            insert docList;

            List<Contact> conList = new List<Contact>();
            for(Account acc : accList){
                Contact con = new Contact();
                con.AccountId = acc.Id;
                con.CN_Contact_Type__c = '01;02';
                con.Title = 'CEO';
                con.CN_Department_Of_Contact_Person__c = '0001';
                con.CN_Contact_Name_EN__c = acc.Name + 'Test Contact';
                con.LastName = 'Contact';
                con.MobilePhone = '13013001300';
                con.CN_Bill_To_Address__c = 'ABCDE';
                conList.add(con);
            }
            Database.DMLOptions dml_contact = new Database.DMLOptions();
            dml_contact.DuplicateRuleHeader.allowSave = true;
            dml_contact.DuplicateRuleHeader.runAsCurrentUser = true;
            dml_contact.OptAllOrNone = true;
            Database.SaveResult[] conList_result = Database.insert(conList, dml_contact);

            Set<Id> accIdSet = new Set<Id>();
            for(Account acc : accList){
                accIdSet.add(acc.Id);
            }
            List<CN_Ship_to_Party__c> shipToList = new List<CN_Ship_to_Party__c>();
                for(Account acc : accList) {
                    CN_Ship_to_Party__c shipTo = new CN_Ship_to_Party__c(
                        CN_Sold_To_Party_Customer__c = acc.Id,
                        CN_Customer_Type__c = '0002',
                        CN_Delivery_Address_CN__c = acc.CN_Invoicing_Address_and_Phone__c,
                        CN_Delivery_Plant__c = acc.CN_Delivery_Plant__c,
                        CN_Province_CN__c = acc.CN_Province_CN__c,
                        CN_City_CN__c = acc.CN_City_CN__c,
                        CN_Delivery_Address_EN__c = acc.CN_Invoicing_Address_EN__c
                    );
                shipToList.add(shipTo);
            }
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = true;
            Database.SaveResult[] srList = Database.insert(shipToList, dml);
        }
        return accList;
    }

    public void approveAccount(Account acc){
        List<Account> accList = new List<Account>();
        accList.add(acc);
        approveAccount(accList);
    }

    public void approveAccount(List<Account> accList){
        List<Account> accList_update1 = new List<Account>();
            for(Account acc : accList){
                Account acc_update1 = new Account();
                acc_update1.Id = acc.Id;
                acc_update1.CN_Visit_Addr_CN__c = 'Visit Address Change';
                acc_update1.CN_Account_Status__c = 'Ready for Approval';
                accList_update1.add(acc_update1);
            }
            update accList_update1;

            List<Account> accList_update2 = new List<Account>();
            for(Account acc : accList){
                Account acc_update2 = new Account();
                acc_update2.Id = acc.Id;
                acc_update2.CN_Account_Status__c = 'Submitted for Approval';
                accList_update2.add(acc_update2);
            }
            update accList_update2;

            List<Account> accList_update3 = new List<Account>();
            for(Account acc : accList){
                Account acc_update3 = new Account();
                acc_update3.Id = acc.Id;
                acc_update3.CN_Customer_Code__c = acc.Name;
                acc_update3.CN_Account_Status__c = 'Approved';
                acc_update3.CN_Sync_Status__c = 'Success';
                acc_update3.CN_Approve_Step__c = '';
                accList_update3.add(acc_update3);
            }
            update accList_update3;
    }

    public List<Opportunity> makeOpp(List<Account> accList) {
        List<Opportunity> oppList = new List<Opportunity>();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CN_Opportunity').getRecordTypeId();

        if(accList.size() > 0) {
            for(Account acc: accList) {
                Opportunity opp = new Opportunity(
                    Name = acc.Name,
                    AccountId = acc.Id,
                    RecordTypeId = oppRTId,
                    Amount = 500,
                    CloseDate = Date.Today().addMonths(1),
                    StageName = 'Qualification'
                );
                oppList.add(opp);
            }
        }
        return oppList;
    }

    public Opportunity makeOpp(Account acc) {
        Opportunity opp = new Opportunity();
        List<Account> accList = new List<Account>{acc};
        List<Opportunity> oppList = makeOpp(accList);
        if(oppList.size() > 0) {
            opp = oppList[0];
        }
        return opp;
    }

    public Campaign makeCampaign() {
        Campaign cam = new Campaign();
        Id camRTId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('CN_Campaign').getRecordTypeId();
        cam.RecordTypeId = camRTId;
        cam.Name = 'TestCampaign';
        cam.Status = 'Planned';
        cam.Type = 'Corporate Event';
        cam.StartDate = Date.today().addMonths(3);
        cam.EndDate = Date.today().addMonths(3).addDays(13);
        cam.CN_Execution_Type__c = 'Public Demonstration';
        cam.CN_Channel__c = 'KA';
        cam.CN_Customer_Category__c = 'BAPA';
        cam.CN_Product_Category__c = 'Dairy';
        cam.CN_Product_Type__c = 'CHEESE';
        cam.CN_Brand__c = '5J';
        return cam;
    }
}