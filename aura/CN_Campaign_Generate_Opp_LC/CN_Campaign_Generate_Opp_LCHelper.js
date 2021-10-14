({
    
    getPicklistValues: function(component, event) {
        var action = component.get("c.getStageFieldValue");
        var campId = component.get("v.recordId");
        action.setParams({
            campaignId : campId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                var result = returnValue["options"];
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap", fieldMap);

                let isChefCreateVIP = returnValue["isChefCreateVIP"];
                if(isChefCreateVIP) {
                    component.set("v.opportunity.CloseDate", returnValue["endDate"]);
                }
            }
        });
        $A.enqueueAction(action);
    },

    callServerAction : function(component, action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                let _state = response.getState();
                if (_state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    let errors = response.getError();
                    let message = "Error";
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = JSON.stringify(errors);
                    }
                    reject(new Error(message));
                }
            });
            $A.enqueueAction(action);
        });
    },
     
    
    saveOpp : function(component, event) {
        var opportunity = component.get("v.opportunity");
        var campId = component.get("v.recordId");
        console.log("campId====: " + JSON.stringify(campId));
        console.log("campId====: " + JSON.stringify(opportunity));
        var action = component.get("c.generateOpp");
        action.setParams({
            oppObj : opportunity,
            campId : campId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(2);
            console.log(state);
            if(state === "SUCCESS"){
                var successMeg = $A.get("{!$Label.c.CN_Generate_Opportunity_Success}");
                alert(successMeg);
                $A.get("e.force:closeQuickAction").fire();
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });       
        console.log(1);
        $A.enqueueAction(action);
    }
})