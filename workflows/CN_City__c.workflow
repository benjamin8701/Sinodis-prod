<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CN_City_Populate_Fields_CN</fullName>
        <field>CN_Province_Name_CN__c</field>
        <formula>CN_Province__r.CN_Province_CN__c</formula>
        <name>CN_City_Populate_Fields_CN</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CN_City_Populate_Fields_EN</fullName>
        <field>CN_Province_Name_EN__c</field>
        <formula>CN_Province__r.CN_Province_EN__c</formula>
        <name>CN_City_Populate_Fields_EN</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CN_City_Populate_Fields</fullName>
        <actions>
            <name>CN_City_Populate_Fields_CN</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CN_City_Populate_Fields_EN</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED(  CN_Province__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
