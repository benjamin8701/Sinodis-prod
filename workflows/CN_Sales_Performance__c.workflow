<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_Populate_Target_ExternalId</fullName>
        <field>CN_Target_External_Id__c</field>
        <formula>CN_Target_Sales_Person__r.Id &amp; CN_Target_Year__c &amp;  TEXT(CN_Target_Month__c)</formula>
        <name>CN_Populate_Target_ExternalId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_SP_Populate_Target_ExternalId</fullName>
        <actions>
            <name>CN_Populate_Target_ExternalId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c, 
  RecordType.DeveloperName = &apos;CN_Sales_Target&apos;,
  OR(ISNEW(),ISCHANGED(  CN_Target_Sales_Person__c ),ISCHANGED(CN_Target_Year__c),ISCHANGED(CN_Target_Month__c))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
