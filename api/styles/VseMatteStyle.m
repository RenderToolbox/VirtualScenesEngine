classdef VseMatteStyle < VseStyle
    % Apply generic matte materials based on a list of spectra.
    
    properties
        spectra = {'300:1 800:1'};
    end
    
    methods
        function obj = VseMatteStyle(varargin)
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
            
            obj.elementTypeFilter = 'materials';
        end
        
        function scene = applyToSceneElements(obj, scene, elements, hints)
            % make generic mappings given material elements
            nElements = numel(elements);
            spectraIndices = 1 + mod((1:nElements) - 1, numel(obj.spectra));
            spectrumProperties = struct( ...
                'name', 'diffuseReflectance', ...
                'valueType', 'spectrum', ...
                'value', obj.spectra(spectraIndices));
            mappings = rtbValidateMappings(struct( ...
                'destination', 'Generic', ...
                'broadType', 'materials', ...
                'specificType', 'matte', ...
                'name', {elements.name}, ...
                'operation', 'update', ...
                'properties', spectrumProperties));
            
            % apply mappings to the scene, via the existing converter
            scene = hints.batchRenderStrategy.converter.applyMappings( ...
                [], scene, mappings, {}, {}, []);
        end
    end
end
