classdef VseStyle < handle
    % Reusable interface for adding materials, lights, etc. to a model.
    
    properties
        name = '';
        destination = '';
        
        applyToOuterModels = true;
        applyToInnerModels = true;
        modelNameFilter = '';
        
        elementTypeFilter = '';
        elementNameFilter = '';
    end
    
    methods
        % Modify the whole scene.
        function scene = applyToWholeScene(obj, scene, hints)
        end
        
        % Modify the mexximp or native scene for selected elements.
        function scene = applyToSceneElements(obj, scene, elements, hints)
        end
        
        
        %% Copy resource to the "resources" folder for the given RTB hints.
        function [resolvedName, resolvedFullPath] = resolveResource(obj, resourceName, hints, varargin)
            workingFolder = rtbWorkingFolder( ...
                'rendererSpecific', false, ...
                'hints', hints);
            resolvedName = mexximpResolveResource(resourceName, ...
                'strictMatching', true, ...
                'useMatlabPath', true, ...
                'sourceFolder', workingFolder, ...
                'outputFolder', workingFolder, ...
                'outputPrefix', 'resources', ...
                varargin{:});
            resolvedFullPath = fullfile(workingFolder, resolvedName);
        end
        
        
        %% Recode an image resource as an exr file.
        function [recodedName, recodedFullPath] = recodeImage(obj, resoiurceFullPath, hints, varargin)
            [~, ~, resourceExt] = fileparts(resoiurceFullPath);
            recodedFullPath = mexximpRecodeImage(resoiurceFullPath, ...
                'toReplace', {resourceExt(2:end)}, ...
                'targetFormat', 'exr', ...
                varargin{:});
            recodedName = rtbGetWorkingRelativePath(recodedFullPath, 'hints', hints);
        end
        
        
        %% Filter elements for this style.
        function elementInfo = selectElements(obj, elementInfo)
            
            % coarse filter for inner vs outer model
            nElements = numel(elementInfo);
            if obj.applyToOuterModels
                if obj.applyToInnerModels
                    % apply to both
                    inOutSelector = true(1, nElements);
                else
                    % apply only to outer
                    inOutSelector = ~[elementInfo.isInner];
                end
            else
                if obj.applyToInnerModels
                    % apply only to inner
                    inOutSelector = [elementInfo.isInner];
                else
                    % apply to neither!
                    inOutSelector = false(1, nElements);
                end
            end
            
            elementInfo = elementInfo(inOutSelector);
            if isempty(elementInfo)
                return;
            end
            
            % coarse filter by model names
            modelNameSelector = VseStyle.selectByFilter( ...
                {elementInfo.modelName}, obj.modelNameFilter);
            
            elementInfo = elementInfo(modelNameSelector);
            if isempty(elementInfo)
                return;
            end
            
            % fine filter by element types
            elementTypeSelector = VseStyle.selectByFilter( ...
                {elementInfo.type}, obj.elementTypeFilter);
            
            elementInfo = elementInfo(elementTypeSelector);
            if isempty(elementInfo)
                return;
            end
            
            % fine filter by element names
            elementNameSelector = VseStyle.selectByFilter( ...
                {elementInfo.name}, obj.elementNameFilter);
            
            elementInfo = elementInfo(elementNameSelector);
        end
    end
    
    methods (Static)
        function isMatch = selectByFilter(strings, filter)
            if isempty(filter)
                isMatch = true(size(strings));
                return;
            end
            
            isMatch = cellfun( ...
                @(string) ~isempty(regexp(string, filter, 'once')), ...
                strings, ...
                'UniformOutput', true);
        end
    end
end
