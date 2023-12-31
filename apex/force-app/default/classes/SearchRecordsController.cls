/**
 * Controller class for SearchRecords page.
 */
public with sharing class SearchRecordsController {
	public List<SObject> Records{ get; set; }
	public String SearchTerm{ get; set; }

	public SearchRecordsController() {
		init();
	}

	public void searchRecords() {
		checkReadAccess();
		
		String searchQuery = 'FIND \'' + sanitizeSearchTerm() + '\' IN Name FIELDS RETURNING Account(Id, Name), Contact(Id, Name) LIMIT 10';

		List<List<SObject>> sObjectLists = Search.query(searchQuery);
		for(List<SObject> sObjects: sObjectLists) {
			Records.addAll(sObjects);
		}
	}

	public void init() {
		SearchTerm = '';
		Records = new List<SObject>();
	}

	private void checkReadAccess() {
		// security read check on Contact and its name field
		Permissionchecker.checkPermissionAndThrowException(Contact.SObjectType, PermissionChecker.Intent.READ);
		Permissionchecker.checkPermissionAndThrowException(Contact.SObjectType, Contact.Name, PermissionChecker.Intent.READ);

		// security read check on Account and its name field
		Permissionchecker.checkPermissionAndThrowException(Account.SObjectType, PermissionChecker.Intent.READ);
		Permissionchecker.checkPermissionAndThrowException(Account.SObjectType, Account.Name, PermissionChecker.Intent.READ);
	}

	private String sanitizeSearchTerm() {
		String escapedText = String.escapeSingleQuotes(SearchTerm);
		escapedText = escapedText.replaceAll( '(?i)( AND NOT | AND | OR )', ' ' );

		Pattern myPattern = Pattern.compile( '(\\?|\\&|\\||\\!|\\{|\\}|\\[|\\]|\\(|\\)|\\^|\\~|\\*|\\:|\\"|\\+|\\-)' );
		Matcher myMatcher = myPattern.matcher( escapedText );

		escapedText = myMatcher.replaceAll( '\\\\\\\\$1' );
		escapedText = escapedText.replaceAll( '( )+', ' ' ).trim();

		return escapedText;
	}

}
