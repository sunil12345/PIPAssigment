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
        								new Question__c( Product_Group__c = lstProductGroup[0].Id, Picklist_Values_Defined__c = 'Test1', Question_Asked__c = 'Testing is going On text?', Question_Type_Picklist__c = 'Text'),
        								new Question__c(Product_Group__c = lstProductGroup[0].Id, Picklist_Values_Defined__c = 'Test2', Question_Asked__c = 'Testing is going On picklist ?', Question_Type_Picklist__c = 'Picklist'),
        								new Question__c(Product_Group__c = lstProductGroup[1].Id, Picklist_Values_Defined__c = 'Test3', Question_Asked__c = 'Testing is going On radio ?', Question_Type_Picklist__c = 'Radio'),
        								new Question__c(Product_Group__c = lstProductGroup[1].Id, Picklist_Values_Defined__c = 'Test4', Question_Asked__c = 'Testing is going On text again?', Question_Type_Picklist__c = 'Text')
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
    	
    	objOpportunity_QA_Class.strAnswerId = lstAnswer[0].Id;
    	
    	objOpportunity_QA_Class.editRecordsOnClick();
    	
    	ApexPages.StandardController sc1 = new ApexPages.standardController(ObjOpportunity);
    	
    	QA_Opportunity_Class objOpportunity_QA_Class1 = new QA_Opportunity_Class(sc1);
        
    	objOpportunity_QA_Class1.isOLIPresent = false;
    	
    	test.stopTest();  
    	
    }
    
    /*
    	Name : test_TBN_WebService
    	Description : test method for webservice
    */
    static testMethod void test_TBN_WebService() {
    	
    	Account objAccount = new Account(Name= 'TestWebService-Demo-Last', AccountNumber= 'AccountNmber', Phone= '112233', Fax ='1212', AccountSource = 'Web');
		insert objAccount;
		
		Contact objContact = new Contact(LastName = 'TestContact-WebService-Demo', Phone='989876', AssistantName= 'Test_Assistant', Email= 'sun@trekbin.com', Department= 'Mechanical', AccountId = objAccount.Id);
		insert objContact;
		
		Case objCase = new Case(AccountId= objAccount.Id, ContactId = objContact.Id, Status = 'New', Origin = 'Phone', Type= 'Mechanical');
		insert objCase;
    	
    	
    	List<Asset> lstAsset_Insert = 	new List<Asset>{
										new Asset(AccountId= objAccount.Id, Name= 'TestAsset1', ContactId= objContact.Id, Status= 'Shipped', Quantity= 2),
										new Asset(AccountId= objAccount.Id, Name= 'TestAsset2', ContactId= objContact.Id, Status= 'Shipped', Quantity= 5)
										};
	
		insert lstAsset_Insert;
		
		List<Entitlement> lstEntitlement_Insert = 	new List<Entitlement>{
													new Entitlement( Name = 'Test-Entitlemnt1', IsPerIncident= false, AssetId= lstAsset_Insert[0].Id, AccountId= objAccount.Id),
													new Entitlement(Name = 'Test-Entitlemnt2', IsPerIncident = false, AssetId= lstAsset_Insert[0].Id, AccountId= objAccount.Id)
													};
		
		insert lstEntitlement_Insert;
		
		List<Case> lstCase =  new List<Case>( 	[	SELECT Id, CaseNumber
													FROM Case
													WHERE Id =: objCase.Id
												]);
		
		system.assertEquals(lstCase.size(), 1);
    	
		TBN_Entitlement_WebService.IVR objIVR = new TBN_Entitlement_WebService.IVR(lstCase[0].CaseNumber, '989876', 'AccountNmber');
		
		TBN_Entitlement_WebService.getCaseRelatedRecords(objIVR);
    	
    	List<Account> lstAccount = new List<Account> ( 	[	SELECT Id, Name, AccountNumber, Phone, Fax, AccountSource
    														FROM Account
    														WHERE AccountNumber =: objIVR.strAccountNumber
    													]);
    													
    	
    	TBN_Entitlement_WebService.accountInfo accountInfo = new TBN_Entitlement_WebService.accountInfo(lstAccount[0].Name, lstAccount[0].AccountNumber, lstAccount[0].Phone, lstAccount[0].Fax, lstAccount[0].AccountSource); 
    	List<TBN_Entitlement_WebService.accountInfo> lstAccountInfo = new List<TBN_Entitlement_WebService.accountInfo>();
    	lstAccountInfo.add(accountInfo); 
    	
    	List<Contact> lstContact = new List<Contact> ( 	[	SELECT Id, Name, Phone, Email, Department, AssistantName
    														FROM Contact
    														WHERE Phone =: objIVR.strPhoneNumber
    													]);
    	
    	TBN_Entitlement_WebService.contactInfo contactInfo = new TBN_Entitlement_WebService.contactInfo(lstContact[0].Name, lstContact[0].Phone, lstContact[0].Email, lstContact[0].Department, lstContact[0].AssistantName );
    	List<TBN_Entitlement_WebService.contactInfo> lstContactInfo = new List<TBN_Entitlement_WebService.contactInfo>();
    	lstContactInfo.add(contactInfo); 
    	
    	
    	List<Asset> lstAsset = new List<Asset> ( 	[	SELECT Id, Name, Quantity, Status, ContactId, AccountId
														FROM Asset
														WHERE AccountId =: lstAccount[0].Id
													]);
    	
    	TBN_Entitlement_WebService.assetInfo assetInfo = new TBN_Entitlement_WebService.assetInfo(lstAsset[0].Name, lstAsset[0].Quantity, lstAsset[0].Status, lstAsset[0].ContactId, lstAsset[0].AccountId);
    	List<TBN_Entitlement_WebService.assetInfo> lstAssetInfo = new List<TBN_Entitlement_WebService.assetInfo>();
    	lstAssetInfo.add(assetInfo);
    	
    	List<Entitlement> lstEntitlement = new List<Entitlement> ( 	[	SELECT Id, Name, IsPerIncident, Status, AssetId, AccountId
																		FROM Entitlement
																		WHERE AccountId =: lstAccount[0].Id
																	]);
													
													
    	TBN_Entitlement_WebService.entitlementInfo entitlementInfo = new TBN_Entitlement_WebService.entitlementInfo(lstEntitlement[0].Name, lstEntitlement[0].Status , lstEntitlement[0].IsPerIncident , lstEntitlement[0].AssetId , lstEntitlement[0].AccountId);
    	List<TBN_Entitlement_WebService.entitlementInfo> lstEntitlementInfo = new List<TBN_Entitlement_WebService.entitlementInfo>();
		lstEntitlementInfo.add(entitlementInfo);
		
		
		TBN_Entitlement_WebService.combineAllRecords_Wrapper objCombineAllWrapper = new TBN_Entitlement_WebService.combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo, '');
		
    	TBN_Entitlement_WebService.IVR objIVRWithoutCaseId =  new TBN_Entitlement_WebService.IVR( null , '989876', '');
    	
    	TBN_Entitlement_WebService.getCaseRelatedRecords(objIVRWithoutCaseId);
    	
    	TBN_Entitlement_WebService.IVR objIVRWithoutPhoneId =  new TBN_Entitlement_WebService.IVR(lstCase[0].CaseNumber, null , '');
    	
    	TBN_Entitlement_WebService.getCaseRelatedRecords(objIVRWithoutPhoneId);
    	
    	TBN_Entitlement_WebService.IVR objIVRWithoutPhoneAndCaseId =  new TBN_Entitlement_WebService.IVR(null, null , '');
    	
    	TBN_Entitlement_WebService.getCaseRelatedRecords(objIVRWithoutPhoneAndCaseId);
    	
    }
}