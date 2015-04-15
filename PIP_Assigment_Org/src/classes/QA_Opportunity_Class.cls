public with sharing class QA_Opportunity_Class {

	public String strOpportunityId				{get;set;}
	public String strOpportunityName 			{get;set;}	
	
	public Opportunity objOpportunity			{get;set;}
	
	public Boolean isOLIPresent					{get;set;}
	
	
	public List<QA_OpportunityWrapperClass> lstQA_OpportunityWrapperClass	{get;set;}
	
	public class QA_OpportunityWrapperClass {
		
		public Answer__c objAnswer		{get;set;}
		public Question__c objQuestion  {get;set;}
	
		public QA_OpportunityWrapperClass(Answer__c objAnswer, Question__c objQuestion) {
			
			this.objAnswer = objAnswer;
			this.objQuestion = objQuestion;
			
		}
	}

	public QA_Opportunity_Class(ApexPages.StandardController sc){
		
		lstQA_OpportunityWrapperClass = new List<QA_OpportunityWrapperClass>();
		
		objOpportunity = new Opportunity();
		
		isOLIPresent = true;
		
		strOpportunityId = ApexPages.currentPage().getParameters().get('Idd');
		
		
		Opportunity objOpportunityQuery = [	SELECT Id, Name,Calculate_BlankQuestion__c, Calculate_ProperAnswer__c
											FROM Opportunity
											WHERE Id =: strOpportunityId
											 ];
											 
		strOpportunityName = objOpportunityQuery.Name;
		objOpportunity = objOpportunityQuery;
		
		queryRealtedProduct(strOpportunityId);
	}
	
	
	private void queryRealtedProduct(String strOpportunityId) {
		
		Set<String> setOLI = new Set<String>();
		
		Set<String> setProductGroupId = new Set<String>();
		
		map<String, Question__c> mapQuestionId_Question = new map<String, Question__c>();
		
		for(OpportunityLineItem objOLI : 	[	SELECT Id, Name, Product2Id, OpportunityId
												FROM OpportunityLineItem
												WHERE OpportunityId =: strOpportunityId
											]) {
		
				setOLI.add(objOLI.Product2Id);									
		}
		
		if(setOLI.isEmpty()) {
			
			isOLIPresent= false;
		}
		
		
		for(Product2 objProduct : 	[	SELECT Id, Name, Product_Group__c, isActive
										FROM Product2
										WHERE Id IN:setOLI 
									]){
										
			setProductGroupId.add(objProduct.Product_Group__c);						
		}
		for(Question__c objQuestion: 	[	SELECT Name, Question_Type__c, Question_Asked__c, Product_Group__c, PicklistValues__c, Id 
											FROM Question__c 
											WHERE Product_Group__c IN: setProductGroupId
										]) {
			
			mapQuestionId_Question.put(objQuestion.Id, objQuestion);
											
		}
		
		system.debug('*****mapQuestionId_Question*****'+mapQuestionId_Question);
		
		for(Answer__c objAnswer : 	[	SELECT  Id, Name, Opportunity__c, Question__c, Realated_Products__c, Realated_Products__r.Name, 
												Question__r.Name, Question__r.Question_Asked__c, Answer_Given__c
										FROM  Answer__c
										WHERE Opportunity__c =: strOpportunityId
										AND Question__c IN:mapQuestionId_Question.keyset()
									]) {
										
			lstQA_OpportunityWrapperClass.add(new QA_OpportunityWrapperClass(objAnswer, mapQuestionId_Question.get(objAnswer.Question__c)));
		}
		
		system.debug('****lstQA_OpportunityWrapperClass****'+lstQA_OpportunityWrapperClass);
		
		
	}
}