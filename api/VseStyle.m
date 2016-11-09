classdef VseStyle < handle
    % Reusable declaration of materials, spectra, renderer config.
    
    properties
        name;
        materials;
        illuminants;
        rendererConfig;
    end
    
    methods
        function obj = VseStyle(varargin)
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
        end
        
        function values = getWrappedValues(obj, fieldName, indices)
            parser = MipInputParser();
            parser.addRequired('fieldName', MipInputParser.isAny('materials', 'illuminants'));
            parser.addRequired('indices', @isnumeric);
            parser.parseMagically('caller');
            
            fieldValues = obj.(fieldName);
            if isempty(fieldValues)
                values = [];
            else
                wrappedIndices = 1 + mod(indices - 1, numel(fieldValues));
                if obj.shuffle
                    wrappedIndices = wrappedIndices(randperm(numel(wrappedIndices)));
                end
                values = fieldValues(wrappedIndices);
            end
        end
        
        function addMaterial(obj, material)
            parser = MipInputParser();
            parser.addRequired('mapping', @(val) isa(val, 'VseMapping'));
            parser.parseMagically('caller');
            
            if isempty(obj.materials)
                obj.materials = material;
            else
                obj.materials(end+1) = material;
            end
        end
        
        function addIlluminant(obj, illuminant)
            parser = MipInputParser();
            parser.addRequired('mapping', @(val) isa(val, 'VseMapping'));
            parser.parseMagically('caller');
            
            if isempty(obj.illuminants)
                obj.illuminants = illuminant;
            else
                obj.illuminants(end+1) = illuminant;
            end
        end
        
        function addRendererConfig(obj, config)
            parser = MipInputParser();
            parser.addRequired('config', @(val) isa(val, 'VseMapping'));
            parser.parseMagically('caller');
            
            if isempty(obj.rendererConfig)
                obj.rendererConfig = {config};
            else
                obj.rendererConfig{end+1} = config;
            end
        end
        
        function addManyMaterials(obj, reflectances)
            parser = MipInputParser();
            parser.addRequired('reflectances', @iscell);
            parser.addParameter('broadType', 'materials', @ischar);
            parser.addParameter('specificType', 'matte', @ischar);
            parser.addParameter('destination', 'Generic', @ischar);
            parser.addParameter('propertyName', 'diffuseReflectance', @ischar);
            parser.addParameter('propertyValueType', 'spectrum', @ischar);
            parser.parseMagically('caller');
            
            for rr = 1:numel(reflectances)
                obj.addMaterial( ...
                    VseMapping( ...
                    'broadType', broadType, ...
                    'specificType', specificType, ...
                    'destination', destination) ...
                    .withProperty(propertyName, propertyValueType, reflectances{rr}));
            end
        end
        
        function addManyTextureMaterials(obj, textures)
            parser = MipInputParser();
            parser.addRequired('textures', @iscell);
            parser.addParameter('broadType', 'materials', @ischar);
            parser.addParameter('specificType', 'matte', @ischar);
            parser.addParameter('destination', 'Generic', @ischar);
            parser.addParameter('propertyName', 'diffuseReflectance', @ischar);
            parser.addParameter('propertyValueType', 'texture', @ischar);
            parser.parseMagically('caller');
            
            for tt = 1:numel(textures)
                % create a texture
                [~, textureName] = fileparts(textures{tt});
                texture = VseMapping( ...
                    'name', textureName, ...
                    'broadType', 'spectrumTextures', ...
                    'specificType', 'bitmap', ...
                    'operation', 'create') ...
                    .withProperty('filename', 'string', textures{tt});
                obj.addRendererConfig(texture);
                
                % wire a material to the texture
                obj.addMaterial( ...
                    VseMapping( ...
                    'broadType', broadType, ...
                    'specificType', specificType, ...
                    'destination', destination) ...
                    .withProperty(propertyName, propertyValueType, textureName));
            end
        end
        
        function addManyIlluminants(obj, illuminants)
            parser = MipInputParser();
            parser.addRequired('illuminants', @iscell);
            parser.addParameter('broadType', 'meshes', @ischar);
            parser.addParameter('specificType', '', @ischar);
            parser.addParameter('destination', 'Generic', @ischar);
            parser.addParameter('propertyName', 'intensity', @ischar);
            parser.addParameter('propertyValueType', 'spectrum', @ischar);
            parser.parseMagically('caller');
            
            for rr = 1:numel(illuminants)
                obj.addIlluminant( ...
                    VseMapping( ...
                    'broadType', broadType, ...
                    'specificType', specificType, ...
                    'destination', destination) ...
                    .withProperty(propertyName, propertyValueType, illuminants{rr}));
            end
        end
    end
end
