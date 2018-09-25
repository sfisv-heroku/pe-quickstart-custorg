/*
 * Copyright (c) 2018, Salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root
 */
 
public with sharing class CreateEventController
{

    public String numberOfBatches { get; set; }

    private Integer num;
    
    public CreateEventController() {
        this.numberOfBatches = '1';
    }

    public PageReference createEvent()
    {
        for (Integer i=0; i<Integer.valueOf(numberOfBatches); i++) {
            // Kick off batch job to create BatchEvents
            Id batchJobId = Database.executeBatch(new PlatformEventBatch('select id, title from contact'), 200);
        }
        return null;
    }
    
}