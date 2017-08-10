classdef VseProofOfConceptTests < matlab.unittest.TestCase
    % Use the vseProofOfConcept example as an end-to-end test.
    
    properties
        checkerboardFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'CheckerBoard.blend');
        ballSceneFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'BigBall.blend');
        workingFolder = fullfile(rtbWorkingFolder(), 'VseProofOfConceptTests');
    end
    
    methods (TestMethodSetup)
        function cleanWorkingFolder(testCase)
            if 7 == exist(testCase.workingFolder, 'dir')
                rmdir(testCase.workingFolder, 's')
            end
        end
    end
    
    methods
        function aioPrefs = makeAioPrefs(testCase)
            aioPrefs.locations = aioLocation( ...
                'name', 'VirtualScenesExampleAssets', ...
                'strategy', 'AioFileSystemStrategy', ...
                'baseDir', fullfile(vseaRoot(), 'examples'));
        end
        
        function [inner, outer] = makeModels(testCase)
            checkerboard_1 = VseModel( ...
                'name', 'checkerboard_1', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            checkerboard_2 = VseModel( ...
                'name', 'checkerboard_2', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            ball_1 = VseModel( ...
                'name', 'ball_1', ...
                'model', mexximpCleanImport(testCase.ballSceneFile), ...
                'transformation', mexximpScale([5 5 5]) * mexximpTranslate([3 3 0]), ...
                'transformationRelativeToCamera', false);
            ball_2 = VseModel( ...
                'name', 'ball_2', ...
                'model', mexximpCleanImport(testCase.ballSceneFile), ...
                'transformation', mexximpScale([5 5 5]) * mexximpTranslate([-3 -3 0]), ...
                'transformationRelativeToCamera', false);
            inner = {[], [ball_1 ball_2]};
            outer = {checkerboard_1, checkerboard_2};
        end
        
        function styles = makeMitsubaStyles(testCase)
            aioPrefs = testCase.makeAioPrefs();
            
            blessAreaLights = VseMitsubaAreaLights( ...
                'name', 'blessAreaLights', ...
                'applyToInnerModels', false);
            
            redBlueLights = VseMitsubaEmitterSpectra( ...
                'name', 'redBlueLights', ...
                'pluginType', 'area', ...
                'propertyName', 'radiance');
            redBlueLights.addSpectrum('300:2 800:0.0');
            redBlueLights.addSpectrum('300:0.0 800:2');
            
            colorCheckerFiles = aioGetFiles('Reflectances', 'ColorChecker', ...
                'aioPrefs', aioPrefs, ...
                'fullPaths', false);
            colorCheckerDiffuse = VseMitsubaDiffuseMaterials( ...
                'name', 'colorCheckerDiffuse');
            colorCheckerDiffuse.addManySpectra(colorCheckerFiles);
            
            textureFiles = aioGetFiles('Textures', 'OpenGameArt', ...
                'aioPrefs', aioPrefs, ...
                'fullPaths', false);
            texturedDiffuse = VseMitsubaDiffuseMaterials( ...
                'name', 'texturedDiffuse');
            texturedDiffuse.addManyTextures(textureFiles);
            
            styles.textures = {blessAreaLights, texturedDiffuse};
            styles.colors = {blessAreaLights, redBlueLights, colorCheckerDiffuse};
        end
        
        function styles = makePbrtStyles(testCase)
            aioPrefs = testCase.makeAioPrefs();
            
            blessAreaLights = VsePbrtAreaLights( ...
                'name', 'blessAreaLights', ...
                'applyToInnerModels', false);
            
            redBlueLights = VsePbrtEmitterSpectra( ...
                'name', 'redBlueLights', ...
                'identifier', 'AreaLightSource', ...
                'propertyName', 'L');
            redBlueLights.addSpectrum('300:2 800:0.0');
            redBlueLights.addSpectrum('300:0.0 800:2');
            
            colorCheckerFiles = aioGetFiles('Reflectances', 'ColorChecker', ...
                'aioPrefs', aioPrefs, ...
                'fullPaths', false);
            colorCheckerDiffuse = VsePbrtDiffuseMaterials( ...
                'name', 'colorCheckerDiffuse');
            colorCheckerDiffuse.addManySpectra(colorCheckerFiles);
            
            textureFiles = aioGetFiles('Textures', 'OpenGameArt', ...
                'aioPrefs', aioPrefs, ...
                'fullPaths', false);
            texturedDiffuse = VsePbrtDiffuseMaterials( ...
                'name', 'texturedDiffuse');
            texturedDiffuse.addManyTextures(textureFiles);
            
            styles.textures = {blessAreaLights, texturedDiffuse};
            styles.colors = {blessAreaLights, redBlueLights, colorCheckerDiffuse};
        end
        
        function sanityCheckRecipes(testCase, inner, outer, styles, recipes)
            % should have a recipe for each inner-outer combo
            nOuter = numel(outer);
            nInner = numel(inner);
            testCase.assertSize(recipes, [nOuter, nInner]);
            
            % each recipe should have a condition for each style
            for oo = 1:nOuter
                for ii = 1:nInner
                    recipe = recipes{oo,ii};
                    
                    % same styles as given
                    recipeStyles = recipe.input.styles;
                    testCase.assertEqual(recipeStyles, styles);
                    styleNames = sort(fieldnames(styles));
                    nStyles = numel(styleNames);
                    
                    % a condition for each style
                    [names, values] = rtbParseConditions(recipe.input.conditionsFile);
                    isStyleName = strcmp(names, 'styleName');
                    recipeStyleNames = sort(values(:, isStyleName));
                    testCase.assertEqual(recipeStyleNames, styleNames);
                    
                    % a scene for each style
                    recipeScenes = recipe.rendering.scenes;
                    nScenes = numel(recipeScenes);
                    testCase.assertEqual(nScenes, nStyles);
                    
                    % a rendering for each style
                    recipeRenderings = recipe.rendering.radianceDataFiles;
                    nRenderings = numel(recipeRenderings);
                    testCase.assertEqual(nRenderings, nStyles);
                end
            end
        end
    end
    
    methods (Test)
        function testProofOfConceptMitsuba(testCase)
            hints.fov = deg2rad(60);
            hints.imageHeight = 120;
            hints.imageWidth = 180;
            hints.workingFolder = testCase.workingFolder();
            hints.renderer = 'Mitsuba';
            
            aioPrefs = testCase.makeAioPrefs();
            [inner, outer] = testCase.makeModels();
            styles = testCase.makeMitsubaStyles();
            
            [~, ~, ~, recipes] = vseProofOfConcept( ...
                'hints', hints, ...
                'aioPrefs', aioPrefs, ...
                'outer', outer, ...
                'inner', inner, ...
                'styles', styles, ...
                'showFigures', false);
            
            testCase.sanityCheckRecipes(inner, outer, styles, recipes);
        end
        
        function testProofOfConceptPbrt(testCase)
            hints.fov = deg2rad(60);
            hints.imageHeight = 120;
            hints.imageWidth = 180;
            hints.workingFolder = testCase.workingFolder();
            hints.renderer = 'PBRT';
            
            aioPrefs = testCase.makeAioPrefs();
            [inner, outer] = testCase.makeModels();
            styles = testCase.makePbrtStyles();
            
            [~, ~, ~, recipes] = vseProofOfConcept( ...
                'hints', hints, ...
                'aioPrefs', aioPrefs, ...
                'outer', outer, ...
                'inner', inner, ...
                'styles', styles, ...
                'showFigures', false);
            
            testCase.sanityCheckRecipes(inner, outer, styles, recipes);
        end
        
    end
end
