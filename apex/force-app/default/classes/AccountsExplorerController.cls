/**
 * Controller class for AccountsExplorer page
 */
public with sharing class AccountsExplorerController {

	private final String SOBJECT_TYPE = String.valueOf(Account.SObjectType);
	private final String DEVELOPER_NAME = 'AllAccounts';

	public AccountsExplorerController(ApexPages.StandardSetController sc) {
		Id filterId = [SELECT Id 
					   FROM ListView 
					   WHERE DeveloperName=:DEVELOPER_NAME AND SObjectType=:SOBJECT_TYPE].Id;
		sc.setFilterId(filterId);
	}
}
