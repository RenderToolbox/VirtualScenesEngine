classdef VseModel < handle
    % Combination of a 3D model plus info to help combine with others.
    
    properties
        name = '';
        model;
        areaLightMeshSelector;
        transformation = mexximpIdentity();
        transformationRelativeToCamera = false;
    end
    
    methods
        function obj = VseModel(varargin)
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
            
            obj.selectAreaLightsNone();
        end
        
        function selectAreaLightsByName(obj, namePattern)
            if isempty(obj.model)
                return;
            end
            nMeshes = numel(obj.model.meshes);
            obj.areaLightMeshSelector = false(1, nMeshes);
            for mm = 1:nMeshes
                obj.areaLightMeshSelector = ...
                    ~isempty(regexp(obj.meshes(mm).name, namePattern, 'once'));
            end
        end
        
        function selectAreaLightsAll(obj)
            if isempty(obj.model)
                return;
            end
            nMeshes = numel(obj.model.meshes);
            obj.areaLightMeshSelector = true(1, nMeshes);
        end
        
        function selectAreaLightsNone(obj)
            if isempty(obj.model)
                return;
            end
            nMeshes = numel(obj.model.meshes);
            obj.areaLightMeshSelector = false(1, nMeshes);
        end
    end
end
