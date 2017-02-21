classdef VsePbrtElementMapper < VseElementMapper
    % Map mexximp scene elements to pbrt elements.
    
    methods
        function buildElementMap(obj, scene, nativeScene)
            obj.clear();
            obj.mapNested(nativeScene);
        end
        
        function mapNested(obj, pbrtNode)
            if ~isempty(pbrtNode.extra)
                obj.put(pbrtNode.extra, pbrtNode);
            end
            
            if isprop(pbrtNode, 'nested')
                for nn = 1:numel(pbrtNode.nested)
                    obj.mapNested(pbrtNode.nested{nn});
                end
            end
        end
    end
end
