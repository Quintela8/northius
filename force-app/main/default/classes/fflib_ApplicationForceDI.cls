/**
 * @description ffli Application module, using the force_di package to retrieve the binding definitions
 */
public class fflib_ApplicationForceDI {
    private static di_injector injector = di_injector.Org;
    private static Set < String > loadedDomainPackages = new Set < String > ();
    /**
     * @description  Simple Service Factory implementaiton
     */
    public class ServiceFactory implements fflib_IServiceFactory {

        private Map < Type, Object > m_serviceInterfaceTypeByMockService;
        public ServiceFactory() {
            m_serviceInterfaceTypeByMockService = new Map < Type, Object > ();
          }
        /**
         * @description  Returns a new instance of the Apex class associated with the given Apex interface
         *   Will return any mock implementation of the interface provided via setMock
         *   Note that this method will not check the configured Apex class actually implements the interface
         *
         * @param serviceInterfaceType Apex interface type
         * @return new Service object intance
         * @exception Is thrown if there is no registered Apex class for the interface type
         */
        public Object newInstance(Type serviceInterfaceType) {
            // Mock implementation?
            if (m_serviceInterfaceTypeByMockService.containsKey(serviceInterfaceType)) {
                return m_serviceInterfaceTypeByMockService.get(serviceInterfaceType);
            }
            // Create an instance of the type impleneting the given interface
            Object serviceImpl = injector.getInstance(serviceInterfaceType);
            if (serviceImpl == null) {
                throw new DeveloperException('No implementation registered for service interface ' + serviceInterfaceType.getName());
            }
            return serviceImpl;
        }
        /**
         * @description  Returns a new instance of the Apex class associated with the given Apex interface
         *   Will return any mock implementation of the interface provided via setMock
         *   Note that this method will not check the configured Apex class actually implements the interface
         *
         * @param serviceInterfaceType Apex interface type
         * @param params params constructor 
         * @return new service object instance 
         * @exception Is thrown if there is no registered Apex class for the interface type
         */
        public Object newInstance(Type serviceInterfaceType, Object params) {
            // Create an instance of the type impleneting the given interface
            Object serviceImpl = injector.getInstance(serviceInterfaceType, params);
            if (serviceImpl == null) {
                throw new DeveloperException('No implementation registered for service interface ' + serviceInterfaceType.getName());
            }
            return serviceImpl;
        }
        @TestVisible
        private void setMock(Type serviceInterfaceType, Object serviceImpl) {
            di_Injector.Org.Bindings.byName(serviceInterfaceType.getName().toLowerCase())
                .replaceBindingWith(serviceImpl);
        }
    }
    /**
     * @description  Implements a Selector class factory
     */
    public class SelectorFactory implements fflib_ISelectorFactory {

        private Map < String, fflib_ISObjectSelector > m_sObjectNameByMockSelector;
        public SelectorFactory(){
            m_sObjectNameByMockSelector = new Map<String, fflib_ISObjectSelector>();
        }

        /**
         * @description Creates a new instance of the associated Apex Class implementing fflib_ISObjectSelector
         *   for the given SObjectType, or if provided via setMock returns the Mock implementaton
         *
         * @param sObjectType An SObjectType token, e.g. Account.SObjectType
         * @return new Selector object instance
         */
        public fflib_ISObjectSelector newInstance(SObjectType sObjectType) {
            String bindingName = getBindingName(sObjectType);
            if(m_sObjectNameByMockSelector.containsKey(bindingName)){
                return m_sObjectNameByMockSelector.get(bindingName);
            }
            fflib_ISObjectSelector selector = getSelectorFromFactory(sObjectType);
            if (selector == null) {
                throw new DeveloperException('Selector class not found for SObjectType ' + sObjectType);
            }
            return selector;
        }

        /**
         * @param sObjectType object type the selector is based
         * @return new Selector object instance
         */
        private fflib_ISObjectSelector getSelectorFromFactory(SObjectType sObjectType) {
            String bindingName = getBindingName(sObjectType);
            fflib_ISObjectSelector selector = null;
            return (fflib_ISObjectSelector) injector.getInstance(bindingName, sObjectType, null);
        }

        /**
         * @description build the binding name from ObjectType and module prefix
         * @param sobjectType the SObjectType to search
         * @param packagePrefix Module prefix
         * @return  `String` name ot use in the search of bindings
         */
        private String getBindingName(SObjectType sobjectType) {
            //String sobjectName = sobjType.getDescribe().getLabelPlural();
            String sobjectName = sobjectType.getDescribe().getLabel();
            sobjectName = toCammelCase(sobjectName);
            String bindingName = 'I'+sobjectName + 'Selector';
            return bindingName;
        }
        
        /**
         * Helper method to query the given SObject records
         *   Internally creates an instance of the registered Selector and calls its
         *     selectSObjectById method
         *
         * @param recordIds The SObject record Ids, must be all the same SObjectType
         * @exception Is thrown if the record Ids are not all the same or the SObjectType is not registered
         **/
        public List<SObject> selectById(Set<Id> recordIds)
        {
            // No point creating an empty Domain class, nor can we determine the SObjectType anyway
            if(recordIds == null || recordIds.isEmpty())
                throw new DeveloperException('Invalid record Id\'s set');

            // Determine SObjectType
            SObjectType domainSObjectType = new List<Id>(recordIds)[0].getSObjectType();

            for (Id recordId : recordIds)
            {
                if (recordId.getSobjectType() != domainSObjectType)
                {
                    throw new DeveloperException('Unable to determine SObjectType, Set contains Id\'s from different SObject types');    
                }
            }

            // Construct Selector class and query by Id for the records
            return newInstance(domainSObjectType).selectSObjectsById(recordIds);
        }

                /**
         * Helper method to query related records to those provided, for example
         *   if passed a list of Opportunity records and the Account Id field will
         *   construct internally a list of Account Ids and call the registered 
         *   Account selector to query the related Account records, e.g.
         *
         *     List<Account> accounts = 
         *        (List<Account>) Application.Selector.selectByRelationship(myOpps, Opportunity.AccountId);
         *
         * @param relatedRecords used to extract the related record Ids, e.g. Opportunty records
         * @param relationshipField field in the passed records that contains the relationship records to query, e.g. Opportunity.AccountId
         **/
        public List<SObject> selectByRelationship(List<SObject> relatedRecords, SObjectField relationshipField)
        {
            Set<Id> relatedIds = new Set<Id>();
            for (SObject relatedRecord : relatedRecords)
            {
                Id relatedId = (Id) relatedRecord.get(relationshipField);
                if (relatedId != null)
                {
                    relatedIds.add(relatedId);
                }
            }
            return selectById(relatedIds);
        }
      
        @TestVisible
        private void setMock(fflib_ISObjectSelector selectorInstance) {
          m_sObjectNameByMockSelector.put(getBindingName(selectorInstance.sObjectType()), selectorInstance);
        }
    }
    /**  
     * @description Class implements a Domain class factory
     */
    public class DomainFactory {
        private fflib_ApplicationForceDI.SelectorFactory m_selectorFactory;
        private Map < SObjectType, fflib_ISObjectDomain > m_sObjectByMockDomain;
        
        /**
         * @description Consturcts a Domain factory, using an instance of the Selector Factory
         *   and a map of Apex classes implementing fflib_ISObjectDomain by SObjectType
         *   Note this will not check the Apex classes provided actually implement the interfaces
         *     since this is not possible in the Apex runtime at present
         * @param selectorFactory e.g. Application.Selector
         * @param packagePrefix package prefix for the factory (module)
         */
        public DomainFactory(fflib_ApplicationForceDI.SelectorFactory selectorFactory) {
            m_selectorFactory = selectorFactory;
            m_sObjectByMockDomain = new Map < SObjectType, fflib_ISObjectDomain > ();
        }
        /**
         * @description Dynamically constructs an instance of a Domain class for the given record Ids
         *   Internally uses the Selector Factory to query the records before passing to a
         *   dynamically constructed instance of the application Apex Domain class
         *
         * @param recordIds A list of Id's of the same type
         * @return new Domain object instance
         * @exception Throws an exception via the Selector Factory if the Ids are not all of the same SObjectType
         */
        public fflib_ISObjectDomain newInstance(Set < Id > recordIds) {
            return newInstance(m_selectorFactory.selectById(recordIds));
        }

        /**
         * @description Dynamically constructs an instace of the Domain class for the given records
         *   Will return a Mock implementation if one has been provided via setMock
         * 
         * @param records A concreate list (e.g. List<Account> vs List<SObject>) of records
         * @return new Domain object instance
         * @exception Throws an exception if the SObjectType cannot be determined from the list 
         *              or the constructor for Domain class was not registered for the SOBjectType
         */
        public fflib_ISObjectDomain newInstance(List < SObject > records) {
            SObjectType domainSObjectType = records.getSObjectType();
            return newInstance(records, domainSObjectType);
        }

        /**
         * @description Dynamically constructs an instace of the Domain class for the given records and SObjectType
         *   Will return a Mock implementation if one has been provided via setMock
         *
         * @param records A list records
         * @param domainSObjectType SObjectType for list of records
         * @return new Domain object instance
         * @exception Throws an exception if the SObjectType is not specified or if constructor for Domain class was not registered for the SObjectType
         *
         * @remark Will support List<SObject> but all records in the list will be assumed to be of
         *         the type specified in sObjectType
         */
        public fflib_ISObjectDomain newInstance(List<SObject> records, SObjectType domainSObjectType) {
            if (domainSObjectType == null) {
                throw new DeveloperException('Must specify sObjectType');
            }
            if (m_sObjectByMockDomain.containsKey(domainSObjectType)) {
                return m_sObjectByMockDomain.get(domainSObjectType);
            }
            fflib_ISObjectDomain domain = getDomainFromFactory(domainSObjectType, records);
            if (domain == null) {
                throw new DeveloperException('Domain constructor class not found for SObjectType ' + domainSObjectType);
            }
            return domain;
        }
       
        @TestVisible
        private void setMock(fflib_ISObjectDomain mockDomain) {
            m_sObjectByMockDomain.put(mockDomain.sObjectType(), mockDomain);
        }

    /**
     * @description Get a domain object instance for SObjectType and init with the records specified in params
     * @param domainSObjectType SObjectType for the domain object instance
     * @param records List of records to handle by the domain
     * @return  `fflib_ISObjectDomain` Domain object instnace for the object type
     */
    private fflib_ISObjectDomain getDomainFromFactory(SObjectType domainSObjectType, List < SObject > records) {
        String sobjectName = domainSObjectType.getDescribe().getLabel();
        sobjectName = toCammelCase(sobjectName);
  
        String developerName = 'I'+ sobjectName + 'Domain'; 
  
        fflib_ISObjectDomain domain;
        return (fflib_ISObjectDomain) injector.getInstance(developerName, domainSObjectType, records);
      }
    }
    
    /**
     * @description Custom esception for fflib_Application
     */
    public class ApplicationException extends Exception {}
    /**
     * @description Exception representing a developer coding error, not intended for end user eyes
     */
    public class DeveloperException extends Exception {}

    /**
     * @description Format string to camml case
     * @param text input string to format
     * @return  `String` string formated in cammel case
     */
    private static String toCammelCase(String text) {

        if (String.isBlank(text)) {
        return null;
        }

        String[] atext = text.split('\\s+');
        for (Integer i = 0; i < atext.size(); i++) {
        atext[i] = atext[i].capitalize();
        }
        return String.join(atext, '');
    }
    
}