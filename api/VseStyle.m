classdef VseStyle < handle
    % Reusable declaration of materials, lights, etc.
    
    properties
        name;
        materials;
        illuminants;
        meshIlluminantSelector;
        rendererConfig;
    end
    
    methods
        function obj = VseStyle(name)
            parser = MipInputParser();
            parser.addRequired('name', @ischar);
            parser.parseMagically(obj);
        end
        
        function values = getWrappedValues(obj, fieldName, indices)
            parser = MipInputParser();
            parser.addRequired('fieldName', MipInputParser.isAny('materials', 'illuminants', 'meshIlluminantSelector'));
            parser.addRequired('indices', @isnumeric);
            parser.parseMagically('caller');
            
            fieldValues = obj.(fieldName);
            wrappedIndices = 1 + mod(indices - 1, numel(fieldValues));
            values = fieldValues(wrappedIndices);
        end
        
        function addValue(obj, fieldName, styleValue)
            parser = MipInputParser();
            parser.addRequired('fieldName', MipInputParser.isAny('materials', 'illuminants', 'rendererConfig'));
            parser.addRequired('styleValue', @(val) isa(val, 'VseStyleValue'));
            parser.parseMagically('caller');
            
            fieldValues = obj.(fieldName);
            if isempty(fieldValues)
                fieldValues = styleValue;
            else
                fieldValues(end+1) = styleValue;
            end
            obj.(fieldName) = fieldValues;
        end
        
        function setMeshIlluminantSelector(obj, meshIlluminantSelector)
            parser = MipInputParser();
            parser.addRequired('meshIlluminantSelector', @islogical);
            parser.parseMagically(obj);
        end
        
        function addManyMaterials(obj, reflectances)
            parser = MipInputParser();
            parser.addRequired('reflectances', @iscell);
            parser.addParameter('specificType', 'matte', @ischar);
            parser.addParameter('destination', 'Generic', @ischar);
            parser.addParameter('propertyName', 'diffuseReflectance', @ischar);
            parser.addParameter('propertyValueType', 'spectrum', @ischar);
            parser.parseMagically('caller');
            
            for rr = 1:numel(reflectances)
                obj.addValue('materials', ...
                    VseStyleValue(specificType, 'destination', destination) ...
                    .withProperty(propertyName, propertyValueType, reflectances{rr}));
            end
        end
        
        function addManyIlluminants(obj, illuminants)
            parser = MipInputParser();
            parser.addRequired('illuminants', @iscell);
            parser.addParameter('specificType', '', @ischar);
            parser.addParameter('destination', 'Generic', @ischar);
            parser.addParameter('propertyName', 'intensity', @ischar);
            parser.addParameter('propertyValueType', 'spectrum', @ischar);
            parser.parseMagically('caller');
            
            for rr = 1:numel(illuminants)
                obj.addValue('illuminants', ...
                    VseStyleValue(specificType, 'destination', destination) ...
                    .withProperty(propertyName, propertyValueType, illuminants{rr}));
            end
        end
    end
end
