classdef VsePbrtAreaLights < VseStyle
    % Bless meshes as area lights.
    
    properties
        defaultSpectrum = '300:1 800:1';
        areaLightTemplate;
    end
    
    methods
        function obj = VsePbrtAreaLights(varargin)
            obj.elementTypeFilter = 'nodes';
            obj.elementNameFilter = 'Light';
            obj.destination = 'PBRT';
            
            areaLight = MPbrtElement('AreaLightSource', ...
                'name', 'template', ...
                'type', 'diffuse');
            areaLight.setParameter('nsamples', 'integer', 8);
            obj.areaLightTemplate = areaLight;
            
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
        end
        
        function areaLight = newAreaLight(obj, name)
            areaLight = MPbrtElement(obj.areaLightTemplate.identifier, ...
                'type', obj.areaLightTemplate.type);
            areaLight.parameters = obj.areaLightTemplate.parameters;
            areaLight.setParameter('L', 'spectrum', obj.defaultSpectrum);
            areaLight.name = name;
        end
        
        % Bless each selected element as an area light.
        function scene = applyToSceneElements(obj, scene, elements, hints)
            
            nElements = numel(elements);
            for ee = 1:nElements
                % attribute contians a transformation and an ObjectInstance
                attribute = elements{ee};
                
                % don't need the ObjectInstance any more
                attribute.find('ObjectInstance', 'remove', true);
                
                % instead, use an AreaLightSource based on template
                areaLight = obj.newAreaLight(attribute.name);
                attribute.append(areaLight);
                
                % find the original object declaration
                object = scene.world.find('Object', 'name', attribute.name);
                
                % use the same material for this area light
                material = object.find('NamedMaterial');
                attribute.append(material);
                
                % use the same geometry for this area light
                include = object.find('Include');
                attribute.append(include);
            end
        end
    end
end
