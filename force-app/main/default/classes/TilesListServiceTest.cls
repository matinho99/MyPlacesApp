@IsTest
public with sharing class TilesListServiceTest {
    private static final String FEATURE_NAME = 'Place_Search';
    private static final String CONTEXT_NAME = 'placesList';

    @IsTest
    private static void testGetTilesListConfig() {
        TilesListService.setMockConfig(FEATURE_NAME, getConfig());
        TilesListService.TilesListConfig tilesListConfig = TilesListService.getTilesListConfig(CONTEXT_NAME, FEATURE_NAME);
        Map<String, Object> config = tilesListConfig.config;
        
        System.assert(config.containsKey('isHorizontal'));
        System.assert(!((Boolean)config.get('isHorizontal')));

        System.assert(config.containsKey('tileLayout'));
        Map<String, Object> tileLayout = (Map<String, Object>)config.get('tileLayout');
        System.assert(tileLayout.containsKey('headerImageUrlFieldName'));
        System.assertEquals('photo_url', tileLayout.get('headerImageUrlFieldName'));

        System.assert(tileLayout.containsKey('fields'));
        List<Object> fields = (List<Object>)tileLayout.get('fields');
        System.assert(fields.size() == 3);

        System.assert(tileLayout.containsKey('actions'));
        List<Object> actions = (List<Object>)tileLayout.get('actions');
        System.assert(actions.size() == 2);
    }

    private static String getConfig() {
        return '{"placesList":{"isHorizontal":false,"tileLayout":{"headerImageUrlFieldName":"photo_url","titleFieldName":"name","titleStyle":"","fields":[{"name":"formatted_address",' + 
            '"label":"","icon":"checkin","type":"address"},{"name":"international_phone_number","label":"","icon":"call","type":"phone"},{"name":"website","label":"","icon":"world", ' + 
            '"type":"url"}],"actions":[{"name":"open","label":"Open","icon":"new_window","hasIconTop":true,"buttonClass":"","buttonStyle":"line-height: normal;"},{"name":"addToList", ' + 
            '"label":"Add to List","icon":"add","hasIconTop":true,"buttonClass":"","buttonStyle":"line-height: normal;"}]}}}';
    }
}
