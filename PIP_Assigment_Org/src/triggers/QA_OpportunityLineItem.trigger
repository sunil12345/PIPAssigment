/**
  Name: QA_OpportunityLineItem
  Description: Trigger for inserting, updating and delteing the Answer(Custom object)
  Created By: Sunil Pal
  Last Modified By: Sunil Pal
 */
 

trigger QA_OpportunityLineItem on OpportunityLineItem (after insert, after update, before delete) {

	QA_OpportuniLineItem_TrigerHandler objOLIHandler = new QA_OpportuniLineItem_TrigerHandler();
	
	if(Trigger.isAfter) {
		
		if(trigger.isInsert){
			
			objOLIHandler.onAfterInsert(trigger.newMap);	
		}
		
		if(trigger.isUpdate){
			
			objOLIHandler.onAfterUdapte(trigger.newMap,trigger.oldMap);
		}
	}
	if(Trigger.isBefore) {
		
		if(trigger.isDelete){
			
			objOLIHandler.onBeforeDelete(trigger.oldMap);
		}
	}
	
}