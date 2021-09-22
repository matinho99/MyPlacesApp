public with sharing class TilesListService {
    private static Map<String, Feature_Setting__mdt> mockConfigs = new Map<String, Feature_Setting__mdt>();

    @AuraEnabled(cacheable = true)
    public static TilesListConfig getTilesListConfig(String contextName, String featureName) {
        TilesListConfig config;

        try {
            config = new TilesListConfig(contextName, featureName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return config;
    }

    private static Map<String, Object> getConfig(String contextName, String featureName) {
        Map<String, Object> config;
        List<Feature_Setting__mdt> settings;

        if(!Test.isRunningTest()){
            settings = [SELECT Properties_JSON__c FROM Feature_Setting__mdt WHERE DeveloperName = :featureName];
        } else {
            settings = new List<Feature_Setting__mdt>();

            if(mockConfigs.containsKey(featureName)) {
                settings.add(mockConfigs.get(featureName));
            }
        }

        if(!settings.isEmpty()) {
            Map<String, Object> setting = (Map<String, Object>)JSON.deserializeUntyped(settings[0].Properties_JSON__c);
            config = setting.containsKey(contextName) ? (Map<String, Object>)setting.get(contextName) : null;
        }

        return config;
    }

    @TestVisible
    private static void setMockConfig(String name, String config) {
        mockConfigs.put(name, new Feature_Setting__mdt( DeveloperName = name, Properties_JSON__c = config ));
    } 

    public class TilesListConfig {
        @AuraEnabled
        public Map<String,Object> config;

        public TilesListConfig(String contextName, String featureName) {
            this.config = getConfig(contextName, featureName);
        }
    }
}
