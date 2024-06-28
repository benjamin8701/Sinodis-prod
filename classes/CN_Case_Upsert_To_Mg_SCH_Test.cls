@IsTest
public class CN_Case_Upsert_To_Mg_SCH_Test {
    @IsTest
	private static void handle() {
		System.schedule('CN_Case_Upsert_To_Mg_SCH', '0 0 * * * ?', new CN_Case_Upsert_To_Mg_SCH());
	}
}