classdef VseModel < handle
    % Combination of a 3D model plus info to help combine with others.
    
    properties
        name = '';
        model;
        transformation = mexximpIdentity();
        transformationRelativeToCamera = false;
    end
    
    methods
        function obj = VseModel(varargin)
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
        end
        
        function duplicate = copy(obj, varargin)
            duplicate = VseModel( ...
                'name', obj.name, ...
                'model', obj.model, ...
                'transformation', obj.transformation, ...
                'transformationRelativeToCamera', obj.transformationRelativeToCamera, ...
                varargin{:});
        end
    end
    
    methods (Static)
        function [obj, assetInfo] = fromAsset(assetType, assetName, varargin)
            parser = MipInputParser();
            parser.addRequired('assetType', @ischar);
            parser.addRequired('assetName', @ischar);
            parser.parseMagically('caller');
            
            sceneFiles = aioGetFiles(assetType, assetName, varargin{:});
            if isempty(sceneFiles)
                obj = [];
                assetInfo = [];
                return;
            end
            
            model = mexximpCleanImport(sceneFiles{1}, varargin{:});
            obj = VseModel(varargin{:}, ...
                'name', assetName, ...
                'model', model);
            
            assetInfo = aioGetInfo(assetType, assetName, varargin{:});
        end
        
        function [model, elementInfo] = combine(outer, inner)
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
            % track which elements came from which model
            nInner = numel(inner);
            bigModelStruct = outer.model;
            innerElementInfo = cell(1, nInner);
            for ii = 1:nInner
                if inner(ii).transformationRelativeToCamera
                    innerTransform = inner(ii).transformation * cameraTransform;
                else
                    innerTransform = inner(ii).transformation;
                end
                
                [bigModelStruct, ~, innerElements] = ...
                    mexximpCombineScenes(bigModelStruct, inner(ii).model, ...
                    'insertTransform', innerTransform, ...
                    'insertPrefix', inner(ii).name);
                
                innerElementInfo{ii} = VseModel.elementInfo(...
                    innerElements, inner(ii).name, true);
            end
            
            % combine names into one big name
            if isempty(inner)
                bigName = outer.name;
            else
                uniqueNames = unique({inner.name});
                concatNames = sprintf('_%s', uniqueNames{:});
                bigName = sprintf('%s%s', outer.name, concatNames);
            end
            
            % pack up the big model
            model = VseModel( ...
                'name', bigName, ...
                'model', bigModelStruct);
            
            % pack up the info about all the elements
            outerElements = mexximpSceneElements(outer.model);
            outerElementInfo = VseModel.elementInfo(outerElements, outer.name, false);
            elementInfo = [outerElementInfo, innerElementInfo{:}];
        end
    end
    
    methods (Static)
        %% Organize elements to make it easy to filter them later.
        function info = elementInfo(elements, modelName, isInner)
            info = elements;
            [info.modelName] = deal(modelName);
            [info.isInner] = deal(isInner);
        end
    end
end
