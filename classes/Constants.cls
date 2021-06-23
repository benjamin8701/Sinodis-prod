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
    
    
	public static final String CN_Account_RT_API_NAME_NEW_DIRECT = 'CN_New_Direct';
	public static final String CN_Account_RT_API_NAME_EDIT_DIRECT = 'CN_Edit_Direct';
	public static final String CN_Account_RT_API_NAME_NEW_INDIRECT = 'CN_New_Indirect';
	public static final String CN_Account_RT_API_NAME_EDIT_INDIRECT = 'CN_Edit_Indirect';
	public static final String CN_Account_RT_API_NAME_APPROVE_DIRECT = 'CN_Approved_Direct';
    
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

}