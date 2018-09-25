/*
 * Copyright (c) 2018, Salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root
 */
 
global class PlatformEventBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private String jobId;
    private String query;
    private Integer batchIndex=0;
    
    public PlatformEventBatch(String inputQuery){
        jobId = createJobId();
        query = inputQuery;
    }
    
    public String getQuery(){
        return query;
    }
    
    public String createJobId(){
        return '' + Math.mod(Math.round(Math.random()*1000), 1000);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Id> ids = new List<Id>();
        for(SObject s : scope){
            ids.add(s.id);
        }    
        String json = JSON.serialize(ids);
        fireEvent(json);
    }
    
    public static void fireEvent(String data) {
        BatchEvent__e batch = new BatchEvent__e(Data__c=data);
        Database.SaveResult sr = publishEvent(batch);
    } 
    
    global void finish(Database.BatchableContext BC){}
    
    @testVisible private static List<BatchEvent__e> eventList = new List<BatchEvent__e>();
    public static Database.SaveResult publishEvent(BatchEvent__e event) {
        eventList.add(event);
        return EventBus.publish(event);
    }
}