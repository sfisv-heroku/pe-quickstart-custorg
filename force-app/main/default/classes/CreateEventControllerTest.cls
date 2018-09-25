@isTest
public class CreateEventControllerTest {

    static testMethod void testController() {

        Test.StartTest(); 
    
        // Set the page to the VF page
        PageReference pageRef = Page.CreateTestEvent;
        Test.setCurrentPage(pageRef);
        
        // Instantiate a new controller, in this case, no parameters required
        CreateEventController controller = new CreateEventController();
        
        controller.createEvent();
        
        Test.StopTest();
    }
}