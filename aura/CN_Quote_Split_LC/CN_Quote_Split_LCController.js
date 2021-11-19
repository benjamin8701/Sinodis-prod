({
	closeModal:function(component,event,helper){        
        $A.get("e.force:closeQuickAction").fire();
    },
    confirmSplit:function(component,event,helper){
          
        helper.split(component,event,helper);             
    },
})