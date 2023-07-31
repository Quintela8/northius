public class Application 
{

	// Configure and create the UnitOfWorkFactory for this Application
	public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
		new fflib_Application.UnitOfWorkFactory(
				new List<SObjectType> {
					Account.SObjectType,
					Opportunity.SObjectType,
					Product2.SObjectType,
					PricebookEntry.SObjectType,
					OpportunityLineItem.SObjectType });	

    private static fflib_ApplicationForceDI.ServiceFactory pService;
    public static fflib_ApplicationForceDI.ServiceFactory Service {
        get {
            if (pService==null) {
                pService = new fflib_ApplicationForceDI.ServiceFactory();
            }
            return pService;
        }
    }

	private static fflib_ApplicationForceDI.SelectorFactory pSelector;
    public static fflib_ApplicationForceDI.SelectorFactory Selector {
        get {
            if (pSelector==null) {
                pSelector = new fflib_ApplicationForceDI.SelectorFactory();
            }
            return pSelector;
        }
    }
                    
	private static fflib_ApplicationForceDI.DomainFactory pDomain;
	public static fflib_ApplicationForceDI.DomainFactory Domain {
		get {
			if (pDomain==null) {
				pDomain = new fflib_ApplicationForceDI.DomainFactory(Selector);
			}
			return pDomain;
		}
	}
}