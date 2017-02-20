classdef VseMitsubaElementMapper < VseElementMapper
    % Map mexximp scene elements to mitsuba elements.
    
    methods
        function buildElementMap(obj, scene, nativeScene)
            obj.clear();
            obj.mapNested(nativeScene);
        end
        
        function mapNested(obj, mitsubaNode)
            if ~isempty(mitsubaNode.extra)
                obj.put(mitsubaNode.extra, mitsubaNode);
            end
            
            for nn = 1:numel(mitsubaNode.nested)
                obj.mapNested(mitsubaNode.nested{nn});
            end
        end
    end
end
