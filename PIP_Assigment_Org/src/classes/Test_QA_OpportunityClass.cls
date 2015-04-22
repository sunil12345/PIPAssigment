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
@isTest(seeAllData=true)
private class Test_QA_OpportunityClass {

   static testMethod void test_QA_Opportunity_Class() {
    	
    	test.startTest();
    	
        Opportunity ObjOpportunity = new Opportunity( Name= 'Test_Opportunity', CloseDate= Date.Today().addDays(2), StageName = 'Closed Won');
        
        insert ObjOpportunity;
        
        List<Product_Group__c > lstProductGroup = 	new List<Product_Group__c>{
        											new Product_Group__c(Name = 'TestGroup'),
        											new Product_Group__c(Name = 'TestGroup1')
        };
      	insert  lstProductGroup;	
      	
        Product2 testprd1 = new Product2 (Name='Test Product Entry 1', Description='Test Product Entry 1', productCode = 'ABC', isActive = true, Product_Group__c = lstProductGroup[0].Id);
		insert testprd1;
		
		Pricebook2  standardPb = 	[	SELECT Id, Name, isActive 
										FROM Pricebook2 
										WHERE IsStandard = true limit 1
									];
		 
		Product2 testprd2 = new Product2 (Name='Test Product Entry 2', Description='Test Product Entry 2', productCode = 'ABCD', isActive = true, Product_Group__c = lstProductGroup[1].Id);
		insert testprd2;
		
		List<PricebookEntry> lstPriceBookEntries = new List<PricebookEntry>([	SELECT Id, ProductCode 
																				FROM PricebookEntry 
																				WHERE ProductCode <> null 
																				AND isActive = True
																			]);
        
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>{
                                            new OpportunityLineItem(OpportunityId = ObjOpportunity.Id, Quantity = 2, UnitPrice = 150,  PricebookEntryId = lstPriceBookEntries[0].Id)
        };
        insert lstOLIs;
        
        List<Question__c> lstQuestion = new List<Question__c> { 
        								new Question__c(Name='Test_question1', Product_Group__c = lstProductGroup[0].Id, Picklist_Values_Defined__c = 'Test1', Question_Asked__c = 'Testing is going On text?', Question_Type_Picklist__c = 'Text'),
        								new Question__c(Name='Test_question2', Product_Group__c = lstProductGroup[0].Id, Picklist_Values_Defined__c = 'Test2', Question_Asked__c = 'Testing is going On picklist ?', Question_Type_Picklist__c = 'Picklist'),
        								new Question__c(Name='Test_question3', Product_Group__c = lstProductGroup[1].Id, Picklist_Values_Defined__c = 'Test3', Question_Asked__c = 'Testing is going On radio ?', Question_Type_Picklist__c = 'Radio'),
        								new Question__c(Name='Test_question4', Product_Group__c = lstProductGroup[1].Id, Picklist_Values_Defined__c = 'Test4', Question_Asked__c = 'Testing is going On text again?', Question_Type_Picklist__c = 'Text')
        };
        
        insert lstQuestion;
        
        List<Answer__c> lstAnswer_Query = 	[	SELECT Id, Name, Opportunity__c 
			        							FROM Answer__c
			        							WHERE Opportunity__c =: ObjOpportunity.Id
			        						];
		
        system.assertEquals(lstAnswer_Query.size(),2);  // Assert 
        
        delete lstOLIs;
    	
    	List<Answer__c> lstAnswer_Query_Del = 	[	SELECT Id, Name, Opportunity__c 
				        							FROM Answer__c
				        							WHERE Opportunity__c =: ObjOpportunity.Id
			        							];
    	
    	system.assertEquals(lstAnswer_Query_Del.size(), 0); // Assert
    	
    	List<OpportunityLineItem> lstOLIs1 = new List<OpportunityLineItem>{
                                             new OpportunityLineItem(OpportunityId = ObjOpportunity.Id, Quantity = 2, UnitPrice = 150,  PricebookEntryId = lstPriceBookEntries[0].Id)
		};
        insert lstOLIs1;
        
        List<Answer__c> lstAnswer = new List<Answer__c>{
									new Answer__c(Opportunity__c = ObjOpportunity.Id, Question__c = lstQuestion[0].id, Realated_Products__c = testprd1.Id ),
									new Answer__c(Opportunity__c = ObjOpportunity.Id, Question__c = lstQuestion[1].id, Realated_Products__c = testprd2.Id ),
									new Answer__c(Opportunity__c = ObjOpportunity.Id, Question__c = lstQuestion[0].id, Realated_Products__c = testprd1.Id )     							
        }; 
        
        insert lstAnswer;
        
        ApexPages.currentPage().getParameters().put('Idd', ObjOpportunity.Id);
        
        ApexPages.StandardController sc = new ApexPages.standardController(ObjOpportunity);
        QA_Opportunity_Class objOpportunity_QA_Class = new QA_Opportunity_Class(sc);
       	objOpportunity_QA_Class.queryRealtedAnswer();
    	
    	objOpportunity_QA_Class.isOLIPresent = true;
    	
    	List<SelectOption> lstSelectOption = new List<SelectOption>();
    	SelectOption firstOption = new SelectOption('', 'None');
    	lstSelectOption.add(firstOption);
    	
    	QA_Opportunity_Class.QA_OpportunityWrapperClass objWrapperClass = new QA_Opportunity_Class.QA_OpportunityWrapperClass(testprd1.Name, lstAnswer[0], lstQuestion[0], 'Text', true, lstSelectOption);
    	
    	lstSelectOption = new List<SelectOption>();
    	SelectOption firstOptionPicklist = new SelectOption('Test', 'Test');
    	lstSelectOption.add(firstOptionPicklist);
    	
    	QA_Opportunity_Class.QA_OpportunityWrapperClass objWrapperClass1 = new QA_Opportunity_Class.QA_OpportunityWrapperClass(testprd1.Name, lstAnswer[1], lstQuestion[1], 'Picklist', true, lstSelectOption);
    	
    	QA_Opportunity_Class.QA_OpportunityWrapperClass objWrapperClass2 = new QA_Opportunity_Class.QA_OpportunityWrapperClass(testprd2.Name, lstAnswer[1], lstQuestion[2], 'Radio', true, lstSelectOption);
    	
    	QA_Opportunity_Class.QA_OpportunityWrapperClass objWrapperClass3 = new QA_Opportunity_Class.QA_OpportunityWrapperClass(testprd2.Name, lstAnswer[0], lstQuestion[3], 'text', true, lstSelectOption);
    	
    	objOpportunity_QA_Class.saveRecords();
    	
    	
    	List<Answer__c> lstAnswer_Query_Check = 	[	SELECT Id, Name, Opportunity__c, Answer_Given__c 
					        							FROM Answer__c
					        							WHERE Opportunity__c =: ObjOpportunity.Id
					        							AND isAnswerGiven__c = false
			        								];
    	
    	ApexPages.StandardController sc1 = new ApexPages.standardController(ObjOpportunity);
    	
    	QA_Opportunity_Class objOpportunity_QA_Class1 = new QA_Opportunity_Class(sc1);
        
    	objOpportunity_QA_Class1.isOLIPresent = false;
    	
    	test.stopTest();  
    	
    }
}