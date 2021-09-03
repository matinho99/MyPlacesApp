public with sharing class TilesListService {
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
        List<Feature_Setting__mdt> settings = [SELECT Properties_JSON__c FROM Feature_Setting__mdt WHERE DeveloperName = :featureName];

        if(!settings.isEmpty()) {
            Map<String, Object> setting = (Map<String, Object>)JSON.deserializeUntyped(settings[0].Properties_JSON__c);
            config = setting.containsKey(contextName) ? (Map<String, Object>)setting.get(contextName) : null;
        }

        return config;
    }

    public class TilesListConfig {
        @AuraEnabled
        public Map<String,Object> config;

        public TilesListConfig(String contextName, String featureName) {
            this.config = getConfig(contextName, featureName);
        }
    }
}
