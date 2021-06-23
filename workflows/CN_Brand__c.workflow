<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_Brand_Populate_Fields</fullName>
        <field>CN_Group_Code_Name__c</field>
        <formula>CN_Group__r.CN_Group_Code__c  + &apos; &apos; +  CN_Group__r.Name</formula>
        <name>CN_Brand_Populate_Fields</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_Brand_Populate_Fields</fullName>
        <actions>
            <name>CN_Brand_Populate_Fields</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED( CN_Group__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
