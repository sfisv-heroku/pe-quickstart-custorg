/*
 * Copyright (c) 2018, Salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root
 */
 
// Create some events, for testing.
Id batchJobId = Database.executeBatch(new PlatformEventBatch('select id, title from contact'), 60);