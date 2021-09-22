@IsTest
public with sharing class MapServiceTest {
    private static final String FEATURE_NAME = 'Place_Search';
    private static final String CONTEXT_NAME = 'map';

    @IsTest
    private static void testGetMapConfig() {
        MapService.setMockConfig(FEATURE_NAME, getConfig());
        MapService.MapConfig mapConfig = MapService.getMapConfig(CONTEXT_NAME, FEATURE_NAME);
        Map<String, Object> config = mapConfig.config;
        
        System.assert(config.containsKey('options'));
        List<Object> options = (List<Object>)config.get('options');
        System.assert(options.size() == 1);

        System.assert(config.containsKey('features'));
        List<Object> features = (List<Object>)config.get('features');
        System.assert(features.size() == 3);

        System.assert(config.containsKey('markerConfigs'));
        List<Object> markerConfigs = (List<Object>)config.get('markerConfigs');
        System.assert(markerConfigs.size() == 2);

        System.assert(config.containsKey('popupConfigs'));
        List<Object> popupConfigs = (List<Object>)config.get('popupConfigs');
        System.assert(popupConfigs.size() == 1);

        System.assert(config.containsKey('tooltipConfigs'));
        List<Object> tooltipConfigs = (List<Object>)config.get('tooltipConfigs');
        System.assert(tooltipConfigs.size() == 1);
    }

    private static String getConfig() {
        return '{"map":{"options":[{"name":"tap","value":false}],"features":[{"name":"tileLayer","urlTemplate":"","options":[]},{"name":"geolocation","showMarker":true,' + 
            '"markerConfig":"user","options":[{"name":"setView","value":true},{"name":"maxZoom","value":13},{"name":"enableHighAccuracy","value":true}]},{"name":"places",' + 
            '"markerConfig":"place"}],"markerConfigs":[{"name":"user","tooltipConfig":"user","options":[{"name":"title","value":"You"},{"name":"icon","function":"return icons.standardRed;"}]},' + 
            '{"name":"place","coordinatesFunction":"return [place.geometry.location.lat, place.geometry.location.lng];","options":[{"name":"title","function":"return place.name;"},' + 
            '{"name":"icon","function":"return icons.standardBlue;"}],"popupConfig":"place"}],"popupConfigs":[{"name":"place","contentFunction":"return \'<b>\' + place.name + \'</b><br>\' + place.formatted_address",' + 
            '"options":[{"name":"closeButton","value":false}]}],"tooltipConfigs":[{"name":"user","content":"You are here","options":[]}],"customIcons":[{"name":"","options":[]}]}}';
    }
}
