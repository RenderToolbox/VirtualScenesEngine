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
        
        function testSingleUnstyledModel(testCase)
            outer = VseModel( ...
                'name', 'singleUnstyledModel', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            
            hints.workingFolder = testCase.tempFolder;
            recipe = vseBuildRecipe(outer, {}, {}, {}, ...
                'hints', hints);
            
            % original model should be unchanged
            recipeScene = load(recipe.input.parentSceneFile);
            testCase.assertEqual(recipeScene, outer.model);
        end
        
        function testMultipleUnstyledModels(testCase)
            outer = VseModel( ...
                'name', 'outerUnstyledModel', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            
            inner = VseModel( ...
                'name', 'innerUnstyledModel', ...
                'model', mexximpCleanImport(testCase.ballSceneFile));
            nInner = 3;
            inners = repmat(inner, 1, nInner);
            
            hints.workingFolder = testCase.tempFolder;
            recipe = vseBuildRecipe(outer, {}, inners, {}, ...
                'hints', hints);
            
            recipeScene = load(recipe.input.parentSceneFile);
            
            % should have all materials from outer and inner models
            nRecipeMaterials = numel(recipeScene.materials);
            nExpectedMaterials = numel(outer.model.materials) ...
                + nInner * numel(inner.model.materials);
            testCase.assertEqual(nRecipeMaterials, nExpectedMaterials);
            
            % should have all meshes from outer and inner models
            nRecipeMeshes = numel(recipeScene.meshes);
            nExpectedMeshes = numel(outer.model.meshes) ...
                + nInner * numel(inner.model.meshes);
            testCase.assertEqual(nRecipeMeshes, nExpectedMeshes);
        end
        
        function testSingleStyledModel(testCase)
            outer = VseModel( ...
                'name', 'singleStyledModel', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            style = VseStyle('name', 'simpleStyle');
            styleSet = {[], style, [], style};
            
            hints.workingFolder = testCase.tempFolder;
            recipe = vseBuildRecipe(outer, styleSet, {}, {}, ...
                'hints', hints);
            
            % original model should be unchanged
            recipeScene = load(recipe.input.parentSceneFile);
            testCase.assertEqual(recipeScene, outer.model);
            
            % conditions should correspond to styleSet
            [~, values] = rtbParseConditions(recipe.input.conditionsFile);
            testCase.assertEqual(size(values, 1), numel(styleSet));
        end
        
        
    end
end
