/**
  Name: TBN_Entitlement_WebService
  Description: webservice class for getting the case related records 
  Created By: Sunil Pal
  Last Modified By: Sunil Pal
 */
 
global with sharing class TBN_Entitlement_WebService {
	
	
	/* 	IVR input which need to pass from IVR side 
	 	1- Case Id 
	 	2- Phone Number
	*/ 
	global class IVR {
		
		webservice String strCaseId;
		webservice String strPhoneNumber;
	}
	
	
	/* 	Name : accountInfo
	 	Description : Wrapper class contains the following information about Account
	 					1- Account Name
	 					2- Account Number
	 					3- Account Phone
	 					4- Account Fax
	 					5- Account Account Source	
	*/ 
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
	
	/* 	Name : contactInfo
	 	Description : Wrapper class contains the following information about Contact
	 					1- Contact Name
	 					2- Contact Phone
	 					3- Contact Email
	 					4- Contact Department
	 					5- Contact AssistantName	
	*/ 
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
	
	/* 	Name : assetInfo
	 	Description : Wrapper class contains the following information about Asset
	 					1- Asset Name
	 					2- Asset Quantity
	 					3- Asset Status
	 					4- Asset ContactId
	 					5- Asset AccountId	
	*/ 
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
	
	/* 	Name : entitlementInfo
	 	Description : Wrapper class contains the following information about Entitlement
	 					1- Entitlement Name
	 					2- Entitlement Status
	 					3- Entitlement isPerIncident
	 					4- Entitlement AssetId
	 					5- Entitlement AccountId	
	*/ 
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
	
	/* 	Name : combineAllRecords_Wrapper
	 	Description : Wrapper class used to combine all the other wrapper class like entitlementInfo, assetInfo etc
	 					1- List<accountInfo>
	 					2- List<contactInfo>
	 					3- List<assetInfo>
	 					4- List<entitlementInfo>
	 					5- String Error	
	*/ 
	// Wrapper class for combine all the inside wrapper class
	global class combineAllRecords_Wrapper {
		
		webservice  List<accountInfo> lstAccountInfo;
		webservice  List<contactInfo> lstContactInfo;
		webservice  List<assetInfo> lstAssetrInfo;
		webservice  List<entitlementInfo> lstEntitlementInfo;
		webservice  String strError;
		
		global combineAllRecords_Wrapper (List<accountInfo> lstAccountInfo, List<contactInfo> lstContactInfo, List<assetInfo> lstAssetrInfo, List<entitlementInfo> lstEntitlementInfo, String strError ) {
			
			this.lstAccountInfo = lstAccountInfo;
			this.lstContactInfo = lstContactInfo;
			this.lstAssetrInfo= lstAssetrInfo;
			this.lstEntitlementInfo = lstEntitlementInfo;
			this.strError = strError;
		}	
	} 
	
	/*
	  Name: combineAllRecords_Wrapper
	  Description: webservice method which is called from IVR side
	  Parameter : IVRSection wrapper class 	(	1 - Case Id
	  											2- 	Phone Number 
	  										)
	  Return type : combineAllRecords_Wrapper										
 	*/
 
	webservice static combineAllRecords_Wrapper getCaseRelatedRecords(IVR IVRSection) {
		
		List<accountInfo> lstAccountInfo = new List<accountInfo>(); // List of accountInfo contains all the information related to account fields
			
		List<assetInfo> lstAssetInfo = new List<assetInfo>();	// List of assetInfo contains all the information related to asset fields
			
		List<entitlementInfo> lstEntitlementInfo = new List<entitlementInfo>(); // List of entitlementInfo contains all the information related to entitlement fields
			
		List<contactInfo> lstContactInfo = new List<contactInfo>(); // List of contactInfo contains all the information related to contact fields
		
		combineAllRecords_Wrapper objCombine_Wrapper = new combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo,  '');
		
		try {
			
			if((IVRSection.strCaseId != null && IVRSection.strCaseId != '') && (IVRSection.strPhoneNumber != null && IVRSection.strPhoneNumber != '')) {
				
				List<Case> lstCase = new List<Case>([	SELECT 	Reason, ParentId, Id, ContactId, CaseNumber, AssetId, AccountId,
														Account.AccountNumber, Contact.MobilePhone, EntitlementId 
														FROM Case
														WHERE CaseNumber =: IVRSection.strCaseId
													]);
					
				if(!lstCase.isEmpty()) {
					
					List<Account> lstAccount = new List<Account>	([	SELECT Id, Name, Phone, Fax, AccountSource, AccountNumber
																		FROM Account
																		WHERE Id =: lstCase[0].AccountId
																		AND AccountNumber =: lstCase[0].CaseNumber
																	]) ;
						
					if(!lstAccount.isEmpty()) {
						
						accountInfo objAccountInfo  =  new accountInfo(lstAccount[0].Name, lstAccount[0].AccountNumber, lstAccount[0].Phone, lstAccount[0].Fax, lstAccount[0].AccountSource);
						
						lstAccountInfo.add(objAccountInfo);
						
						for(Contact objContact : [	SELECT Id, Name, Email, Department, AssistantName, AccountId, Phone
												 	FROM Contact
												 	WHERE AccountId =: lstAccount[0].Id
												 	AND Phone =: IVRSection.strPhoneNumber
												 ]) {
							
							if(objContact != null ) {
								
								contactInfo objContactInfo = new contactInfo(objContact.Name, objContact.Phone, objContact.Email, objContact.Department, objContact.AssistantName) ;
								
								lstContactInfo.add(objContactInfo);
							}
						}
						
						if(lstContactInfo.isEmpty()) {
							
							objCombine_Wrapper = new combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo, ' No contact record is available!');
							
							return objCombine_Wrapper;
						}
						for(Asset objAsset : [	SELECT Id, Name, AccountId, Status, Quantity, ContactId
												FROM Asset
												WHERE AccountId =: lstAccount[0].Id])	 {
																		
							if(objAsset != null ) {
							
								assetInfo objAssetInfo = new assetInfo(objAsset.Name, objAsset.Quantity, objAsset.Status, objAsset.ContactId, objAsset.AccountId );
								
								lstAssetInfo.add(objAssetInfo); 	
							}
						}											 
						
						if(lstAssetInfo.isEmpty()) {
							
							objCombine_Wrapper = new combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo, ' No asset record is available!');
							
							return objCombine_Wrapper;
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
						if(lstAssetInfo.isEmpty()) {
							
							objCombine_Wrapper = new combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo, ' No entitlement record is available!');
							
							return objCombine_Wrapper;
						}
					}
					else {
						
						objCombine_Wrapper = new combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo, ' No account record is available!');
						
						return objCombine_Wrapper;
					}
				}		
				else {
					
					objCombine_Wrapper = new combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo, ' Records are not avilable for this caseId');
					
					return objCombine_Wrapper;
				}							
			} 
			else {
				
				objCombine_Wrapper = new combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo, 'Something is missing caseid or phone number');
			}
			
			return objCombine_Wrapper;
		}
		catch(Exception e) {
			
			system.debug('***** Exception *****'+e);
			
			Error_Log__c objErrorLog = new Error_Log__c(Error_Description__c = string.valueOf(e)+'/'+string.valueOf(e.getLineNumber()), 
														Error_Source__c = 'TBN_Entitlement_WebService',
														Error_Method_Name__c = 'getCaseRelatedRecords', 
														Error_Date_Time__c = Date.today(), 
														Error_Type__c = string.valueOf(e.getTypeName()));
			insert objErrorLog;
			
			objCombine_Wrapper = new combineAllRecords_Wrapper(lstAccountInfo, lstContactInfo, lstAssetInfo, lstEntitlementInfo, string.valueOf(e));
			
			return objCombine_Wrapper;
		}
	}
}