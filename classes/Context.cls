public without sharing class Context {
    public static Map<Id,UserRole> allRoles = new Map<Id,UserRole>([Select ID, Name, DeveloperName From UserRole limit 50000]);
    
    public static Boolean ApplyTo(List<String> nCodes) {
    	if(nCodes == null || nCodes.size() == 0) {
    		return false;
    	}
		ID roleId = UserInfo.getUserRoleId();
		if(roleId == null) {
			return true;
		}
		UserRole role = allRoles.get(roleId);
		for(String nCode : nCodes) {
			if(nCode == 'ALL') {
				return true;
			}
			if(role.DeveloperName.startsWith(nCode)) {
				return true;
			}
		}
		return false;
    }
    public static Boolean ApplyTo(String nCode) {
		return ApplyTo(new String[] {nCode});
    }  
}