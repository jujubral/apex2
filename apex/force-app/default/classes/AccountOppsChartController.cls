
/**
 * Controller class for AccountOppsChart page.
 */
public with sharing class AccountOppsChartController {
	private Id accountId;
	public List<OpportunityDetail> OppDetails { get; set; }

	public AccountOppsChartController(ApexPages.StandardController controller) {
		accountId = controller.getId();
		getRelatedOppDetails();
	}

	private void getRelatedOppDetails() {
		OppDetails = new List<OpportunityDetail>();
		List<Opportunity> oppList = getRelatedOpportunities();

		for(Opportunity opp: oppList) {
			OpportunityDetail oppDetail = new OpportunityDetail();
			oppDetail.Name = opp.Name;
			oppDetail.Amount = opp.Amount;

			OppDetails.add(oppDetail);
		}
	}

	private List<Opportunity> getRelatedOpportunities() {
		checkReadAccess();

		return [SELECT Name, Amount
				FROM Opportunity 
				WHERE AccountId = :accountId];
	}

	private void checkReadAccess() {
		PermissionChecker.Intent oprnType = PermissionChecker.Intent.READ;
		SobjectType objType = Opportunity.SObjectType;

		// check read access on Opportunity SObject
		PermissionChecker.checkPermissionAndThrowException(objType, oprnType);

		// check read on Opportunity fields queried
		PermissionChecker.checkPermissionAndThrowException(objType, Opportunity.Name, oprnType);
		PermissionChecker.checkPermissionAndThrowException(objType, Opportunity.Amount, oprnType);
	}

	/**
	 * Wrapper class to depict pie chart.
	 */
	public class OpportunityDetail {
		public String Name { get; set; }
		public Decimal Amount { get; set; }
	}

}
