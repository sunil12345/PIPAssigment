/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class Test_QA_OpportunityClass {

    static testMethod void test_QA_OpportunityHandler_BeforeInsert() {
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        Opportunity ObjOpportunity = new Opportunity( Name= 'Test_Opportunity', CloseDate= date.today(), StageName = 'Closed Won');
        
        lstOpportunity.add(ObjOpportunity);
        
        insert lstOpportunity;
        
        List<Product_Group__c > lstProductGroup = 	new List<Product_Group__c>{
        													new Product_Group__c(Name = 'TestGroup'),
        													new Product_Group__c(Name = 'TestGroup1')
        											};
      	insert  lstProductGroup;											
        
        Product2 newProduct = new Product2(Name = 'test product', family = 'test family', Product_Group__c = lstProductGroup[0].Id);
    	insert newProduct;
        
        PriceBookEntry pbEntry = new PriceBookEntry(
        
	        UnitPrice = 300,
	        PriceBook2Id = [select id from PriceBook2 where isStandard = true].Id,
	        Product2Id = newProduct.Id,
	        IsActive = true
    	);
    	
    	insert pbEntry ;
    	
    	/*PriceBookEntry pbEntry_Next = new PriceBookEntry(
        
	        UnitPrice = 250,
	        PriceBook2Id = [select id from PriceBook2 where isStandard = true].Id,
	        Product2Id = newProduct.Id,
	        IsActive = true
    	);
    	
    	insert pbEntry_Next ;
    	*/
    	
    	List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>{
                                                    new OpportunityLineItem(OpportunityId = lstOpportunity[0].Id, Quantity = 2, UnitPrice = 150,  PricebookEntryId = pbEntry.Id),
                                                    new OpportunityLineItem(OpportunityId = lstOpportunity[0].Id, Quantity = 3, UnitPrice = 200, PricebookEntryId = pbEntry.Id),
                                                    new OpportunityLineItem(OpportunityId = lstOpportunity[0].Id, Quantity = 5, UnitPrice = 1095,  PricebookEntryId = pbEntry.Id)
                                                    };
                                                    
        insert lstOLIs;
        
       /* List<OpportunityLineItem> lstOLI_Duplicta = new List<OpportunityLineItem>{
                                                    new OpportunityLineItem(OpportunityId = lstOpportunity[0].Id, Quantity = 2, UnitPrice = 100,  PricebookEntryId = pbEntry.Id),
                                                    new OpportunityLineItem(OpportunityId = lstOpportunity[0].Id, Quantity = 3, UnitPrice = 200, PricebookEntryId = pbEntry_Next.Id),
                                                    new OpportunityLineItem(OpportunityId = lstOpportunity[1].Id, Quantity = 5, UnitPrice = 1090,  PricebookEntryId = pbEntry_Next.Id)};
                                                    
        insert lstOLI_Duplicta;
        */
        
        
        List<Question__c> lstQuestion = new List<Question__c>{
        										new Question__c(Name='Test_Question1', Question_Type__c = 'Text',Product_Group__c = lstProductGroup[0].Id, Question_Asked__c = 'Testing' ),
        										new Question__c(Name='Test_Question1', Question_Type__c = 'Text',Product_Group__c = lstProductGroup[1].Id, Question_Asked__c = 'Testing 456' )
        										};	
		insert lstQuestion;
    }
}