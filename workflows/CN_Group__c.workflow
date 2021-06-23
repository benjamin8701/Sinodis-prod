<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_Group_Populate_Search_Key</fullName>
        <field>CN_Sales_Team_Code_Name__c</field>
        <formula>CN_Sales_Team__r.CN_Sales_Team_Code__c + &apos; &apos; + CN_Sales_Team__r.Name</formula>
        <name>CN_Group_Populate_Search_Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Group_Populate_Fields</fullName>
        <actions>
            <name>CN_Group_Populate_Search_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() ||  ISCHANGED( CN_Sales_Team__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
