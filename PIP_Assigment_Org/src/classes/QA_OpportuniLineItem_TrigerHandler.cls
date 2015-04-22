/**
  Name: QA_OpportuniLineItem_TrigerHandler
  Description: Controller for QA_OpportunityLineItem trigger
  Created By: Sunil Pal
  Last Modified By: Sunil Pal
 */


public with sharing class QA_OpportuniLineItem_TrigerHandler {
	
	
	public QA_OpportuniLineItem_TrigerHandler() {
		
		// Do Nothing
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
  	 Name: onBeforeInsert
  	 Description: On insert of OpportunityLineItem need to check the duplicate values
  	 Params: 1. list of newly insrted OpportunityLineItem
 	*/
 	
 	public void onBeforeInsert(List<OpportunityLineItem> lstOpportunityLineItem){
 		
 		Map<String, Set<String>> mapOpportunityId_setProducts = new Map<String, Set<String>>();	// Used for keeping the set of product id under one opportunity
 		
 		Map<String, OpportunityLineItem> mapProductId_OLI = new Map<String, OpportunityLineItem>();	// Used for storing the OLI associated with product
 		
 		// Iterating over the newly inserted OLI for getting the productId, opportunity Id
 		for(OpportunityLineItem objOLI: lstOpportunityLineItem) {
 			
 			mapProductId_OLI.put(objOLI.Product2Id, objOLI);
 			
 			if(mapOpportunityId_setProducts.containsKey(objOLI.OpportunityId)) {
 				
 				mapOpportunityId_setProducts.get(objOLI.OpportunityId).add(objOLI.Product2Id);
 			}
 			else {
 				
 				mapOpportunityId_setProducts.put(objOLI.OpportunityId, new Set<String>{objOLI.Product2Id});
 			}
 			
 		}
 		
 		// Iterarting over the OLI for getting the alreday stored OLI and check whether the same OLI is present in the newly inserted OLI
 		for(OpportunityLineItem oLI : 	[	SELECT Id, Name, Product2Id, OpportunityId
 											FROM OpportunityLineItem
 											WHERE OpportunityId IN : mapOpportunityId_setProducts.keySet()
 										]) {
		
			Set<String> setProductId = new Set<String>();
			
			setProductId.addAll(mapOpportunityId_setProducts.get(oLI.OpportunityId));
			
			if(setProductId.contains(oLI.Product2Id)) {
				
				OpportunityLineItem OLIERROR = mapProductId_OLI.get(oLI.Product2Id);
				
				OLIERROR.addError('This Product Alreday Exist Under This Opportunity');
			}
		}
 	}
 	
 	/**
  	 Name: onBeforeDelete
  	 Description:  On delet of OpportunityLineItem need to delete the answer records
  	 Params:  1. map of old insrted OpportunityLineItem
 	*/
 	
 	public void onBeforeDelete(map<Id,OpportunityLineItem> mapOpportunityLineItem_Old) {
 			
 			deleteAnswersRecords(mapOpportunityLineItem_Old);
 	}
 	
 	/**
  	 Name: deleteAnswersRecords
  	 Description:  For deleting the Answers records associated with that OLI
  	 Params:  1. map of old insrted OpportunityLineItem
 	*/
 	
 	private void deleteAnswersRecords(map<Id,OpportunityLineItem> mapOpportunityLineItem_Old) {
 		
 		Map<String, Set<String>> mapOpportunityId_setProducts = new Map<String, Set<String>>();		//Used for keeping the set of product id under one opportunity
 		Map<String, OpportunityLineItem> mapProductId_OPPLI = new Map<String, OpportunityLineItem>();	// Used for storing the OLI associated with product
 		
 		List<Answer__c> lstAnswerDelete = new List<Answer__c>();	// Used for deleting the answer records as their asscociated OLI is deleted
 		
 		for(OpportunityLineItem OPPLI : mapOpportunityLineItem_Old.values()) {
 			
 			mapProductId_OPPLI.put(OPPLI.Product2Id, OPPLI);
 			
 			if(mapOpportunityId_setProducts.containsKey(OPPLI.OpportunityId)) {
 				
 				mapOpportunityId_setProducts.get(OPPLI.OpportunityId).add(OPPLI.Product2Id);
 			}
 			else {
 				
 				mapOpportunityId_setProducts.put(OPPLI.OpportunityId, new Set<String>{OPPLI.Product2Id});
 			}
 			
 		}
 		
 		for(Answer__c objAnswer : 	[	SELECT Id, Name, Realated_Products__c, Opportunity__c
 										FROM Answer__c
 										WHERE Realated_Products__c IN : mapProductId_OPPLI.keySet()
 										AND Opportunity__c IN : mapOpportunityId_setProducts.keySet()
 									]) {
 										
 			Set<String> setProductId = new Set<String>();
			
			setProductId.addAll(mapOpportunityId_setProducts.get(objAnswer.Opportunity__c));
			
			if(setProductId.contains(objAnswer.Realated_Products__c)) {
				
				lstAnswerDelete.add(objAnswer);		
			}							
 		}
 		
 		delete lstAnswerDelete;
 	}
 	
 	
 	/**
  	 Name: createAnswerRecords
  	 Description:  For creating the Answers reords without filling the answers value it will be cartession product type (OP1- P1,P2- PG1, Q1,Q2)
  	 			1* 2*1*2 = 4
  	 Params:  1. map of new insrted OpportunityLineItem
 	*/
 	private void createAnswerRecords(map<Id, OpportunityLineItem> mapOpportunityLineItem_New) {
 		
 		List<Answer__c> lstAnswerInsert = new List<Answer__c>();
 		
		Map<String, String> mapProductId_GroupId = new Map<String, String>();
		
		Map<String, List<String>> mapGroupId_Question =  new Map<String, List<String>>();
		
		Map<String, List<String>> mapProductId_LstQuestion =  new Map<String, List<String>>(); 
		
		Map<String, Map<String, List<String>>> mapOpportunityId_Product_Question = new Map<String, Map<String, List<String>>>();		
 		
 		Map<String, List<String>> mapOppId_OppProduct = new Map<String, List<String>>();
 		
 		set<String> setProductId = new Set<String>();
 		
 		set<String> setProductGroupId = new Set<String>();
 		
 		Map<String, Answer__c> mapQuest_Answer = new Map<String, Answer__c>();
 		
 		for(OpportunityLineItem objOLI : mapOpportunityLineItem_New.values()) {
 			
 			
 			if(mapOppId_OppProduct.containsKey(objOLI.OpportunityId)) {
 			
 				mapOppId_OppProduct.get(objOLI.OpportunityId).add(objOLI.Product2Id);
 			}
 			else {
 				
 				mapOppId_OppProduct.put(objOLI.OpportunityId, new List<String> {objOLI.Product2Id});
 			}	
 			
 			setProductId.add(objOLI.Product2Id);
 		}
 		
 		for(Product2 objProduct : 	[	SELECT Id, Name, Product_Group__c 
 										FROM Product2
 										WHERE Id IN : setProductId
 										AND Product_Group__c <> null
 									]) {
 			
 			mapProductId_GroupId.put(objProduct.Id, objProduct.Product_Group__c);
 			
 			setProductGroupId.add(objProduct.Product_Group__c);
		}
		
		for(Question__c objQuestion : 	[	SELECT Id, Name, Product_Group__c
											FROM Question__c
											WHERE Product_Group__c IN: setProductGroupId
										]){
			
			if(mapGroupId_Question.containsKey(objQuestion.Product_Group__c)) {
				
				mapGroupId_Question.get(objQuestion.Product_Group__c).add(objQuestion.Id);
			}
			
			else {	
										
				mapGroupId_Question.put(objQuestion.Product_Group__c , new List<String>{objQuestion.Id});
			}	
		}
		
		for(String strProductId : mapProductId_GroupId.keySet()) {
			
			String groupId = mapProductId_GroupId.get(strProductId);
			
			List<String> lstQuestionId = mapGroupId_Question.get(groupId);
			
			mapProductId_LstQuestion.put(strProductId,lstQuestionId);
			
			for(String strOpportunityIdFetch : mapOppId_OppProduct.keySet()) {
				
				mapOpportunityId_Product_Question.put(strOpportunityIdFetch, new Map<String, List<String>>(mapProductId_LstQuestion));
				
			}
		}
		
		for(String strOpportunityId_Get :  mapOpportunityId_Product_Question.keyset()) {
				
			for(String strProductId : mapProductId_LstQuestion.keySet()) {
				
				List<String> lstQuestin =  mapProductId_LstQuestion.get(strProductId);
				
				if(!lstQuestin.isEmpty()) {
					
					for(String strQuestion : lstQuestin) {
					
						Answer__c objAnswerInsert = new Answer__c();
						
						objAnswerInsert.Realated_Products__c = strProductId;
						objAnswerInsert.Question__c = strQuestion;
						objAnswerInsert.Opportunity__c = strOpportunityId_Get;
						
						lstAnswerInsert.add(objAnswerInsert);
					}
				}
			}		
		}
		
		Database.SaveResult[] srList = Database.insert(lstAnswerInsert, false);	
		
	}
}