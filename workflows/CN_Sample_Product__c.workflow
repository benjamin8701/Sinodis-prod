<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_SP_Populate_Current_Status_Date</fullName>
        <field>CN_Current_Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>CN_SP_Populate_Current_Status_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SP_Populate_Feedback_Date</fullName>
        <field>CN_Feedback_Date__c</field>
        <formula>TODAY()</formula>
        <name>CN_SP_Populate_Feedback_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SP_Populate_Sample_Cost</fullName>
        <field>CN_Sample_Cost__c</field>
        <formula>CN_Sample_Unit_List_Price__c  *  CN_Quantity_Needed__c</formula>
        <name>CN_SP_Populate_Sample_Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_SampleProduct_Set_ExternalID</fullName>
        <field>CN_External_ID__c</field>
        <formula>CN_Sample_Request__r.Id &amp;&apos;-&apos;&amp; CN_Product__r.Id</formula>
        <name>CN_SampleProduct_Set_ExternalID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_SP_Populate_Current_Status_Date</fullName>
        <actions>
            <name>CN_SP_Populate_Current_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c, ISBLANK( CN_Current_Status_Date__c), NOT(ISBLANK(TEXT(CN_Current_Status__c))), OR(ISNEW(), ISCHANGED(CN_Current_Status__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_SP_Populate_Feedback_Date</fullName>
        <actions>
            <name>CN_SP_Populate_Feedback_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c, ISBLANK( CN_Feedback_Date__c), NOT(ISBLANK(TEXT(CN_Customer_Feedback__c))), OR(ISNEW(), ISCHANGED(CN_Customer_Feedback__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_SP_Populate_Sample_Cost</fullName>
        <actions>
            <name>CN_SP_Populate_Sample_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c, 
CN_Sample_Request__r.RecordType.DeveloperName  = &apos;CN_Office_Repack&apos;,
OR(
   ISNEW(),
   ISCHANGED(CN_Product__c), 
   ISCHANGED(CN_Quantity_Needed__c)
)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CN_SampleProduct_Set_ExternalID</fullName>
        <actions>
            <name>CN_SampleProduct_Set_ExternalID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.Trigger_Switcher_Setting__c.EnableFlow__c , RecordType.DeveloperName = &apos;CN_Sample_Product&apos;,
ISCHANGED( CN_Product__c) || ISCHANGED( CN_Sample_Request__c) || ISNEW()
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
