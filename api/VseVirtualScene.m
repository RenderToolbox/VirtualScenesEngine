
classdef VseVirtualScene < handle
    % An outer Combo with multiple inner Combos.
    
    properties
        name;
        outerCombo;
        innerCombos;
        innerTransforms;
    end
    
    methods
        function obj = VseVirtualScene(outerCombo, varargin)
            parser = MipInputParser();
            parser.addRequired('outerCombo', @(val) isa(val, 'VseCombo'));
            parser.addParameter('name', '', @ischar);
            parser.parseMagically(obj);
            
            if isempty(obj.name)
                obj.name = obj.outerCombo.name;
            end
        end
        
        function addInnerCombo(obj, innerCombo, innerTransform)
            parser = MipInputParser();
            parser.addRequired('innerCombo', @(val) isa(val, 'VseCombo'));
            parser.addRequired('innerTransform', @isnumeric);
            parser.parseMagically('caller');
            
            if isempty(obj.innerCombos)
                obj.innerCombos = innerCombo;
                obj.innerTransforms = innerTransform;
            else
                obj.innerCombos(end+1) = innerCombo;
                obj.innerTransforms(end+1) = innerTransform;
            end
        end
        
        function model = bigModel(obj)
            model = obj.outerCombo.model;
            for cc = 1:numel(obj.innerCombos)
                combo = obj.innerCombos(cc);
                transform = obj.innerTransforms(cc);
                model = mexximpCombineScenes(model, combo.model, ...
                    'insertTransform', transform, ...
                    'insertPrefix', combo.name);
            end
        end
        
        function combos = allCombos(obj)
            combos = cat(2, obj.outerCombo, obj.innerCombos);
        end
        
        function nStyles = styleCount(obj)
            nStyles = numel(obj.outerCombo.styles);
            for ss = 1:numel(obj.innerCombos)
                nStyles = max(nStyles, numel(obj.innerCombos(ss).styles));
            end
        end
        
        function bigName = bigStyleName(obj, styleIndex)
            combos = obj.allCombos();
            nCombos = numel(combos);
            comboNames = cell(nCombos);
            for cc = 1:nCombos
                combo = combos(cc);
                style = combo.getWrappedStyles(styleIndex);
                comboNames{cc} = style.name;
            end
            uniqueNames = unique(comboNames);
            concatNames = sprintf('_%s', uniqueNames{:});
            bigName = sprintf('%d%s', styleIndex, concatNames);
        end
        
        function bigConfig = bigRendererConfig(obj, styleIndex)
            combos = obj.allCombos();
            nCombos = numel(combos);
            configs = cell(nCombos);
            for cc = 1:nCombos
                configs{cc} = combos(cc).getWrappedStyles(styleIndex).rendererConfig;
            end
            bigConfig = [configs{:}];
        end
        
        function [bigMaterials, bigIndices] = bigMaterialValues(obj, styleIndex)
            combos = obj.allCombos();
            nCombos = numel(combos);
            materials = cell(1, nCombos);
            indices = cell(1, nCombos);
            indexOffset = 0;
            for cc = 1:nCombos
                combo = combos(cc);
                model = combo.model;
                style = combo.getWrappedStyles(styleIndex);
                
                nMaterials = numel(model.materials);
                allMaterials = 1:nMaterials;
                indices{cc} = indexOffset + allMaterials;
                indexOffset = indexOffset + nMaterials;
                
                materials{cc} = style.getWrappedValues('materials', allMaterials);
            end
            
            bigMaterials = [materials{:}];
            bigIndices = [indices{:}];
        end
        
        function [bigIlluminants, bigIndices] = bigIlluminantValues(obj, styleIndex)
            combos = obj.allCombos();
            nCombos = numel(combos);
            illuminants = cell(1, nCombos);
            indices = cell(1, nCombos);
            indexOffset = 0;
            for cc = 1:nCombos
                combo = combos(cc);
                model = combo.model;
                style = combo.getWrappedStyles(styleIndex);
                
                nMeshes = numel(model.meshes);
                meshSelector = style.getWrappedValues('meshIlluminantSelector', 1:nMeshes);
                selectedMeshes = find(meshSelector);
                
                indices{cc} = indexOffset + selectedMeshes;
                indexOffset = indexOffset + nMeshes;
                
                illuminants{cc} = style.getWrappedValues('illuminants', selectedMeshes);
            end
            
            bigIlluminants = [illuminants{:}];
            bigIndices = [indices{:}];
        end
    end
end
