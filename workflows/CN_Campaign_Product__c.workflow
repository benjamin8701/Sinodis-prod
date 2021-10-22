<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_CampaignProduct_Populate_External_ID</fullName>
        <field>CN_External_ID__c</field>
        <formula>CN_Campaign__r.Id &amp; &apos;-&apos; &amp;  CN_Product__r.Id</formula>
        <name>CN_CampaignProduct_Populate_External_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_CampaignProduct_Populate_External_ID</fullName>
        <actions>
            <name>CN_CampaignProduct_Populate_External_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  $Setup.Trigger_Switcher_Setting__c.EnableFlow__c , 
  ISCHANGED( CN_Product__c) || ISCHANGED( CN_Campaign__c) || ISNEW()
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
