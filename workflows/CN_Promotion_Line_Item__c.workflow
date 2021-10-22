<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_PromotionLineItem_Set_ExternalID</fullName>
        <field>CN_External_ID__c</field>
        <formula>CN_Promotion__c + &quot;-&quot; +  CN_Product__c</formula>
        <name>CN_PromotionLineItem_Set_ExternalID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_PromotionLineItem_Set_ExternalID</fullName>
        <actions>
            <name>CN_PromotionLineItem_Set_ExternalID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c , RecordType.DeveloperName = &apos;CN_Promotion_Line_Item&apos;,
 ISCHANGED(CN_Promotion__c  ) ||  ISCHANGED(CN_Product__c  ) || ISNEW()
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
