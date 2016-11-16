classdef VseRecipeTests < matlab.unittest.TestCase
    % Test basic behaviors for building RenderToolbox recipes.
    
    properties
        checkerboardFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'CheckerBoard.blend');
        ballSceneFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'BigBall.blend');
        tempFolder = fullfile(tempdir(), 'VseRecipeTests');
    end
    
    methods (TestMethodSetup)
        function resetFixtureAssets(testCase)
            % fresh temp folder
            if 7 == exist(testCase.tempFolder, 'dir')
                rmdir(testCase.tempFolder, 's')
            end
        end
    end
    
    methods (Test)
        
        function testOuterUnstyledModel(testCase)
            outer = VseModel( ...
                'name', 'outer', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            
            hints.workingFolder = testCase.tempFolder;
            recipe = vseBuildRecipe(outer, {}, {}, {}, ...
                'hints', hints);
            
            % original model should be unchanged in the recipe
            recipeScene = load(recipe.input.parentSceneFile);
            testCase.assertEqual(recipeScene, outer.model);
        end
        
        function testMultipleUnstyledModels(testCase)
            outer = VseModel( ...
                'name', 'outer', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            
            inner = VseModel( ...
                'name', 'inner', ...
                'model', mexximpCleanImport(testCase.ballSceneFile));
            nInner = 3;
            inners = repmat(inner, 1, nInner);
            
            hints.workingFolder = testCase.tempFolder;
            recipe = vseBuildRecipe(outer, {}, inners, {}, ...
                'hints', hints);
            
            recipeScene = load(recipe.input.parentSceneFile);
            
            % recipe should have all materials from outer and inner models
            nRecipeMaterials = numel(recipeScene.materials);
            nExpectedMaterials = numel(outer.model.materials) ...
                + nInner * numel(inner.model.materials);
            testCase.assertEqual(nRecipeMaterials, nExpectedMaterials);
            
            % recipe should have all meshes from outer and inner models
            nRecipeMeshes = numel(recipeScene.meshes);
            nExpectedMeshes = numel(outer.model.meshes) ...
                + nInner * numel(inner.model.meshes);
            testCase.assertEqual(nRecipeMeshes, nExpectedMeshes);
        end
        
        function testOnlyOuterStyled(testCase)
            outer = VseModel( ...
                'name', 'outer', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            style = VseStyle('name', 'testStyle');
            outerStyles = {[], style, [], style};
            
            hints.workingFolder = testCase.tempFolder;
            recipe = vseBuildRecipe(outer, outerStyles, {}, {}, ...
                'hints', hints);
            
            % recipe conditions should correspond to given outerStyles
            [~, values] = rtbParseConditions(recipe.input.conditionsFile);
            testCase.assertEqual(size(values, 1), numel(outerStyles));
        end
        
        function testOnlyInnerStyled(testCase)
            outer = VseModel( ...
                'name', 'outer', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            
            inner = VseModel( ...
                'name', 'inner', ...
                'model', mexximpCleanImport(testCase.ballSceneFile));
            nInner = 3;
            inners = repmat(inner, 1, nInner);
            
            style = VseStyle('name', 'testStyle');
            innerStyleSets = {[], style, [], [style style]};
            
            hints.workingFolder = testCase.tempFolder;
            recipe = vseBuildRecipe(outer, {}, inners, innerStyleSets, ...
                'hints', hints);
            
            % recipe conditions should correspond to innerStyleSets
            [~, values] = rtbParseConditions(recipe.input.conditionsFile);
            testCase.assertEqual(size(values, 1), numel(innerStyleSets));
        end
        
        function testMaterialAlignment(testCase)
            % two models to combine
            outer = VseModel( ...
                'name', 'outer', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            inner = VseModel( ...
                'name', 'inner', ...
                'model', mexximpCleanImport(testCase.ballSceneFile));
            inners = [inner inner];
            
            % two styles to apply
            outerStyle = VseStyle('name', 'outer');
            outerStyle.addManyMaterials({'outer.spd'});
            innerStyle = VseStyle('name', 'inner');
            innerStyle.addManyMaterials({'inner.spd'});
            
            % make the recipe
            hints.workingFolder = testCase.tempFolder;
            recipe = vseBuildRecipe(outer, {outerStyle}, inners, {innerStyle}, ...
                'hints', hints);
            
            % expect each material from each model to get a mapping, by name
            %   and properties to use outer.spd or inner.spd as specified by styles
            elements = mexximpSceneElements(outer.model);
            isMaterial = strcmp({elements.type}, 'materials');
            outerNames = {elements(isMaterial).name};
            outerValues = cell(size(outerNames));
            [outerValues{:}] = deal('outer.spd');
            
            elements = mexximpSceneElements(inner.model);
            isMaterial = strcmp({elements.type}, 'materials');
            innerNames = {elements(isMaterial).name};
            innerValues = cell(size(innerNames));
            [innerValues{:}] = deal('inner.spd');
            
            expectedNames = cat(2, outerNames, innerNames, innerNames);
            expectedValues = cat(2, outerValues, innerValues, innerValues);
            
            % recipe mappings should cover all materials, using given styles
            mappings = rtbLoadJsonMappings(recipe.input.mappingsFile);
            names = {mappings.name};
            props = [mappings.properties];
            values = {props.value};
            
            testCase.assertEqual(names, expectedNames);
            testCase.assertEqual(values, expectedValues);
        end
        
        function testIlluminantAlignment(testCase)
            % two models to combine
            outer = VseModel( ...
                'name', 'outer', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            outer.selectAreaLightsByName('Light');
            inner = VseModel( ...
                'name', 'inner', ...
                'model', mexximpCleanImport(testCase.ballSceneFile));
            inner.selectAreaLightsAll();
            inners = [inner inner];
            
            % two styles to apply
            outerStyle = VseStyle('name', 'outer');
            outerStyle.addManyIlluminants({'outer.spd'});
            innerStyle = VseStyle('name', 'inner');
            innerStyle.addManyIlluminants({'inner.spd'});
            
            % make the recipe
            hints.workingFolder = testCase.tempFolder;
            recipe = vseBuildRecipe(outer, {outerStyle}, inners, {innerStyle}, ...
                'hints', hints);
            
            % expect each selected mesh from each model to get a mapping, by name
            %   and properties to use outer.spd or inner.spd as specified by styles
            selectedMeshes = outer.model.meshes(outer.areaLightMeshSelector);
            outerNames = {selectedMeshes.name};
            outerValues = cell(size(outerNames));
            [outerValues{:}] = deal('outer.spd');
            
            selectedMeshes = inner.model.meshes(inner.areaLightMeshSelector);
            innerNames = {selectedMeshes.name};
            innerValues = cell(size(innerNames));
            [innerValues{:}] = deal('inner.spd');
            
            expectedNames = cat(2, outerNames, innerNames, innerNames);
            expectedValues = cat(2, outerValues, innerValues, innerValues);
            
            % recipe mappings should cover all selected meshes, using given styles
            mappings = rtbLoadJsonMappings(recipe.input.mappingsFile);
            names = {mappings.name};
            props = [mappings.properties];
            values = {props.value};
            
            testCase.assertEqual(names, expectedNames);
            testCase.assertEqual(values, expectedValues);
        end
        
    end
end
