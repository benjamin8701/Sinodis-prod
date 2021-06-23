<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_Sales_Team_Populate_Search_Key</fullName>
        <field>CN_Business_Unit_Code_Name__c</field>
        <formula>CN_Business_Unit__r.CN_Business_Unit_Code__c + &quot; &quot; +  CN_Business_Unit__r.Name</formula>
        <name>CN_Sales_Team_Populate_Search_Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Sales_Team_Populate_Fields</fullName>
        <actions>
            <name>CN_Sales_Team_Populate_Search_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() ||  ISCHANGED( CN_Business_Unit__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
