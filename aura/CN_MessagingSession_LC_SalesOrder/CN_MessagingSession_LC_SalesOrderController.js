({
	initAction : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getInitData");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if(state === "SUCCESS") {
                if(returnVal.isSuccess) {
					component.set('v.columns', [
						{ label: 'SKU Description CN', fieldName: 'CN_SKU_Description_CN__c', type: 'text'},
						{ label: 'SKU Code', fieldName: 'CN_Product_Code__c', type: 'text'},
						{ label: 'Quantity', fieldName: 'Total', type: 'number', typeAttributes: { step: '0.01' } }
					]);
					component.set('v.data', returnVal.datas);
                } else {
					component.set('v.isShowError', true);
					component.set('v.ErrorMsg', returnVal.msg);
                }
            } else {
				component.set('v.isShowError', true);
				component.set('v.ErrorMsg', response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})