public with sharing class AccountWithOppsDetailsController {

	private Id accountId;
	public List<Opportunity> OppDetails { get; set; }

	public AccountWithOppsDetailsController(ApexPages.StandardController controller) {
		accountId = controller.getId();
		getRelatedOpportunities();
	}

	private void getRelatedOpportunities() {
		permissionChecks();

		OppDetails = [SELECT Name, Amount, StageName, CloseDate, NextStep 
					  FROM Opportunity 
					  WHERE AccountId = :accountId];
	}

	private void permissionChecks() {
		PermissionChecker.Intent oprnType = PermissionChecker.Intent.READ;
		SobjectType objType = Opportunity.SObjectType;

		// check read access on Opportunity SObject
		PermissionChecker.checkPermissionAndThrowException(objType, oprnType);

		// check read on Opportunity Fields queried
		PermissionChecker.checkPermissionAndThrowException(objType, Opportunity.Name, oprnType);
		PermissionChecker.checkPermissionAndThrowException(objType, Opportunity.Amount, oprnType);
		PermissionChecker.checkPermissionAndThrowException(objType, Opportunity.StageName, oprnType);
		PermissionChecker.checkPermissionAndThrowException(objType, Opportunity.CloseDate, oprnType);
		PermissionChecker.checkPermissionAndThrowException(objType, Opportunity.NextStep, oprnType);
	}

}
