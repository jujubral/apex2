public with sharing class AccountWithContactDetailsController {
	private Id accountId;
	public List<Contact> ConDetails { get; set; }

	public AccountWithContactDetailsController(ApexPages.StandardController sc) {
		accountId = sc.getId();
		getRelatedContactDetails();
	}

	private void getRelatedContactDetails() {
		checkReadAccess();

		ConDetails = [SELECT FirstName, LastName, Email, Phone
					  FROM Contact 
					  WHERE AccountId = :accountId];
	}

	private void checkReadAccess() {
		// security read access for Contact SObjectType
		PermissionChecker.checkPermissionAndThrowException(Contact.SObjectType, PermissionChecker.Intent.READ);

		// security read access for Contact fields queried
		PermissionChecker.checkPermissionAndThrowException(Contact.SObjectType, Contact.FirstName, PermissionChecker.Intent.READ);
		PermissionChecker.checkPermissionAndThrowException(Contact.SObjectType, Contact.LastName, PermissionChecker.Intent.READ);
		PermissionChecker.checkPermissionAndThrowException(Contact.SObjectType, Contact.Email, PermissionChecker.Intent.READ);
		PermissionChecker.checkPermissionAndThrowException(Contact.SObjectType, Contact.Phone, PermissionChecker.Intent.READ);
	}

}
