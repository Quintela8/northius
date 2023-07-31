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

	// Configure and create the SelectorFactory for this Application
	public static final fflib_Application.SelectorFactory Selector = 
		new fflib_Application.SelectorFactory(
			new Map<SObjectType, Type> {
					Account.SObjectType => AccountSelector.class});

                    
	public static final fflib_Application.DomainFactory Domain = 
		new fflib_Application.DomainFactory(
			Application.Selector,
			new Map<SObjectType, Type> {
					Account.SObjectType => AccountDomain.Constructor.class });
}