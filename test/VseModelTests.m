classdef VseModelTests < matlab.unittest.TestCase
    % Test basic behaviors for VseModel objects.
    
    properties
        checkerboardFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'CheckerBoard.blend');
        ballSceneFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'BigBall.blend');
    end
    
    methods (Test)
        function testSelectMeshes(testCase)
            checkerboard = VseModel( ...
                'name', 'checkerboard', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            
            checkerboard.selectAreaLightsNone();
            testCase.assertEqual(numel(checkerboard.areaLightMeshSelector), numel(checkerboard.model.meshes));
            testCase.assertTrue(~all(checkerboard.areaLightMeshSelector));
            
            checkerboard.selectAreaLightsAll();
            testCase.assertEqual(numel(checkerboard.areaLightMeshSelector), numel(checkerboard.model.meshes));
            testCase.assertTrue(all(checkerboard.areaLightMeshSelector));
            
            checkerboard.selectAreaLightsByName('Light');
            expectedSelector = false(1, numel(checkerboard.model.meshes));
            expectedSelector(1:3) = true;
            testCase.assertEqual(checkerboard.areaLightMeshSelector, expectedSelector);
            
            checkerboard.selectAreaLightsByName('Check');
            expectedSelector = false(1, numel(checkerboard.model.meshes));
            expectedSelector(4:end) = true;
            testCase.assertEqual(checkerboard.areaLightMeshSelector, expectedSelector);
        end
        
        function testInsertFromOrigin(testCase)
            checkerboard = VseModel( ...
                'name', 'checkerboard', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            ball = VseModel( ...
                'name', 'ball', ...
                'model', mexximpCleanImport(testCase.ballSceneFile), ...
                'transformation', mexximpIdentity(), ...
                'transformationRelativeToCamera', false);
            bigScene = VseModel.bigModel(checkerboard, ball);
            
            % ball position should be at origin
            ballNode = bigScene.model.rootNode.children(end);
            testCase.assertEqual(ballNode.name, 'ballBigBall');
            testCase.assertEqual(ballNode.transformation([4 8 12]), [0 0 0], ...
                'AbsTol', 1e-6);
        end
        
        function testInsertFromCarmera(testCase)
            checkerboard = VseModel( ...
                'name', 'checkerboard', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            ball = VseModel( ...
                'name', 'ball', ...
                'model', mexximpCleanImport(testCase.ballSceneFile), ...
                'transformation', mexximpIdentity(), ...
                'transformationRelativeToCamera', true);
            bigScene = VseModel.bigModel(checkerboard, ball);
            
            % ball position should be near camera position
            ballNode = bigScene.model.rootNode.children(end);
            testCase.assertEqual(ballNode.name, 'ballBigBall');
            cameraNode = bigScene.model.rootNode.children(end-1);
            testCase.assertEqual(cameraNode.name, 'Camera');
            testCase.assertEqual(ballNode.transformation([4 8 12]), ...
                cameraNode.transformation([4 8 12]), ...
                'AbsTol', 1e-6);
        end
        
        function testModelFromAsset(testCase)
            aioPrefs.locations = aioLocation( ...
                'name', 'VirtualScenesExampleAssets', ...
                'strategy', 'AioFileSystemStrategy', ...
                'baseDir', fullfile(vseaRoot(), 'examples'));
            
            fromAsset = VseModel.fromAsset('BaseScenes', 'CheckerBoard', ...
                'aioPrefs', aioPrefs, ...
                'nameFilter', 'blend$');
            testCase.assertEqual(fromAsset.name, 'CheckerBoard');
            
            % loaded from asset should match loaded from fixture
            manual = mexximpCleanImport(testCase.checkerboardFile);
            testCase.assertEqual(fromAsset.model, manual);
        end
    end
end
