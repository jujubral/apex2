/**
 * Controller class for SubscriptionReminder page.
 */
public with sharing class SubscriptionReminderController {
	public List<Contact> Contacts { get; set; }
	public Integer MaxDaysToExpiry{ get; set; }
	public Boolean EmailSent{ get; set; }
	public String SearchName{ get; set; }
	public List<String> OtherContactFields{ get; set; }

	public SubscriptionReminderController() {
		MaxDaysToExpiry = 10;
		init();
	}

	public void init() {
		Date dateToday = Date.today();
		Date reminderDate = dateToday.addDays(MaxDaysToExpiry);

		// using WITH SECURITY_ENFORCED automatically enforces read access checks
		String query = String.format(
			'SELECT {0} ' +
			'FROM Contact ' + 
			'WHERE SubscriptionExpiry__c != null ' +
				'AND SubscriptionExpiry__c >= :dateToday ' +
				'AND SubscriptionExpiry__c <= :reminderDate ' +
				'AND Name LIKE \'%' + SearchName + '%\' ' +
			'WITH SECURITY_ENFORCED', 
			new List<String>{
				getFields()
			}
		);

		Contacts = Database.query(query);
		EmailSent = false;
	}

	public void sendReminder() {
		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		String subject = 'Your Subscription is about to expire !';
		String senderDisplayName = 'Subsciption Support @ ' + UserInfo.getOrganizationName();

		String message = 'Hello {!Contact.FirstName} {!Contact.LastName}!\n';
		message += 'Your Subscription is about to expire on {!Contact.SubscriptionExpiry__c}.\n\n';
		message += 'Please login to your account to renew your subscription !\n';
		message += 'Ignore if already done.\n\n';
		message += 'Thanks and Regards\n';
		message += senderDisplayName;

		for(Contact con: Contacts) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTreatBodiesAsTemplate(true);
			mail.setTargetObjectId(con.Id);
			mail.setPlainTextBody(message);
			mail.setSenderDisplayName(senderDisplayName);
			mail.setSubject(subject);

			mails.add(mail);
		}

		if(mails.size() > 0) {
			Messaging.sendEmail(mails);
			EmailSent = true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Email sent successfully to ' + mails.size() + ' contact(s)!'));
		}

	}

	private String getFields() {
		List<String> fields = new List<String>{
			'FirstName',
			'LastName',
			'AccountId',
			'Email',
			'SubscriptionExpiry__c'
		};

		String fieldListCsv = ApexPages.currentPage().getParameters().get('extraFields');
		OtherContactFields = fieldListCsv != null ? fieldListCsv.split(',') : new List<String>();

		fields.addAll(getAllowedExtraFields(OtherContactFields));

		return String.join(fields, ',');    
	}

	// whitelist the allowed extra fields to be queried
	private List<String> getAllowedExtraFields(List<String> extraFields) {
		if(extraFields != null && extraFields.equals(new List<String>{'HomePhone', 'Phone', 'Fax'})) {
			return extraFields;
		}

		return new List<String>();
	}
}
