/**
 * API class for calculating EMI.
 */
global with sharing class EMICalculatorService {

	private static final String END_POINT = 'https://fakegetloanrate.com/compare';
	private static final String USER_NAME = 'fakeuser@example.com';

	/**
	 * API method to calculate EMI.
	 */
	global static CalculateEMIResponse calculateEMI(CalulateEMIRequest request){
		Double rateFactor = Math.pow(1+request.Rate, request.Period);
		Double emi = (request.Principal * request.Rate * rateFactor)/(rateFactor-1);

		CalculateEMIResponse emiResponse = new CalculateEMIResponse(request);
		emiResponse.Emi = emi;

		return emiResponse;
	}

	/**
	 * API method to compare loan rate between two providers
	 * Delegate request to external API using REST callout.
	 * Authorization to external API using username only.
	 */
	global static HttpResponse compareLoanRate(String providerKey1, String providerKey2) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint(
			END_POINT + 
			'?provider1=' + EncodingUtil.urlEncode(providerKey1,'UTF-8') +
			'&provider2=' + EncodingUtil.urlEncode(providerKey2,'UTF-8')
		);
		req.setMethod('GET');

		Blob headerValue = Blob.valueOf(USER_NAME);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);

		return new Http().send(req);
	}

	/**
	 * Request for calculating EMI.
	 */
	global class CalulateEMIRequest{
		/**
		 * Principal amount.
		 */
		global Double Principal{ get; set; }

		/**
		 * Rate of interest.
		 */
		global Double Rate{ get; set; }

		/**
		 * Period in months.
		 */
		global Integer Period{ get; set; }

		/**
		 * Global constructor for request.
		 */
		global CalulateEMIRequest() {

		}
	}

	/**
	 * Response returned after calculating EMI.
	 */
	global class CalculateEMIResponse {
		/**
		 * Principal amount.
		 */
		global Double Principal{ get; private set; }

		/**
		 * Rate of interest.
		 */
		global Double Rate{ get; private set; }

		/**
		 * Period in months.
		 */
		global Integer Period{ get; private set; }

		/**
		 * EMI calculated.
		 */
		global Double Emi{ get; private set; }

		/**
		 * Global constrcutor.
		 */
		global CalculateEMIResponse() {

		}

		/**
		 * Public constructor to get values form request.
		 */
		public CalculateEMIResponse(CalulateEMIRequest request) {
			Principal = request.Principal;
			Rate = request.Rate;
			Period = request.Period;
		}

	}
}
