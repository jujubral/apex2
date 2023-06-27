/**
 * Controller class for Subscriber Registration page.
 */
public with sharing class SubscriberRegistrationController {
	public String SelectedPeriod { get; set; }
	public Boolean SubscriptionSaved { get; set; }
	public Boolean Error { get; set; }
	public ApexPages.StandardController controller { get; set; }
	public SubscriberRegistrationController(ApexPages.StandardController sc) {
		controller = sc;
		SelectedPeriod = '3';
	}

	public List<SelectOption> getSubscriptionPeriodOptions() {
		List<SelectOption> options = new List<SelectOption>(); 
		options.add(new SelectOption('3', '3 months')); 
		options.add(new SelectOption('6', '6 months')); 
		options.add(new SelectOption('12', '12 months')); 

		return options; 
	}

	public void saveSubscription() {
		Contact record = (Contact) controller.getRecord();
		Date subscriptionExpiry = Date.today().addMonths(Integer.valueOf(SelectedPeriod));
		record.SubscriptionExpiry__c = subscriptionExpiry;

		try{
			PermissionChecker.checkPermissionAndThrowException(Contact.SObjectType, PermissionChecker.Intent.CREATE);

			insert record;
			sendActivationEmail(record.Id);
		} catch (Exception ex) {
			Error = true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));
			return;
		}

		SubscriptionSaved = true;
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'You are now subscribed !!'));
		ApexPages.currentPage().getParameters().put('editUrl', '/'+record.Id);
	}

	public PageReference editDetails() {
		String editPage = ApexPages.currentPage().getParameters().get('editUrl');
		return new PageReference(editPage);
	}

	private void sendActivationEmail(Id contactId) {
		String subject = 'Your Subscription is now active.';
		String senderDisplayName = 'Subsciption Support @ ' + UserInfo.getOrganizationName();

		String message = 'Hello {!Contact.FirstName} {!Contact.LastName}!\n';
		message += 'Your Subscription is now activated for ' + SelectedPeriod + ' months and will expire on {!Contact.SubscriptionExpiry__c}.\n\n';
		message += 'Please login to your account to discover the APIs supported.\n';
		message += 'Thanks and Regards\n';
		message += senderDisplayName;

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTreatBodiesAsTemplate(true);
		mail.setTargetObjectId(contactId);
		mail.setPlainTextBody(message);
		mail.setSenderDisplayName(senderDisplayName);
		mail.setSubject(subject);

		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
	}

}
