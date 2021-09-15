({	
    doInit : function(component, event, helper) {        
        helper.getPicklistValues(component, event);
        let title1 = $A.get("{!$Label.c.CN_Generate_Opportunity_Title1}");
        component.set("v.title1", title1);
        let title2 = $A.get("{!$Label.c.CN_Generate_Opportunity_Title2}");
        component.set("v.title2", title2);

        component.set("v.isBtnDisabled", false);

    },   
    
    save : function(component, event, helper) {
        helper.saveOpp(component, event);
    },
    cancel : function(component, helper, event)
    {
        //Below line of code will close the modal popup
        $A.get("e.force:closeQuickAction").fire();   
    },
    //handle StageName Picklist Selection
    handleOnChange : function(component, event, helper) {
        var stage = component.get("v.opportunity.StageName");
    }
})