classdef VseStyle < handle
    % Reusable interface for adding materials, lights, etc. to a model.
    
    properties
        name;
        destination;
        
        modelNameFilter;
        applyToOuterModels = true;
        applyToInnerModels = true;
        
        elementNameFilter;
        elementTypeFilter;
    end
    
    methods
        % Modify the whole scene.
        function scene = applyToWholeScene(obj, scene, hints)
        end
        
        % Modify one mexximp or native scene element.
        function scene = applyToSceneElements(obj, scene, elements, hints)
        end
        
        %% Filter elements for this style.
        function elements = selectElements(obj, filterInfo)
            
            % coarse filter for inner vs outer model
            outerSelector = obj.applyToOuterModels & ~[filterInfo.isInner];
            innerSelector = obj.applyToInnerModels & [filterInfo.isInner];
            selector = outerSelector | innerSelector;
            filterInfo = filterInfo(selector);
                        
            % coarse filter by model names
            if ~isempty(obj.modelNameFilter)
                modelNames = {filterInfo.modelName};
                isNameModelMatch = cellfun( ...
                    @(name) ~isempty(regexp(name, obj.modelNameFilter, 'once')), ...
                    modelNames);
                filterInfo = filterInfo(isNameModelMatch);
            end
            
            if isempty(filterInfo)
                elements = [];
                return;
            end
            elements = [filterInfo.elements];
            
            % fine filter by element types
            if ~isempty(obj.elementTypeFilter)
                elementTypes = {elements.type};
                isTypeMatch = strcmp(elementTypes, obj.elementTypeFilter);
                elements = elements(isTypeMatch);
            end
            
            % fine filter by element names
            if ~isempty(obj.elementNameFilter)
                elementNames = {elements.name};
                isNameMatch = cellfun( ...
                    @(name) ~isempty(regexp(name, obj.elementTypeFilter, 'once')), ...
                    elementNames);
                elements = elements(isNameMatch);
            end
        end
    end
    
    methods (Static)
        %% Organize elements to make it easy to filter them later.
        function info = elementFilterInfo(modelNames, elements, isInner)
            info = struct( ...
                'modelName', modelNames, ...
                'elements', elements, ...
                'isInner', isInner);
        end
    end
end
