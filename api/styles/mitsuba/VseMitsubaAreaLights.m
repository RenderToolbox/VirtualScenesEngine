classdef VseMitsubaAreaLights < VseStyle
    % Bless meshes as area lights.
    
    properties
        defaultSpectrum = '300:1 800:1';
    end
    
    methods
        function obj = VseMitsubaAreaLights(varargin)
            obj.elementTypeFilter = 'nodes';
            obj.elementNameFilter = 'Light';
            obj.destination = 'Mitsuba';
            
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
        end
        
        % Bless each selected element as an area light.
        function scene = applyToSceneElements(obj, scene, elements, hints)
            
            nElements = numel(elements);
            for ee = 1:nElements
                mitsubaElement = elements{ee};
                
                % nest an emitter inside the shape
                emitterId = [mitsubaElement.id '-emitter'];
                emitter = MMitsubaElement(emitterId, 'emitter', 'area');
                emitter.setProperty('radiance', 'spectrum', obj.defaultSpectrum);
                mitsubaElement.append(emitter);
            end
        end
    end
end
