/*
 * ************************************************************************************************
 * Name : CN_CampaignMember_Upsert_To_Mg_SCH_Test
 * Description :
 * Object :
 * Requirement :
 * Target :
 * Refer classes :
 * Author : Zhang Zhihao
 * Create Date : 2024/4/2
 * Modify History :
 * ************************************************************************************************
 */
@IsTest
public  class CN_CampaignMember_Upsert_To_Mg_SCH_Test {
    @IsTest
	private static void handle() {
		System.schedule('CN_CampaignMember_Upsert_To_Mg_SCH', '0 0 * * * ?', new CN_CampaignMember_Upsert_To_Mg_SCH());
	}
}