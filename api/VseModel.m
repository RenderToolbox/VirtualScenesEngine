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
            
            if isempty(obj.areaLightMeshSelector)
                obj.selectAreaLightsNone();
            end
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
    
    methods (Static)
        function [model, allMeshes, allMaterials, allMeshSelectors] = bigModel(outer, inner)
            parser = MipInputParser();
            parser.addRequired('outer', @(val) isa(val, 'VseModel'));
            parser.addRequired('inner', @(val) isa(val, 'VseModel'));
            parser.parseMagically('caller');
            
            % get the camera transform of the outer model
            if isempty(outer.model.cameras)
                cameraTransform = mexximpIdentity();
            else
                cameraName = outer.model.cameras(1).name;
                isCameraNode = strcmp(cameraName, {outer.model.rootNode.children.name});
                if any(isCameraNode)
                    cameraNodeIndex = find(isCamreraNode, 1, 'first');
                    cameraNode = outer.model.rootNode.children(cameraNodeIndex);
                    cameraTransform = cameraNode.transform;
                else
                    cameraTransform = mexximpIdentity();
                end
            end
            
            % append each inner scene struct to the outer struct
            %   keep track of which meshes and materials came from each one
            nInner = numel(inner);
            innerMaterials = cell(1, nInner);
            innerMeshes = cell(1, nInner);
            innerMeshSelectors = cell(1, nInner);
            bigModelStruct = outer.model;
            for ii = 1:nInner
                if inner(ii).transformationRelativeToCamera
                    innerTransform = inner(ii).transform * cameraTransform;
                else
                    innerTransform = inner(ii).transform;
                end
                
                bigModelStruct = mexximpCombineScenes(bigModelStruct, ...
                    inner(ii).model, ...
                    'insertTransform', innerTransform, ...
                    'insertPrefix', inner(ii).name);
                
                innerMeshes{ii} = inner(ii).model.meshes;
                innerMaterials{ii} = inner(ii).model.materials;
                innerMeshSelectors = inner(ii).areaLightMeshSelector;
            end
            allMeshes = cat(2, {outer.model.meshes}, innerMeshes);
            allMaterials = cat(2, {outer.model.materials}, innerMaterials);
            allMeshSelectors = cat(2, {outer.areaLightMeshSelector}, innerMeshSelectors);
            
            % combine names into one big name
            uniqueNames = unique({inner.name});
            concatNames = sprintf('+%s', uniqueNames{:});
            bigName = sprintf('%s%s', outer.name, concatNames);
            
            % combine mesh area light selectors into one big selector
            bigMeshSelector = [outer.areaLightMeshSelector inner.areaLightMeshSelector];
            
            % pack it all up
            model = VseModel( ...
                'name', bigName, ...
                'model', bigModelStruct, ...
                'areaLightMeshSelector', bigMeshSelector);
        end
    end
end
