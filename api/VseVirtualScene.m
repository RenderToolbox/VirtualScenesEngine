classdef VseVirtualScene < handle
    
    methods
        
        function model = bigModel(obj)
            model = obj.outerCombo.model;
            for cc = 1:numel(obj.innerCombos)
                combo = obj.innerCombos(cc);
                transform = obj.innerTransforms{cc};
                model = mexximpCombineScenes(model, combo.model, ...
                    'insertTransform', transform, ...
                    'insertPrefix', combo.name);
            end
        end
        
        function bigName = bigStyleName(obj, styleIndex)
            combos = obj.allCombos();
            nCombos = numel(combos);
            comboNames = cell(1, nCombos);
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
            configs = cell(1, nCombos);
            for cc = 1:nCombos
                configs{cc} = combos(cc).getWrappedStyles(styleIndex).rendererConfig;
            end
            bigConfigCell = cat(2, configs{:});
            if isempty(bigConfigCell)
                bigConfig = [];
                return;
            end
            
            bigConfig = [bigConfigCell{:}];
            if isempty(bigConfig)
                return;
            end
            
            % TODO: don't know there will be a name field yet...
            [~, order] = unique({bigConfig.name});
            bigConfig = bigConfig(order);
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
        
        function [bigIlluminants, bigIndices, bigNames] = bigIlluminantValues(obj, styleIndex)
            combos = obj.allCombos();
            nCombos = numel(combos);
            illuminants = cell(1, nCombos);
            indices = cell(1, nCombos);
            names = cell(1, nCombos);
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
                
                names{cc} = {model.meshes(meshSelector).name};
                
                illuminants{cc} = style.getWrappedValues('illuminants', selectedMeshes);
            end
            
            bigIlluminants = [illuminants{:}];
            bigIndices = [indices{:}];
            bigNames = cat(2, names{:});
        end
    end
end
