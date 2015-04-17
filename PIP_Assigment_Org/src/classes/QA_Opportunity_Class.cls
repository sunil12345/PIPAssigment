/**
  Name: QA_Opportunity_Class
  Description: Page for displaying the Q&A on page 
  Created By: Sunil Pal
  Last Modified By: Sunil Pal
 */
 
 public with sharing class QA_Opportunity_Class {

	public String strOpportunityId				{get;set;}	// For stroing the OpportunityId of the page
	public String strOpportunityName 			{get;set;}	// For Storing the Opportunity Name which is used for showing on page
	 
	public Opportunity objOpportunity			{get;set;}  // Used for displaying the Opprtunity Rollup fileds on page
	
	public Boolean isOLIPresent					{get;set;}	// Used for checking the if any OLI is available for this opportunity 
	
	public map<String, List<QA_OpportunityWrapperClass>> mapProductName_Wrapper 		{get;set;} // Used for getting the product name with associated Questions and answers
	
	public List<SelectOption> lstSelectOPtion			{get;set;}	// USed for dispalying the all the picklist value stored in question object
	
	/**
	  Name: QA_OpportunityWrapperClass
	  Description: Wrapper clas for combining and displaying the Answer, Object and their associated values in page side
	 */
 
	public class QA_OpportunityWrapperClass {
		
		public String strProductName	{get;set;} 
		public Answer__c objAnswer		{get;set;}
		public Question__c objQuestion  {get;set;}
		public String strType			{get;set;}
		public Boolean isAnswerd		{get;set;}
		
	
		public QA_OpportunityWrapperClass(String strProductName, Answer__c objAnswer, Question__c objQuestion, String strType, Boolean isAnswerd) {
			
			this.strProductName = strProductName;
			this.objAnswer = objAnswer;
			this.objQuestion = objQuestion;
			this.strType = strType;
			this.isAnswerd = isAnswerd;
		}
	}

	//Constructor
	public QA_Opportunity_Class(ApexPages.StandardController sc){
		
		objOpportunity = new Opportunity();
		
		lstSelectOPtion = new List<SelectOption>();
		
		isOLIPresent = true;
		
		strOpportunityId = ApexPages.currentPage().getParameters().get('Idd');
		
		Opportunity objOpportunityQuery = 	[	SELECT Id, Name,Calculate_BlankQuestion__c, Calculate_ProperAnswer__c
												FROM Opportunity
												WHERE Id =: strOpportunityId
											 ];
											 
		strOpportunityName = objOpportunityQuery.Name;
		
		objOpportunity = objOpportunityQuery;
		
		queryRealtedProduct(strOpportunityId);
		
		getPickListValues();
	}
	
	/*
		Name : queryRealtedProduct
		Type:  private
		Description: Fetching the required values from corresponding objects
		Param: 1- OpportunityId
		
	
	*/
	private void queryRealtedProduct(String strOpportunityId) {
		
		mapProductName_Wrapper  = new Map<String, List<QA_OpportunityWrapperClass>>();
		
		Set<String> setOLI = new Set<String>();		// Storing the product id under the OLI
		
		Set<String> setProductGroupId = new Set<String>(); // Storing the Product Group id present under the product
		
		Map<String, Question__c> mapQuestionId_Question = new Map<String, Question__c>();
		
		Map<String, Product2> mapProductId_Product = new Map<String, Product2>();
		
		String strObject_Type = '';
		
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
			
			mapProductId_Product.put(objProduct.Id, objProduct)	;
									
			setProductGroupId.add(objProduct.Product_Group__c);						
		}
		
		for(Question__c objQuestion: 	[	SELECT Name, Question_Type__c, Question_Asked__c, Product_Group__c, PicklistValues__c, Id 
											FROM Question__c 
											WHERE Product_Group__c IN: setProductGroupId
										]) {
			
			mapQuestionId_Question.put(objQuestion.Id, objQuestion);
											
		}
		
		for(Answer__c objAnswer : 	[	SELECT  Id, Name, Opportunity__c, Question__c, Realated_Products__c, Realated_Products__r.Name, 
												Question__r.Name, Question__r.Question_Asked__c, Answer_Given__c, Question__r.PicklistValues__c,
												Question__r.Question_Type__c
										FROM  Answer__c
										WHERE Opportunity__c =: strOpportunityId
										AND Question__c IN:mapQuestionId_Question.keyset()
									]) {
										
			if(mapProductId_Product.containskey(objAnswer.Realated_Products__c)){
				
				if(mapProductName_Wrapper.containsKey(objAnswer.Realated_Products__r.Name)) {
					
					List<QA_OpportunityWrapperClass> lstOfQA_On_OpportunityWrapper = mapProductName_Wrapper.get(objAnswer.Realated_Products__r.Name);
				
	      			lstOfQA_On_OpportunityWrapper.add(new QA_OpportunityWrapperClass(objAnswer.Realated_Products__r.Name ,objAnswer,mapQuestionId_Question.get(objAnswer.Question__c), objAnswer.Question__r.Question_Type__c, false));
	      			
	      			mapProductName_Wrapper.put(objAnswer.Realated_Products__r.Name, lstOfQA_On_OpportunityWrapper);
	      			
				}
				else {
				
					QA_OpportunityWrapperClass objNewWrapper = new QA_OpportunityWrapperClass(objAnswer.Realated_Products__r.Name, objAnswer, mapQuestionId_Question.get(objAnswer.Question__c), objAnswer.Question__r.Question_Type__c, false);
					mapProductName_Wrapper.put(objAnswer.Realated_Products__r.Name, new List<QA_OpportunityWrapperClass>{objNewWrapper});
					
				}
			}
		}
		
	}
	
	/*
		Name : getPickListValues
		Type:  private
		Description: Fetching the picklist values from QuestionObject
	*/
	
	private void getPickListValues() {
		
  		Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Question__c');//From the Object Api name retrieving the SObject
  		
    	Sobject Object_name = targetType.newSObject();
    	
  		Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
  		
    	Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
    	
    	Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
    	
    	List<Schema.PicklistEntry> pick_list_values = field_map.get('PicklistValues__c').getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
    	
    	
    	SelectOption firstOption = new SelectOption('', ' - Select Options' + ' -');
    	
    	lstSelectOPtion.add(firstOption);
    	
    	for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
    		
      		lstSelectOPtion.add(new SelectOption(a.getValue(),a.getValue()));
      		
   		}
	}
	
	
	public void saveRecords() {
		
		List<Answer__c> lstAnswer = new List<Answer__c>();	// List used to update the answer records on click of save
		
		for(List<QA_OpportunityWrapperClass> strQuestionValues : mapProductName_Wrapper.values()) {
			
			for(QA_OpportunityWrapperClass lstWrapper : strQuestionValues) {
				
				if(lstWrapper.objAnswer.Answer_Given__c != null && lstWrapper.objAnswer.Answer_Given__c != '') {
					
					system.debug('****lstWrapper.objAnswer.Answer_Given__c*inside***'+lstWrapper.objAnswer.Answer_Given__c);
					
					lstWrapper.objAnswer.isAnswerGiven__c = true;
				}
				
				lstAnswer.add(lstWrapper.objAnswer);
				
				system.debug('****lstAnswer****'+lstAnswer);
			}
		}
		
		update lstAnswer;
	}
	
}