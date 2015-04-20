/**
  Name: QA_Opportunity_Class
  Description: Page for displaying the Q&A on page 
  Created By: Sunil Pal
  Last Modified By: Sunil Pal
 */
 
 public with sharing class QA_Opportunity_Class {

    public Opportunity objOpportunity           {get;set;}  // Used for displaying the Opprtunity Rollup fileds on page
    
    public Boolean isOLIPresent                 {get;set;}  // Used for checking the if any OLI is available for this opportunity 
    
    public Boolean hasError                 {get;set;}  // Used for checking the if any OLI is available for this opportunity
    
    public String strGetStatus						{get;set;}
    
    public map<String, List<QA_OpportunityWrapperClass>> mapProductName_Wrapper         {get;set;} // Used for getting the product name with associated Questions and answers
    
    public Integer intSumTotalQuestion		{get;set;}
    
    public List<SelectOption> lstSelectOPtion           {get;set;}  // USed for dispalying the all the picklist value stored in question object
    
    private String strOpportunityId ;
    
    private Map<String, Question__c> mapQuestionId_Question = new Map<String, Question__c>();
    private Map<String, Product2> mapProductId_Product = new Map<String, Product2>();
    /**
      Name: QA_OpportunityWrapperClass
      Description: Wrapper clas for combining and displaying the Answer, Object and their associated values in page side
     */
 
    public class QA_OpportunityWrapperClass {
        
        public String strProductName    {get;set;} 
        public Answer__c objAnswer      {get;set;}
        public Question__c objQuestion  {get;set;}
        public String strType           {get;set;}
        public Boolean isAnswerd        {get;set;}
        public List<SelectOption> lstSlectOption_Display    {get;set;}  
        public String strSelectedValue                      {get;set;}
            
        public QA_OpportunityWrapperClass(String strProductName, Answer__c objAnswer, Question__c objQuestion, String strType, Boolean isAnswerd, List<SelectOption> lstSlectOption_Display, String strSelectedValue) {
            
            this.strProductName = strProductName;
            this.objAnswer = objAnswer;
            this.objQuestion = objQuestion;
            this.strType = strType;
            this.isAnswerd = isAnswerd;
            this.lstSlectOption_Display = lstSlectOption_Display;
            this.strSelectedValue = strSelectedValue;
        }
    }

    //Constructor
    public QA_Opportunity_Class(ApexPages.StandardController sc){
        
        objOpportunity = new Opportunity();
        
        strOpportunityId = '';
        strGetStatus = 'ALL';
        
        lstSelectOPtion = new List<SelectOption>();
        
        isOLIPresent = hasError = true;
        
        intSumTotalQuestion = 0;
        
        if(!ApexPages.currentPage().getParameters().containsKey('Idd')) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'URL Parameter (Idd) is missing'));
        }
        else {
        	
        	strOpportunityId = ApexPages.currentPage().getParameters().get('Idd');
        	
        	if(strOpportunityId == '') {
        		
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Url is not valid. No value present for Idd'));
        	}
        	else {
    		
	        	List<Opportunity> lstOpportunityQuery =     new List<Opportunity> ([    SELECT Id, Name, Calculate_BlankQuestion__c, Calculate_ProperAnswer__c
	         	                                                                        FROM Opportunity
	          	                                                                        WHERE Id =: strOpportunityId
	           	                                         							]);
	    		
	    		if(lstOpportunityQuery.isEmpty()) {
	    			
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Opportuninty Id is not correct. Please use correct Id'));
	    		}
	    		else {
	    			
	    			hasError = false;
	    			
	    			intSumTotalQuestion = Integer.valueOf(lstOpportunityQuery[0].Calculate_BlankQuestion__c) + integer.valueOf(lstOpportunityQuery[0].Calculate_ProperAnswer__c);
	    			objOpportunity = lstOpportunityQuery[0];
	    
	        		queryRealtedAnswer();
	    		}
        	}
    	} 
    }
    
    /*
        Name : queryRealtedProduct
        Type:  public
        Description: Fetching the required values from corresponding objects
    */
    public void queryRealtedAnswer() {
        
        try{
            
            mapProductName_Wrapper  = new Map<String, List<QA_OpportunityWrapperClass>>();
            mapProductId_Product = new Map<String, Product2>();
            mapQuestionId_Question = new Map<String, Question__c>();
            
            Set<String> setProductIds = new Set<String>();     // Storing the product id under the OLI
            Set<String> setProductGroupId = new Set<String>(); // Storing the Product Group id present under the product
            Set<String> setQuestionId = new Set<String>();
            
            String strObject_Type = '';
            
            for(OpportunityLineItem objOLI :    [   SELECT Id, Name, Product2Id, OpportunityId
                                                    FROM OpportunityLineItem
                                                    WHERE OpportunityId =: strOpportunityId
                                                ]) {
            
                setProductIds.add(objOLI.Product2Id);                                  
            }
            
            if(setProductIds.isEmpty()) {
                
                isOLIPresent= false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No Opportunity Line Item records are present!!!!!'));
            }
            
            for(Product2 objProduct :   [   SELECT Id, Name, Product_Group__c, isActive
                                            FROM Product2
                                            WHERE Id IN:setProductIds 
                                        ]){
                
                mapProductId_Product.put(objProduct.Id, objProduct) ;
                                        
                setProductGroupId.add(objProduct.Product_Group__c);                     
            }
            
            for(Question__c objQuestion:    [   SELECT Name, Question_Type__c, Question_Asked__c, Product_Group__c, PicklistValues__c, Id, Picklist_Values_Defined__c
                                                FROM Question__c 
                                                WHERE Product_Group__c IN: setProductGroupId
                                            ]) {
                
                mapQuestionId_Question.put(objQuestion.Id, objQuestion);
                                                
            }
            
            setQuestionId.addAll(mapQuestionId_Question.keyset());
            
            String strQuery = 'SELECT  Id, Name, Opportunity__c, Question__c, Realated_Products__c, Realated_Products__r.Name, '+ 
                              'Question__r.Name, Question__r.Question_Asked__c, Answer_Given__c, Question__r.PicklistValues__c, '+
                              'Question__r.Question_Type__c, Question__r.Picklist_Values_Defined__c '+
                              'FROM  Answer__c '+
                              'WHERE Opportunity__c =: strOpportunityId '+
                              'AND Question__c IN : setQuestionId';    
                              
            if(strGetStatus == 'ANSWER') {
            	
            	strQuery += ' AND isAnswerGiven__c = true'; 
            }
            else if(strGetStatus == 'PENDING') {
            	
            	strQuery += ' AND isAnswerGiven__c = false'; 
            }     
            
            for(Answer__c objAnswer :   Database.query(strQuery)) {
                
                List<SelectOption> lstSelectOPtion_AddValues = new List<SelectOption>();        
                                    
                if(mapProductId_Product.containskey(objAnswer.Realated_Products__c)){
                    
                    if(mapProductName_Wrapper.containsKey(objAnswer.Realated_Products__r.Name)) {
                        
                        List<QA_OpportunityWrapperClass> lstOfQA_On_OpportunityWrapper = mapProductName_Wrapper.get(objAnswer.Realated_Products__r.Name);
                        
                        if(objAnswer.Question__r.Question_Type__c == 'Picklist' || objAnswer.Question__r.Question_Type__c == 'picklist') {
                            
                            String strNewValues = objAnswer.Question__r.Picklist_Values_Defined__c;
                            
                            if(strNewValues != null && strNewValues != '') {
                                
                                List<String> lstString_OPtionValues = new List<String>();
                                
                                lstString_OPtionValues.addAll(strNewValues.split('\n'));
                                
                                for(String strOPtionValues : lstString_OPtionValues) {
                                    
                                    lstSelectOPtion_AddValues.add(new SelectOption(strOPtionValues,strOPtionValues));
                                }
                            }
                        }
                        else {
                            
                            lstSelectOPtion_AddValues.add(new SelectOption('None', 'None'));
                        }
                        
                        lstOfQA_On_OpportunityWrapper.add(new QA_OpportunityWrapperClass(objAnswer.Realated_Products__r.Name ,objAnswer,mapQuestionId_Question.get(objAnswer.Question__c), objAnswer.Question__r.Question_Type__c, false, lstSelectOPtion_AddValues, ''));
                        
                        mapProductName_Wrapper.put(objAnswer.Realated_Products__r.Name, lstOfQA_On_OpportunityWrapper);
                        
                    }
                    else {
                        
                        if(objAnswer.Question__r.Question_Type__c == 'Picklist' || objAnswer.Question__r.Question_Type__c == 'picklist') {
                            
                            String strNewValues = objAnswer.Question__r.Picklist_Values_Defined__c;
                            
                            if(strNewValues != null && strNewValues != '') {
                                
                                List<String> lstString_OPtionValues = new List<String>();
                                
                                lstString_OPtionValues.addAll(strNewValues.split('\n'));
                                
                                for(String strOPtionValues : lstString_OPtionValues) {
                                    
                                    strOPtionValues = strOPtionValues.trim();
                                    
                                    lstSelectOPtion_AddValues.add(new SelectOption(strOPtionValues,strOPtionValues));
                                }                       
                            }
                        }
                        else {
                            
                            lstSelectOPtion_AddValues.add(new SelectOption('None', 'None'));
                        }
                        
                        QA_OpportunityWrapperClass objNewWrapper = new QA_OpportunityWrapperClass(objAnswer.Realated_Products__r.Name, objAnswer, mapQuestionId_Question.get(objAnswer.Question__c), objAnswer.Question__r.Question_Type__c, false, lstSelectOPtion_AddValues, '');
                        mapProductName_Wrapper.put(objAnswer.Realated_Products__r.Name, new List<QA_OpportunityWrapperClass>{objNewWrapper});
                        
                    }
                }
            }
        }
        catch(Exception e) {
            
            system.debug('*****Exception****'+e);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, string.valueof(e)));
        }
    }
    
    /*
        Name : saveRecords
        Type:  public
        Description: Update the answer records with answer values associated with those records.
    */
    
    public void saveRecords(){
        
        try {
            
            List<Answer__c> lstAnswer = new List<Answer__c>();  // List used to update the answer records on click of save button
            
            for(List<QA_OpportunityWrapperClass> strQuestionValues : mapProductName_Wrapper.values()) {
                
                for(QA_OpportunityWrapperClass lstWrapper : strQuestionValues) {
                    
                    if(lstWrapper.objAnswer.Answer_Given__c != null && lstWrapper.objAnswer.Answer_Given__c != '') {
                        
                        lstWrapper.objAnswer.isAnswerGiven__c = true;
                        
                    }
                    
                    lstAnswer.add(lstWrapper.objAnswer);
                    
                }
            }
            
            update lstAnswer;
        }
        catch(Exception e) {
            
            System.debug('*****Exception*****'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, string.valueof(e)));
            
        }
    }
}