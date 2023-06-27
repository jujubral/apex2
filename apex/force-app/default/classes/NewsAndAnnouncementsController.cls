/**
 * Controller class for NewsAndAnnouncementsPage
 */
public with sharing class NewsAndAnnouncementsController {

	private final String SOBJECT_TYPE = String.valueOf(Post__c.SObjectType);
	private final String DEVELOPER_NAME = 'All';

	public NewsAndAnnouncementsController(ApexPages.StandardSetController sc) {
		Id filterId = [SELECT Id 
					   FROM ListView 
					   WHERE DeveloperName=:DEVELOPER_NAME AND SObjectType=:SOBJECT_TYPE].Id;
		sc.setFilterId(filterId);
	}
}
