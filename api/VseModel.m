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
            selector = false(1, nMeshes);
            for mm = 1:nMeshes
                selector(mm) = ...
                    ~isempty(regexp(obj.model.meshes(mm).name, namePattern, 'once'));
            end
            obj.areaLightMeshSelector = selector;
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
        function [obj, assetInfo] = fromAsset(assetType, assetName, varargin)
            parser = MipInputParser();
            parser.addRequired('assetType', @ischar);
            parser.addRequired('assetName', @ischar);
            parser.parseMagically('caller');
            
            sceneFiles = vsaGetFiles(assetType, assetName, varargin{:});
            if isempty(sceneFiles)
                obj = [];
                assetInfo = [];
                return;
            end
            
            model = mexximpCleanImport(sceneFiles{1}, varargin{:});
            obj = VseModel(varargin{:}, 'name', assetName, 'model', model);
            
            assetInfo = vsaGetInfo(assetType, assetName, varargin{:});
        end
        
        function model = bigModel(outer, inner)
            parser = MipInputParser();
            parser.addRequired('outer', @(val) isa(val, 'VseModel'));
            parser.addRequired('inner', @(val) isempty(val) || isa(val, 'VseModel'));
            parser.parseMagically('caller');
            
            % get the camera transform of the outer model
            if isempty(outer.model.cameras)
                cameraTransform = mexximpIdentity();
            else
                cameraName = outer.model.cameras(1).name;
                isCameraNode = strcmp(cameraName, {outer.model.rootNode.children.name});
                if any(isCameraNode)
                    cameraNodeIndex = find(isCameraNode, 1, 'first');
                    cameraNode = outer.model.rootNode.children(cameraNodeIndex);
                    cameraTransform = cameraNode.transformation;
                else
                    cameraTransform = mexximpIdentity();
                end
            end
            
            % append each inner scene struct to the outer struct
            %   keep track of which meshes and materials came from each one
            nInner = numel(inner);
            bigModelStruct = outer.model;
            for ii = 1:nInner
                if inner(ii).transformationRelativeToCamera
                    innerTransform = inner(ii).transformation * cameraTransform;
                else
                    innerTransform = inner(ii).transformation;
                end
                
                bigModelStruct = mexximpCombineScenes(bigModelStruct, ...
                    inner(ii).model, ...
                    'insertTransform', innerTransform, ...
                    'insertPrefix', inner(ii).name);
            end
            
            % combine names into one big name
            % combine mesh area light selectors into one big selector
            if isempty(inner)
                bigName = outer.name;
                bigMeshSelector = outer.areaLightMeshSelector;
            else
                uniqueNames = unique({inner.name});
                concatNames = sprintf('_%s', uniqueNames{:});
                bigName = sprintf('%s%s', outer.name, concatNames);

                bigMeshSelector = [outer.areaLightMeshSelector inner.areaLightMeshSelector];
            end
            
            
            % pack it all up
            model = VseModel( ...
                'name', bigName, ...
                'model', bigModelStruct, ...
                'areaLightMeshSelector', bigMeshSelector);
        end
    end
end
