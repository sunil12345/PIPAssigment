/**
  Name: TBN_Entitlement_WebService
  Description: webservice class for getting the case related records 
  Created By: Sunil Pal
  Last Modified By: Sunil Pal
 */
 
global with sharing class TBN_Entitlement_WebService {
	
	
	global class IVR {
		
		webservice String strCaseId;
		webservice String strPhoneNumber;
	}
	
	
	// Wrapper class for AccountInfo
	global class accountInfo {
		
		webservice String strAccountName;
		webservice String strAccountNumber;
		webservice String strPhoneNumber;
		webservice String strFax;
		webservice String strAccountSource;
		
		global accountInfo (String strAccountName, String strAccountNumber, String strPhoneNumber, String strFax, String strAccountSource) {
			
			this.strAccountName = strAccountName;
			this.strAccountNumber = strAccountNumber;
			this.strPhoneNumber = strPhoneNumber;
			this.strFax = strFax;
			this.strAccountSource = strAccountSource;
		}
	}
	
	// Wrapper class for ContactInfo
	global class contactInfo {
		
		webservice String strContactName;
		webservice String strContactPhone;
		webservice String strEmail;
		webservice String strDepartment;
		webservice String strAssistantName;
		
		global contactInfo(String strContactName, String strContactPhone, String strEmail, String strDepartment, String strAssistantName) {
			
			this.strContactName = strContactName;
			this.strContactPhone = strContactPhone;
			this.strEmail = strEmail;
			this.strDepartment = strDepartment;
			this.strAssistantName = strAssistantName;
		}	
	}
	
	// Wrapper class for AssetInfo
	global class assetInfo {
	
		webservice String strAssetname ;
		webservice decimal dbQuantity ;
		webservice String strStatus ;
		webservice String strContactId ;
		webservice String strAccountId ;
		
		global assetInfo(String strAssetname , decimal dbQuantity, String strStatus, String strContactId, String strAccountId) {
			
			this.strAssetname = strAssetname;
			this.dbQuantity = dbQuantity;
			this.strStatus = strStatus;
			this.strContactId = strContactId;
			this.strAccountId = strAccountId;
		}
	}
	
	// Wrapper class for entitlementInfo
	global class entitlementInfo {
	
		webservice String strEntitlementName ;
		webservice String strStatus ;
		webservice boolean isPerIncident ;
		webservice String strAssetId ;
		webservice String strAccountId ;
		
		global entitlementInfo(String strEntitlementName, String strStatus, boolean isPerIncident, String strAssetId, String strAccountId) {
			
			this.strEntitlementName = strEntitlementName;
			this.strStatus = strStatus;
			this.isPerIncident= isPerIncident;
			this.strAssetId= strAssetId;
			this.strAccountId = strAccountId;
		}
	}
	
	// Wrapper class for combine all the inside wrapper class
	global class combineAllRecords_Wrapper {
		
		webservice  List<accountInfo> lstAccountInfo;
		webservice  List<contactInfo> lstContactInfo;
		webservice  List<assetInfo> lstAssetrInfo;
		webservice  List<entitlementInfo> lstEntitlementInfo;
		
		global combineAllRecords_Wrapper (List<accountInfo> lstAccountInfo, List<contactInfo> lstContactInfo, List<assetInfo> lstAssetrInfo, List<entitlementInfo> lstEntitlementInfo ) {
			
			this.lstAccountInfo = lstAccountInfo;
			this.lstContactInfo = lstContactInfo;
			this.lstAssetrInfo= lstAssetrInfo;
			this.lstEntitlementInfo = lstEntitlementInfo;
		}	
	} 
	
	/*
	  Name: combineAllRecords_Wrapper
	  Description: webservice method which is called from IVR side
	  Parameter : IVRSection wrapper class 	(	1 - Case Id
	  											2- 	Phone Number 
	  										)
 	*/
 
	webservice static combineAllRecords_Wrapper getCaseRelatedRecords(IVR IVRSection) {
		
		try {
			
			List<accountInfo> lstAccountInfo = new List<accountInfo>();
			
			List<assetInfo> lstAssetInfo = new List<assetInfo>();
			
			List<entitlementInfo> lstEntitlementInfo = new List<entitlementInfo>();
			
			List<contactInfo> lstContactInfo = new List<contactInfo>();
			
			if(IVRSection.strCaseId != null && IVRSection.strPhoneNumber != null) {
					
				List<Case> lstCase = new List<Case>([	SELECT 	Reason, ParentId, Id, ContactId, CaseNumber, AssetId, AccountId,
														Account.AccountNumber, Contact.MobilePhone, EntitlementId 
														FROM Case
														WHERE Id =: IVRSection.strCaseId
													]);
					
				if(!lstCase.isEmpty()) {
					
					List<Account> lstAccount = new List<Account>	([	SELECT Id, Name, Phone, Fax, AccountSource, AccountNumber
																		FROM Account
																		WHERE Id =: lstCase[0].AccountId
																	]) ;
					if(!lstAccount.isEmpty()) {
						
						accountInfo objAccountInfo  =  new accountInfo(lstAccount[0].Name, lstAccount[0].AccountNumber, lstAccount[0].Phone, lstAccount[0].Fax, lstAccount[0].AccountSource);
						
						lstAccountInfo.add(objAccountInfo);
						
						for(Contact objContact : [	SELECT Id, Name, Email, Department, AssistantName, AccountId, Phone
												 	FROM Contact
												 	WHERE AccountId =: lstAccount[0].Id
												 	AND Phone =:IVRSection.strPhoneNumber  
												 ]) {
							
							if(objContact != null ) {
								
								contactInfo objContactInfo = new contactInfo(objContact.Name, objContact.Phone, objContact.Email, objContact.Department, objContact.AssistantName) ;
								
								lstContactInfo.add(objContactInfo);
							}					 	
						}
						
						for(Asset objAsset : [	SELECT Id, Name, AccountId, Status, Quantity, ContactId
												FROM Asset
												WHERE AccountId =: lstAccount[0].Id])	 {
																		
							if(objAsset != null ) {
							
								assetInfo objAssetInfo = new assetInfo(objAsset.Name, objAsset.Quantity, objAsset.Status, objAsset.ContactId, objAsset.AccountId );
								
								lstAssetInfo.add(objAssetInfo); 	
							}
																				
						}											 
						
						for(Entitlement objEntitlement : [	SELECT Id, Name, AccountId, Status, IsPerIncident, AssetId 
															FROM Entitlement
															WHERE AccountId =: lstAccount[0].Id
														]) {
							
							if(objEntitlement != null ){
								
								entitlementInfo objEntitlementInfo = new entitlementInfo(objEntitlement.Name, objEntitlement.Status, objEntitlement.IsPerIncident, objEntitlement.AssetId, objEntitlement.AccountId);
								
								lstEntitlementInfo.add(objEntitlementInfo);	
							}
						}								
					}	
				}									
			} 
			
			combineAllRecords_Wrapper objCombine_Wrapper = new combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo);
			
			return objCombine_Wrapper;
		}
		catch(Exception e) {
			
			system.debug('**** Exception ****'+e);
			Error_Log__c objErrorLog = new Error_Log__c();
			objErrorLog.Error_Description__c = string.valueOf(e);
			objErrorLog.Error_Source__c = string.valueOf(e.getLineNumber());
			objErrorLog.Error_Method_Name__c = 'getCaseRelatedRecords';
			objErrorLog.Error_Date_Time__c = Date.today();
			objErrorLog.Error_Type__c = string.valueOf(e.getTypeName());
			insert objErrorLog;
			
			return null;
		}
		
	}
}