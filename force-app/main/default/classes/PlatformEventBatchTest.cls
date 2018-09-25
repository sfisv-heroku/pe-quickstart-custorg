@isTest
public class PlatformEventBatchTest {

    static testMethod void testPlatformEventBatch() {

        Test.StartTest(); 
        
        Account account = new Account();
        account.name = 'test user';
        insert(account);
        
        String query = 'select name from account limit 1';
        PlatformEventBatch peEventBatch = new PlatformEventBatch(query);

        // Verify 
        System.assert(query.equals(peEventBatch.getQuery()));
        
        Id batchJobId = Database.executeBatch(peEventBatch);
        System.assertNotEquals(null, batchJobId, 'The execution of the batch returned a null id.');
        
        Test.StopTest();
        System.assertEquals( 1, PlatformEventBatch.eventList.size(), 'There should be one element in the list' );
    }
}