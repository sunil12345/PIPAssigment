/**
  Name: QA_OpportunityLineItem
  Description: Trigger for inserting, updating and delteing the Answer(Custom object)
  Created By: Sunil Pal
  Last Modified By: Sunil Pal
 */
 
 
trigger QA_OpportunityLineItem on OpportunityLineItem (after insert, before delete, before insert) {

	QA_OpportuniLineItem_TrigerHandler objOLIHandler = new QA_OpportuniLineItem_TrigerHandler();
	
	if(Trigger.isAfter) {
		
		if(trigger.isInsert){
			
			objOLIHandler.onAfterInsert(trigger.newMap);	
		}
	}
	if(Trigger.isBefore) {
		
		if(trigger.isInsert) {
			
			objOLIHandler.onBeforeInsert(trigger.new);
		}
		if(trigger.isDelete){
			
			objOLIHandler.onBeforeDelete(trigger.oldMap);
		}
	}
	
}