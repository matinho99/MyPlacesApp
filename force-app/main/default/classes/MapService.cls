public with sharing class MapService {
    private static final String LEAFLET_RESOURCE_PATH = Pagereference.forResource('leaflet').getUrl().substringBefore('?');
    private static final String STANDARD_MARKER_SHADOW_PATH = LEAFLET_RESOURCE_PATH + '/images/marker-shadow.png';
    private static final List<StandardIcon> STANDARD_ICONS = new List<StandardIcon> {
        new StandardIcon('standardBlack', '/images/marker-icon-black.png', '/images/marker-icon-2x-black.png'),
        new StandardIcon('standardBlue', '/images/marker-icon.png', '/images/marker-icon-2x.png'),
        new StandardIcon('standardGreen', '/images/marker-icon-green.png', '/images/marker-icon-2x-green.png'),
        new StandardIcon('standardGrey', '/images/marker-icon-grey.png', '/images/marker-icon-2x-grey.png'),
        new StandardIcon('standardOrange', '/images/marker-icon-orange.png', '/images/marker-icon-2x-orange.png'),
        new StandardIcon('standardRed', '/images/marker-icon-red.png', '/images/marker-icon-2x-red.png'),
        new StandardIcon('standardViolet', '/images/marker-icon-violet.png', '/images/marker-icon-2x-violet.png'),
        new StandardIcon('standardYellow', '/images/marker-icon-yellow.png', '/images/marker-icon-2x-yellow.png')
    };
    private static Map<String, Feature_Setting__mdt> mockConfigs = new Map<String, Feature_Setting__mdt>();

    @AuraEnabled(cacheable = true)
    public static MapConfig getMapConfig(String contextName, String featureName) {
        MapConfig config;

        try {
            config = new MapConfig(contextName, featureName);
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

        if(settings != null && !settings.isEmpty()) {
            Map<String, Object> setting = (Map<String, Object>)JSON.deserializeUntyped(settings[0].Properties_JSON__c);
            config = setting.containsKey(contextName) ? (Map<String, Object>)setting.get(contextName) : null;
        }

        return config;
    }

    @TestVisible
    private static void setMockConfig(String name, String config) {
        mockConfigs.put(name, new Feature_Setting__mdt( DeveloperName = name, Properties_JSON__c = config ));
    } 

    public class MapConfig {
        @AuraEnabled
        public Map<String,Object> config;

        @AuraEnabled
        public List<StandardIcon> standardIcons;

        public MapConfig(String contextName, String featureName) {
            this.config = getConfig(contextName, featureName);
            this.standardIcons = STANDARD_ICONS;
        }
    }

    public class StandardIcon {
        @AuraEnabled
        public String name;

        @AuraEnabled
        public String iconUrl;

        @AuraEnabled
        public String iconRetinaUrl;

        @AuraEnabled
        public String shadowUrl;

        public StandardIcon(String name, String iconPath, String iconRetinaPath) {
            this.name = name;
            this.iconUrl = LEAFLET_RESOURCE_PATH + iconPath;
            this.iconRetinaUrl = LEAFLET_RESOURCE_PATH + iconRetinaPath;
            this.shadowUrl = STANDARD_MARKER_SHADOW_PATH;
        }
    }
}
