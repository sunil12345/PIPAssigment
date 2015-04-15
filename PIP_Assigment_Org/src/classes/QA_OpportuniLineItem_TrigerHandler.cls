/**
  Name: QA_OpportuniLineItem_TrigerHandler
  Description: Controller for QA_OpportunityLineItem trigger
  Created By: Sunil Pal
  Last Modified By: Sunil Pal
 */


public with sharing class QA_OpportuniLineItem_TrigerHandler {
	
	
	public QA_OpportuniLineItem_TrigerHandler() {
	
	}
	
	
	/**
  	 Name: onAfterInsert
  	 Description: On insert of OpportunityLineItem need to create the answer records
  	 Params: 1. map of new ly insrted OpportunityLineItem
 	*/
 	
 	public void onAfterInsert(map<Id, OpportunityLineItem> mapOpportunityLineItem_New) {
 		
 		createAnswerRecords(mapOpportunityLineItem_New);
 	}
 	
 	
 	/**
  	 Name: onAfterUdapte
  	 Description: On update of OpportunityLineItem need to update the answer records
  	 Params: 1. map of newly insrted OpportunityLineItem
  	 		 2. map of old insrted OpportunityLineItem
 	*/
 	
 	public void onAfterUdapte(map<Id, OpportunityLineItem> mapOpportunityLineItem_New, map<Id, OpportunityLineItem> mapOpportunityLineItem_Old) {
 		
 	}
 	
 	/**
  	 Name: onBeforeDelete
  	 Description:  On delet of OpportunityLineItem need to delete the answer records
  	 Params:  1. map of old insrted OpportunityLineItem
 	*/
 	
 	public void onBeforeDelete(map<Id,OpportunityLineItem> mapOpportunityLineItem_Old) {
 		
 	}
 	
 	private void createAnswerRecords(map<Id, OpportunityLineItem> mapOpportunityLineItem_New) {
 		
 		Set<String> setOLIIProduct2d = new Set<String>();
 		Set<String> setProductId = new Set<String>();
 		
 		Set<String> setProductGroupId = new Set<String>();
 		
 		List<Answer__c> lstAnswerInsert = new List<Answer__c>();
 		
 		Map<String, String> mapAnswerId_OtherValues = new Map<String, String>(); // Used for check the values already present in Answer Object records
 		
 		Map<String, Question__c> mapQuestionId_Question = new Map<String, Question__c>();
 		
 		Map<String, List<String>> mapOpportunity_lstProductsId = new Map<String, List<String>>();
 		
 		Map<String, List<String>> mapQuestion_ProductGroup = new Map<String, List<String>>();
 		
 		Map<String, List<String>> mapProduct_ProductGroup = new Map<String, List<String>>(); // Used for making collection of produxt corresponding to product group
 		
 		Map<String, List<String>> mapProductGroupId_ProductQuestion = new Map<String, List<String>>();
 		
 		
 		for(OpportunityLineItem objOLI : mapOpportunityLineItem_New.values()) {
 			
 			setOLIIProduct2d.add(objOLI.Product2Id);
 			
 			mapOpportunity_lstProductsId.put(objOLI.OpportunityId, new List<String>{objOLI.Product2Id});
 			
 		}
 		
 		for(Product2 objProduct : [	SELECT Id, Name, Product_Group__c, Product_Group__r.Id
 									FROM Product2
 									WHERE Id IN : setOLIIProduct2d
 									]) {
 			
 			setProductGroupId.add(objProduct.Product_Group__c);	
 			setProductId.add(objProduct.Id);	
 			if(mapProduct_ProductGroup.containsKey(objProduct.Product_Group__c)) {
 				
 				mapProduct_ProductGroup.get(objProduct.Product_Group__c).add(objProduct.Id);
 				mapProductGroupId_ProductQuestion.get(objProduct.Product_Group__c).add(objProduct.Id);
 			}
 			else {
 				
 				mapProduct_ProductGroup.put(objProduct.Product_Group__c, new List<String>{objProduct.Id});
 				mapProductGroupId_ProductQuestion.put(objProduct.Product_Group__c, new List<String>{objProduct.Id});	
 			}
 			
		}
		
		for(Question__c objQuestion : [	SELECT Id, Name, Question_Type__c, Question_Asked__c, Product_Group__c, Product_Group__r.Id
										FROM Question__c
										WHERE Product_Group__c In : setProductGroupId
										])  {
			
			mapQuestionId_Question.put(objQuestion.Id, objQuestion);
			
			if(mapProductGroupId_ProductQuestion.containsKey(objQuestion.Product_Group__c)) {
				
				mapProductGroupId_ProductQuestion.get(objQuestion.Product_Group__c).add(objQuestion.Id);
			}
			else {
				
				mapProductGroupId_ProductQuestion.put(objQuestion.Product_Group__c, new List<String>{objQuestion.Id});
				
				mapQuestion_ProductGroup.put(objQuestion.Product_Group__c , new List<String>{objQuestion.Id});	
			}
											
		}
		
		
		for(String strValues : mapProductGroupId_ProductQuestion.keyset()) {
			
			
		}
		
		
		for(List<String> strValues : mapProductGroupId_ProductQuestion.values()) {
			
			
		}
		
		
		for(Answer__c objAnser : [	SELECT Id, Name, Opportunity__c, Question__c, Realated_Products__c
									FROM Answer__c
									WHERE Opportunity__c IN: mapOpportunity_lstProductsId.keyset()
									]) {
		
			mapAnswerId_OtherValues.put(objAnser.Id, objAnser.Opportunity__c+'--'+objAnser.Realated_Products__c+'--'+objAnser.Question__c);								
		}
		
		
		for(Question__c objQuestion : mapQuestionId_Question.values()) {
			
				Answer__c objAnswerInsert = new Answer__c();
				objAnswerInsert.Realated_Products__c = objQuestion.Product_Group__c;
				objAnswerInsert.Name = objQuestion.Name;
				objAnswerInsert.Question__c = objQuestion.Id;
		}
 	}
}