public without sharing class Constants {
    public static final String CN_Code = 'CN';
    // Account trigger switch
    public static Boolean ACCOUNT_TRIGGER_ON = true;
    public static Boolean CN_ACCOUNT_TRIGGER_ON = true;
    public static Boolean CN_ACCOUNT_GENERATE_CONTACT_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_ACCOUNT_GENERATE_SHIPTO_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_ACCOUNT_SYNC_SALESPERSON_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_ACCOUNT_POPULATE_APPROVER_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_ACCOUNT_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_ACCOUNT_APPROVE_AGING_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_ACCOUNT_GENERATE_DOCUMENTS_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_ACCOUNT_ADDRESS_CHANGE_HANDLER_TRIGGER_ON = true;
    //CR05 - Tm report by Shuqi - start
    public static Boolean CN_ACCOUNT_TM_REPORT_HANDLER_TRIGGER_ON = true;
    //CR05 - Tm report by Shuqi - end   
	public static Boolean CN_ACCOUNT_PREVENT_EDIT_APPROVED_HANDLER_TRIGGER_ON = true;
	
    
    public static final String CN_Account_RT_API_NAME_NEW_DIRECT = 'CN_New_Direct';
    public static final String CN_Account_RT_API_NAME_EDIT_DIRECT = 'CN_Edit_Direct';
    public static final String CN_Account_RT_API_NAME_NEW_INDIRECT = 'CN_New_Indirect';
    public static final String CN_Account_RT_API_NAME_EDIT_INDIRECT = 'CN_Edit_Indirect';
    public static final String CN_Account_RT_API_NAME_APPROVE_DIRECT = 'CN_Approved_Direct';
    public static final String CN_Account_RT_API_NAME_NEW_Prospect = 'CN_New_Prospect';
    public static final String CN_Account_RT_API_NAME_EDIT_Prospect = 'CN_Edit_Prospect';     
  public static final String CN_ACCOUNT_ACCOUNT_STATUS_SUBMITTED_FOR_APPROVAL = 'Submitted for Approval';
    public static final String CN_ACCOUNT_ACCOUNT_STATUS_READY_FOR_APPROVAL = 'Ready for Approval';
    public static final String CN_ACCOUNT_ACCOUNT_STATUS_APPROVED = 'Approved';
    
    public static final String CN_ACCOUNT_NATURE_REGULAR_CUSTOMER = 'Regular Customer';
    public static final String CN_ACCOUNT_NATURE_TM1 = 'TM1 (Hotel-3month rule)';
    public static final String CN_ACCOUNT_NATURE_TM2 = 'TM2 (BAPA-3month rule)';

    public static final String CN_ACCOUNT_SALESOFFICE_VALUE_K010 = 'K010';
    public static final String CN_ACCOUNT_SALESOFFICE_VALUE_K020 = 'K020';
    public static final String CN_ACCOUNT_SALESOFFICE_VALUE_K030 = 'K030';
    public static final String CN_ACCOUNT_SALESOFFICE_VALUE_K040 = 'K040';
    public static final String CN_ACCOUNT_SALESOFFICE_VALUE_K050 = 'K050';
    public static final String CN_ACCOUNT_SALESOFFICE_VALUE_K060 = 'K060';

    public static final String CN_ACCOUNT_SYNC_STATUS_SUCCESS = 'Success';
    
    public static final String CN_ACCOUNT_SALESTEAM_CODE_WS = '900014';


    // ContentDocumentLink
    public static Boolean CDL_TRIGGER_ON = true;
    public static Boolean CN_CDL_TRIGGER_ON = true;
    public static Boolean CN_CDL_POPULATE_UPLOADED_HANDLER_TRIGGER_ON = true;

    // ContentDocument
    public static Boolean CD_TRIGGER_ON = true;
    public static Boolean CN_CD_TRIGGER_ON = true;
    public static Boolean CN_CD_POPULATE_UPLOADED_HANDLER_TRIGGER_ON = true;
    
    // User
    public static final String CN_USER_TITLE_SALES_REP = 'Sales Rep';
    public static final String CN_USER_TITLE_MANAGER = 'Manager';
    public static final String CN_USER_TITLE_ARM = 'Assistant Regional Manager';
    public static final String CN_USER_TITLE_RM = 'Regional Manager';
    public static final String CN_USER_TITLE_CM = 'Channel Manager';
    public static final String CN_USER_TITLE_CD = 'Commerical Director';
    public static final String CN_USER_TITLE_CFO = 'CFO';
    public static final String CN_USER_TITLE_CEO = 'CEO';

    // Contact trigger switch
    public static Boolean CONTACT_TRIGGER_ON = true;
    public static Boolean CN_CONTACT_TRIGGER_ON = true;
    public static Boolean CN_CONTACT_POPULATE_FIELD_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CONTACT_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CONTACT_UPDATE_FINAREMAIL_HANDLER_TRIGGER_ON = true;
    // Added By Jessica Wang 2021-07-22 Start
	public static Boolean CN_CONTACT_WRITE_BACK_TO_LEAD_HANDLER_TRIGGER_ON = true;
	// Added By Jessica Wang 2021-07-22 End
	public static Boolean CN_CONTACT_TYPE_CHECK_HANDLER_TRIGGER_ON = true;
    public static final String CN_CONTACT_RT_API_NAME = 'CN_Contact';
    public static final String CN_CONTACT_TYPE_FINANCE_VALUE_NAME = '01';
    public static final String CN_CONTACT_TYPE_PURCHASE_VALUE_NAME = '02';

    public static final String CN_CONTACT_ACCOUNT_SYNC_STATUS_SUCCESS = 'Success';
    //Ship To Party trigger switch
    public static Boolean SHIPTO_TRIGGER_ON = true;
    public static Boolean CN_SHIPTO_TRIGGER_ON = true;
    public static Boolean CN_SHIPTO_PREVENT_DELETE_HANDLER_ON = true;
    
    public static final String CN_SHIPTO_RT_API_NAME = 'CN_Ship_to_Party';

    public static final String CN_SHIPTO_ACCOUNT_SYNC_STATUS_SUCCESS = 'Success';

    //Credit Term Application trigger switch
    public static Boolean CTA_TRIGGER_ON = true;
    public static Boolean CN_CTA_TRIGGER_ON = true;
    public static Boolean CN_CTA_POPULATE_FIELDS_HANDLER_ON = true;
    public static Boolean CN_CTA_POPULATE_APPROVER_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CTA_APPROVE_AGING_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CTA_GENERATE_CR_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CTA_PREVENT_DUPLICATE_CR_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CTA_POPULATE_FINANCEMDM_HANDLER_TRIGGER_ON = true;

    public static final String CN_CTA_RT_API_NAME = 'CN_Credit_Term_Application';
    
    public static final String CN_CTA_STATUS_NEW = 'New';
    public static final String CN_CTA_STATUS_READY_FOR_APPROVAL = 'Ready for Approval';
    public static final String CN_CTA_STATUS_SUBMITTED_FOR_APPROVAL = 'Submitted for Approval';
    public static final String CN_CTA_STATUS_APPROVALED = 'Approved';
    public static final String CN_CTA_STATUS_CANCEL = 'Cancel';

    public static final String CN_CTA_NATURE_OF_REQUEST_REGULAR = 'Regular Customer';
    public static final String CN_CTA_NATURE_OF_REQUEST_TM1 = 'TM1 (Hotel-3month rule)';
    public static final String CN_CTA_NATURE_OF_REQUEST_TM2 = 'TM2 (BAPA-3month rule)';
    public static final String CN_CTA_NATURE_OF_REQUEST_NOC = 'NO CONTRACT';    
    
    // Change Request Trigger Switch
    public static Boolean CR_TRIGGER_ON = true;
    public static Boolean CN_CR_TRIGGER_ON = true;
    public static Boolean CN_CR_POPULATE_APPROVER_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_CHANGE_RECORDTYPE_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_APPROVE_AGING_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_WRITE_BACK_TO_SHIPTO_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_WRITE_BACK_TO_CONTACT_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_GENERATE_CONTACT_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_PREVENT_DUPLICATE_ONGOING_CR_TRIGGER_ON = true;
    public static Boolean CN_CR_CHECK_AT_LEAST_ONE_FIELD_CHANGED_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_GENERATE_SHIPTO_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_UPDATE_SYNC_STATUS_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_WRITE_BACK_TO_ACCOUNT_HANDLER_TRIGGER_ON = true;
    public static Boolean CN_CR_CHECK_FIELDS_HANDLER_TRIGGER_ON = true;

    public static final String CN_CR_RT_API_NAME_UPDATE_ACCOUNT = 'CN_Update_Account_Request';
    public static final String CN_CR_RT_API_NAME_UPDATE_CONTACT = 'CN_Update_Contact_Request';
    public static final String CN_CR_RT_API_NAME_UPDATE_SHIPTO = 'CN_Update_Ship_To_Request';
    public static final String CN_CR_RT_API_NAME_NEW_CONTACT = 'CN_New_Contact_Request';
    public static final String CN_CR_RT_API_NAME_NEW_SHIPTO = 'CN_New_Ship_To_Request';
    public static final String CN_CR_RT_API_NAME_APPD_UPDATE_ACCOUNT = 'CN_Approved_Update_Account_Request';
    public static final String CN_CR_RT_API_NAME_APPD_UPDATE_CONTACT = 'CN_Approved_Update_Contact_Request';
    public static final String CN_CR_RT_API_NAME_APPD_UPDATE_SHIPTO = 'CN_Approved_Update_Ship_To_Request';
    public static final String CN_CR_RT_API_NAME_APPD_NEW_CONTACT = 'CN_Approved_New_Contact_Request';
    public static final String CN_CR_RT_API_NAME_NEW_APPD_SHIPTO = 'CN_Approved_New_Ship_To_Request';
    //hotfix realse7 ----by shuqi start
    public static final String CN_CR_RT_API_NAME_Mass_UPDATE_ACCOUNT_OWNER = 'CN_MASS_Change_Account_Owner';
    public static final String CN_CR_RT_API_NAME_Mass_UPDATE_ACCOUNT_FINANCE_AR = 'CN_Mass_Change_Account_Finance_AR';
    //hotfix realse7 ----by shuqi end

    public static final String CN_CR_STATUS_READY_FOR_APPROVAL = 'Ready for Approval';
    public static final String CN_CR_STATUS_SUBMITTED_FOR_APPROVAL = 'Submitted for Approval';
    public static final String CN_CR_STATUS_APPROVALED = 'Approved';
    public static final String CN_CR_SYNC_STATUS_NO_NEED_TO_SYNC = 'No Need To Sync';
    public static final String CN_CR_STATUS_CANCEL = 'Cancel';

    public static final String CN_CR_STATUS_APPROVED = 'Approved';

    public static final String CN_CR_SYNC_STATUS_SENT = 'Sent';
    public static final String CN_CR_SYNC_STATUS_PROCESSING = 'Processing';
    public static final String CN_CR_SYNC_STATUS_SUCCESS = 'Success';
    public static final String CN_CR_SYNC_STATUS_FAIL = 'Fail';

    // Sales Order
    public static final String CN_SO_SYNC_STATUS_SENT = 'Sent';
    public static final String CN_SO_SYNC_STATUS_PROCESSING = 'Processing';
    public static final String CN_SO_SYNC_STATUS_SUCCESS = 'S';
    public static final String CN_SO_SYNC_STATUS_FAIL = 'E';

    //Business Hours
    public static final String CN_BUSINESS_HOURS_NAME = 'CN_BusinessHour';  
    

    //Document
    public static final String CN_DOCUMENT_TYPE_BUSINESS_LICENSE = 'Business License';  
    public static final String CN_DOCUMENT_TYPE_FAPIAO_INFORMATION = 'Fapiao Information';  
    public static final String CN_DOCUMENT_TYPE_HYGIENE_CERTIFICATE = 'Hygiene Certificate';    
    public static final String CN_DOCUMENT_TYPE_CONTRACT = 'Contract';  


    //Business Unit
    public static Boolean BU_TRIGGER_ON = true;
    public static Boolean CN_BU_TRIGGER_ON = true;
    public static Boolean CN_BUSINESSUNIT_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;

    public static final String CN_BU_RT_API_NAME = 'CN_Business_Unit';

    public static final String CN_BU_SYNC_STATUS_FAIL = 'Fail';
    public static final String CN_BU_SYNC_STATUS_SUCCESS = 'Success';


    //Sales Team
    public static Boolean ST_TRIGGER_ON = true;
    public static Boolean CN_ST_TRIGGER_ON = true;
    public static Boolean CN_SALESTEAM_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;

    public static final String CN_ST_RT_API_NAME = 'CN_Sales_Team';

    public static final String CN_ST_SYNC_STATUS_FAIL = 'Fail';
    public static final String CN_ST_SYNC_STATUS_SUCCESS = 'Success';

    //Group
    public static Boolean GR_TRIGGER_ON = true;
    public static Boolean CN_GR_TRIGGER_ON = true;
    public static Boolean CN_GROUP_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;

    public static final String CN_GROUP_RT_API_NAME = 'CN_Group';

    public static final String CN_GROUP_SYNC_STATUS_FAIL = 'Fail';
    public static final String CN_GROUP_SYNC_STATUS_SUCCESS = 'Success';

    //Brand
    public static Boolean BR_TRIGGER_ON = true;
    public static Boolean CN_BR_TRIGGER_ON = true;
    public static Boolean CN_BRAND_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;
    
    public static final String CN_BRAND_RT_API_NAME = 'CN_Brand';

    public static final String CN_BRAND_SYNC_STATUS_FAIL = 'Fail';
    public static final String CN_BRAND_SYNC_STATUS_SUCCESS = 'Success';

	// Added By Jessica Wang 2021-07-21 Release2 Start
	//Lead
	public static Boolean LEAD_TRIGGER_ON = true;
	public static Boolean CN_LEAD_TRIGGER_ON = true;
	public static Boolean CN_LEAD_OWNER_CHANGED_CUSTOM_NOTIFICATION_TRIGGER_ON = true;
	public static Boolean CN_LEAD_MKT_ASSIGNED_HANDLER_TRIGGER_ON = true;
	
	
	public static final String CN_LEAD_RT_API_NAME = 'CN_Lead';

	public static final String CN_LEAD_STATUS_CLOSED_CONVERTED = 'Closed - Converted';
	public static final String CN_LEAD_STATUS_SALES_QUALIFIED = 'Sales Qualified';
	public static final String CN_LEAD_STATUS_MKT_QUALIFIED = 'MKT Qualified';

	public static final String CN_Custom_Notification_API_NAME = 'CN_Sinodis_Notification';
	// Added By Jessica Wang 2021-07-21 Release2 End
	// Added By Kealsalas 2021-07-27 Release2 Start
	public static Boolean CHEF_REQUEST_TRIGGER_ON = true;
	public static Boolean CN_CHEF_REQUEST_TRIGGER_ON = true;
	public static Boolean CN_CHEF_REQUEST_ASSIGN_APPROVER_TRIGGER_ON = true;
	public static Boolean CN_CHEF_REQUEST_SHARING_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_CHEF_REQUEST_SET_ACCOUNT_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_CHEF_REQUEST_EVENT_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_CHEF_REQUEST_CHEF_ASSIGN_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_CHEF_REQUEST_PEVENT_DELETE_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_CHEF_REQUEST_AUTO_CONFIRM_HANDLER_TRIGGER_ON = true;
	public static final String CN_CHEF_REQUEST_1ON1_NEW_RT_API_NAME = 'CN_1on1_Service_Chef_Request_New';
	public static final String CN_CHEF_REQUEST_1ON1_RT_API_NAME = 'CN_1on1_Service_Chef_Request';
	public static final String CN_CHEF_REQUEST_CHEF_SELF_RT_API_NAME = 'CN_Chef_Self_Work_Request';
	public static final String CN_CHEF_REQUEST_CHEF_DEMO_RT_API_NAME = 'CN_Marketing_CCE_Chef_Demo_Request';
	public static final String CN_CHEF_REQUEST_MKT_DEV_RT_API_NAME = 'CN_Marketing_Development_Request';

	public static final String CN_CHEF_REQUEST_STATUS_READY_FOR_APPROVAL = 'Ready for Approval';
	public static final String CN_CHEF_REQUEST_STATUS_SUBMITTED_FOR_APPROVAL = 'Submitted for Approval';
	public static final String CN_CHEF_REQUEST_STATUS_APPROVALED = 'Approved';
	public static final String CN_CHEF_REQUEST_STATUS_REJECTED = 'Rejected';
	public static final String CN_CHEF_REQUEST_STATUS_NEW = 'New';

	public static Boolean CHEFS_ASSIGNED_TRIGGER_ON = true;
	public static Boolean CN_CHEFS_ASSIGNED_TRIGGER_ON = true;
	public static Boolean CN_CHEFS_ASSIGNED_SHARING_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_CHEFS_ASSIGNED_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_CHEFS_ASSIGNED_RESET_WORKDATE_HANDLER_TRIGGER_ON = true;
	public static final String CN_CHEFS_ASSIGNED_RT_API_NAME = 'CN_Chef_Assigned';

	public static final String CN_EVENT_RT_API_NAME = 'CN_Event';

	public static Boolean DEMO_USED_PRODUCT_TRIGGER_ON = true;
	public static Boolean CN_DEMO_USED_PRODUCT_TRIGGER_ON = true;
	public static Boolean CN_DEMO_USED_PRODUCT_ACCUMULATE_HANDLER_TRIGGER_ON = true;

	public static Boolean DEMO_REPORT_TRIGGER_ON = true;
	public static Boolean CN_DEMO_REPORT_TRIGGER_ON = true;
	public static Boolean CN_DEMO_REPORT_COPY_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_DEMO_REPORT_PREVENT_DELETE_TRIGGER_ON = true;

	public static final String CN_CHEF_REQUEST_RT_NAME_1ON1 = 'CN_1on1_Service_Chef_Request';
	public static final String CN_CHEF_REQUEST_RT_NAME_SELF_WORK = 'CN_Chef_Self_Work_Request';
	public static final String CN_CHEF_REQUEST_RT_NAME_MKT_DEMO = 'CN_Marketing_CCE_Chef_Demo_Request';
	public static final String CN_CHEF_REQUEST_RT_NAME_MKT_DEV = 'CN_Marketing_Development_Request';

	public static Boolean PROMOTION_TRIGGER_ON = true;
	public static Boolean CN_PROMOTION_TRIGGER_ON = true;
	public static Boolean CN_PROMOTION_PREVENT_DELETE_TRIGGER_ON = true;
	public static Boolean CN_PROMOTION_VALIDATION_TRIGGER_ON = true;
	public static final String CN_PROMOTION_STATUS_PLANNED = 'Planned';

	public static Boolean PROMOTION_LINE_ITEM_TRIGGER_ON = true;
	public static Boolean CN_PROMOTION_LINE_ITEM_TRIGGER_ON = true;
	public static Boolean CN_PROMOTION_LINE_ITEM_PREVENT_DELETE_TRIGGER_ON = true;

	public static Boolean PROMOTION_MEMBER_TRIGGER_ON = true;
	public static Boolean CN_PROMOTION_MEMBER_TRIGGER_ON = true;
	public static Boolean CN_PROMOTION_MEMBER_PREVENT_DELETE_TRIGGER_ON = true;
	public static Boolean CN_PROMOTION_MEMBER_SET_ACCOUNT_OWNER_TRIGGER_ON = true;
	// Added By Kealsalas 2021-07-27 Release2 End
	// Added By Jessica Wang 2021-07-28 Release2 Start
	//Sample Request
	public static Boolean SAMPLE_REQUEST_TRIGGER_ON = true;
	public static Boolean CN_SAMPLE_REQUEST_TRIGGER_ON = true;
	public static Boolean CN_SR_POPULATE_FIELDS_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_SR_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;
	
	public static final String CN_SR_OFFICE_REPACK_RT_API_NAME = 'CN_Office_Repack';
	public static final String CN_SR_WHOLE_PACK_RT_API_NAME = 'CN_Whole_Pack';
	public static final String CN_SR_STATUS_APPROVED = 'Approved';
	public static final String CN_SR_STATUS_READY = 'Ready for Approval';
	public static final String CN_SR_STATUS_SUBMIT = 'Submitted for Approval';
	public static final String CN_SR_STATUS_CANCELED = 'Canceled';
	public static final String CN_SALES_TEAM_NAME_KA = 'KA';
	public static final String CN_SALES_TEAM_NAME_DS = 'DS';
	public static final String CN_SALES_TEAM_NAME_WS = 'WS';
	public static final String CN_SR_SHARING_ROWCAUSE_EDIT = 'Edit';
	public static final String CN_SR_SHARING_ACCESSLEVEL_MANUAL = 'Manual';

    // Sample Product
	public static final String CN_SP_RT_API_NAME = 'CN_Sample_Product';
	public static Boolean SAMPLE_PRODUCT_TRIGGER_ON = true;
	public static Boolean CN_SAMPLE_PRODUCT_TRIGGER_ON = true;
	public static Boolean CN_SP_POPULATE_FIELDS_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_SP_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;

	//Campaign Member
	public static final String CN_CM_STATUS_ATTENDED = 'Attended';
	public static final String CN_CM_TYPE_ACCOUNT = 'Account';
	public static final String CN_CM_TYPE_CONTACT = 'Contact';
	public static final String CN_CM_TYPE_LEAD = 'Lead';


	//User Sales Team
	public static final String CN_SALES_TEAM1 = '900012';
	public static final String CN_SALES_TEAM2 = '900013';
	public static final String CN_SALES_TEAM3 = '900014';

	//Event
	public static final String CN_VISIT_RT_API_NAME = 'CN_Visit';
	public static Boolean CN_SR_GENERATE_EVENT_VISIT_HANDLER_TRIGGER_ON = true;

	//Event
	public static final String CN_TASK_RT_API_NAME = 'CN_Task';

	//Promotion
	public static final String CN_PROMOTION_STATUS_READY = 'Ready';
	public static final String CN_PROMOTION_STATUS_PUBLISHED = 'Published';

	public static final String CN_PROMOTION_SHARING_ROWCAUSE_READ = 'Read';
	public static final String CN_PROMOTION_SHARING_ACCESSLEVEL_MANUAL = 'Manual';

	//Promotion Member
	public static Boolean CN_PROMOTION_MEMBER_PUBLISHED_TRUE = true;
	public static Boolean CN_PROMOTION_MEMBER_PUBLISHED_FALSE = false;
	// Added By Jessica Wang 2021-07-28 Release2 End

	// Added By Dezheng Du 2021-08-03 Release2 Start
	//Quote
	public static Boolean QU_TRIGGER_ON = true;
	public static Boolean CN_QU_TRIGGER_ON = true;
	public static Boolean CN_QUOTE_POPULATE_FIELDS_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_QUOTE_POPULATE_APPROVER_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_QUOTE_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_QUOTE_APPROVAL_REMINDER_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_QUOTE_GENERATE_QUOTE_PROMOTION_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_QUOTE_READY_VALIDATION_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_QUOTE_PROMOTION_LINK_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_QUOTE_SHARING_HANDLER_TRIGGER_ON = true;

	public static Integer CN_QUOTE_APPROVAL_REMINDER_HOURS = 8;
	public static String CN_SHARING_REASON_MANUAL = 'Manual';

	public static final String CN_QUOTE_RT_API_NAME_NEW = 'CN_Quote_New';
	public static final String CN_QUOTE_RT_API_NAME = 'CN_Quote';
	public static final Integer CN_QUOTE_APPROVAL_LENGTH = 12;
	public static final String CN_QUOTE_STATUS_NEW = 'New';
	public static final String CN_QUOTE_STATUS_SUBMITTED = 'Submitted for Approval';
	public static final String CN_QUOTE_STATUS_READY = 'Ready for Approval';
	public static final String CN_QUOTE_STATUS_APPROVED = 'Approved';
	public static final String CN_QUOTE_STATUS_REJECTED = 'Rejected';
	public static final String CN_QUOTE_STATUS_ACCEPTED = 'Accepted';
	public static final String CN_QUOTE_STATUS_DENIED = 'Denied';

	public static final String CN_QUOTE_SYNC_STATUS_FAIL = 'Fail';
	public static final String CN_QUOTE_SYNC_STATUS_SUCCESS = 'Success';

	//QuoteItem
	public static Boolean QI_TRIGGER_ON = true;
	public static Boolean CN_QI_TRIGGER_ON = true;
	public static Boolean CN_QUOTEITEM_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_QUOTEITEM_POPULATE_FIELDS_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_QUOTEITEM_VALIDATION_HANDLER_TRIGGER_ON = true;
	
	public static final String CN_QUOTEITEM_ACCEPTANCE_ACCEPTED = 'Accepted';
	public static final String CN_QUOTEITEM_ACCEPTANCE_DENIED = 'Denied';
	public static final String CN_QUOTEITEM_APPROVAL_STATUS_REJECT = 'Reject';
	public static final String CN_QUOTEITEM_APPROVAL_STATUS_APPROVED = 'Approved';

	//PriceBook
	public static Boolean PB_TRIGGER_ON = true;
	public static Boolean CN_PB_TRIGGER_ON = true;
	public static Boolean CN_PB_POPULATE_FIELDS_HANDLER_TRIGGER_ON = true;

	public static final String CN_PB_RT_API_NAME = 'CN_Price_Book';

	//Quote To Promotion
	public static Boolean QTP_TRIGGER_ON = true;
	public static Boolean CN_QTP_TRIGGER_ON = true;
	public static Boolean CN_QTP_PREVENT_CHANGE_APPROVED_HANDLER_TRIGGER_ON = true;

	public static final String CN_QTP_RT_API_NAME_NEW = 'CN_Quote_To_Promotion';
	
	//Case
	public static Boolean CA_TRIGGER_ON = true;
	public static Boolean CN_CA_TRIGGER_ON = true;
	public static Boolean CN_CA_CREATOR_TO_OWNER_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_CA_PREVENT_DELETE_TRIGGER_ON = true;
	public static Boolean CN_CA_SHARE_HANDLER_TRIGGER_ON = true;

	public static final String CN_CA_RT_API_NAME_COMPLAINT = 'CN_Complaint';
	public static final String CN_CA_STATUS_NEW = 'New';
	public static final String CN_CA_STATUS_REJECTED = 'Rejected';
	public static final String CN_CA_STATUS_RESOLVED = 'Resolved';
	public static final String CN_CA_STATUS_ASSIGNED = 'Assigned';
    public static final String CN_CA_STATUS_ACCEPTED = 'Accepted';
	public static final String CN_CA_STATUS_CLOSED = 'Closed';
	public static final String CN_CA_STATUS_CANCELED = 'Canceled';

	//Profile
	public static final String CN_PROFILE_NAME_CS = 'CN C/S';
	public static final String CN_PROFILE_NAME_QA = 'CN QA';
	public static final String CN_PROFILE_NAME_CCE = 'CN CCE';
	public static final String CN_PROFILE_NAME_CCERM = 'CN CCE Reassign Manager';
	public static final String CN_PROFILE_NAME_CCESM = 'CN CCE Sample Manager';
	public static final String CN_PROFILE_NAME_MKT = 'CN Marketing';
	public static final String CN_PROFILE_NAME_MKTBO = 'CN MKT Brand Owner';
	public static final String CN_PROFILE_NAME_MKTLM = 'CN MKT Lead Manager';
	public static final String CN_PROFILE_NAME_MKTRM = 'CN MKT Reassign Manager';
	public static final String CN_PROFILE_NAME_SALESLEADER = 'CN Sales Lead';
	public static final String CN_PROFILE_NAME_ADMIN = 'System Administrator';
	public static final String CN_PROFILE_NAME_INTEGRATION = 'System Integration';

	//Permission Set / Custom Permission
	public static final String CN_CUSTOMPERMISSION_MRM = 'CN_Marketing_Reassign_Manager';

	// Contract
	public static Boolean CONTRACT_TRIGGER_ON = true;
	public static Boolean CN_CONTRACT_TRIGGER_ON = true;
	public static Boolean CN_CONTRACT_POPULATE_FIELDS_HANDLER_TRIGGER_ON = true;

	public static final String CN_CONTRACT_RT_API_NAME_NEW = 'CN_Contract';

	// Opportunity
	public static Boolean OP_TRIGGER_ON = true;
	public static Boolean CN_OP_TRIGGER_ON = true;
	public static Boolean CN_OP_POPULATE_FIELDS_HANDLER_TRIGGER_ON = true;

	public static final String CN_OP_RT_API_NAME_NEW = 'CN_Opportunity';

	// Event
	public static Boolean EV_TRIGGER_ON = true;
	public static Boolean CN_EV_TRIGGER_ON = true;
	public static Boolean CN_EV_GENERATE_FOLLOW_VISIT_HANDLER_TRIGGER_ON = true;
	public static Boolean CN_EV_PREVENT_DELETE_HANDLER_TRIGGER_ON = true;

	public static final String CN_EV_RT_API_NAME_NEW = 'CN_Visit';
	public static final String CN_EV_RT_API_NAME_EVENT = 'CN_Event';

	public static final String CN_EV_By_WHEN_ONE = 'One week after';
	public static final String CN_EV_By_WHEN_TWO = 'Two weeks after';
	public static final String CN_EV_By_WHEN_THREE = 'Three weeks after';

	public static final String CN_EV_VISIT_STATUS_PLANNED = 'Planned';
	public static final String CN_EV_TIME_BEFORE_EVENT_PLANNED = '1 day';

	// Sales Performance
	public static Boolean SALESPERFOR_TRIGGER_ON = true;
	public static Boolean CN_SALESPERFOR_TRIGGER_ON = true;
	public static Boolean CN_SALESPERFOR_POPULATE_PRODUCT_HANDLER_ON = true;

	public static final String CN_SP_RT_API_NAME_PERFORMANCE = 'CN_Sales_Performance';
	public static final String CN_SP_RT_API_NAME_TARGET = 'CN_Sales_Target';


	// Added By Dezheng Du 2021-08-03 Release2 End

	
	
}