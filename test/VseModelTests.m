classdef VseModelTests < matlab.unittest.TestCase
    % Test basic behaviors for VseModel objects.
    
    properties
        checkerboardFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'CheckerBoard.blend');
        ballSceneFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'BigBall.blend');
    end
    
    methods (Test)
        function testInsertFromOrigin(testCase)
            checkerboard = VseModel( ...
                'name', 'checkerboard', ...
                'model', mexximpCleanImport(testCase.checkerboardFile));
            ball = VseModel( ...
                'name', 'ball', ...
                'model', mexximpCleanImport(testCase.ballSceneFile), ...
                'transformation', mexximpIdentity(), ...
                'transformationRelativeToCamera', false);
            bigScene = VseModel.combine(checkerboard, ball);
            
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
            bigScene = VseModel.combine(checkerboard, ball);
            
            % ball position should be near camera position
            ballNode = bigScene.model.rootNode.children(end);
            testCase.assertEqual(ballNode.name, 'ballBigBall');
            cameraNode = bigScene.model.rootNode.children(end-1);
            testCase.assertEqual(cameraNode.name, 'Camera');
            testCase.assertEqual(ballNode.transformation([4 8 12]), ...
                cameraNode.transformation([4 8 12]), ...
                'AbsTol', 1e-6);
        end
        
        function testCombinedElementInfo(testCase)
            [checkerboardModel, checkerboardElements] = mexximpCleanImport(testCase.checkerboardFile);
            checkerboard = VseModel( ...
                'name', 'checkerboard', ...
                'model', checkerboardModel);
            
            [ballModel, ballElements] = mexximpCleanImport(testCase.checkerboardFile);
            ball = VseModel( ...
                'name', 'ball', ...
                'model', ballModel, ...
                'transformation', mexximpIdentity(), ...
                'transformationRelativeToCamera', true);
            [~, combinedElements] = VseModel.combine(checkerboard, ball);
            
            % expect sum of elements, minus one extra root node
            nCheckerboard = numel(checkerboardElements);
            nBall = numel(ballElements);
            nExpected = nCheckerboard + nBall - 1;
            nCombined = numel(combinedElements);
            testCase.assertEqual(nCombined, nExpected);
            
            % all inner elements are from the ball
            isInner = [combinedElements.isInner];
            innerElements = combinedElements(isInner);
            innerModelNames = {innerElements.modelName};
            testCase.assertTrue(all(strcmp(innerModelNames, ball.name)));
            
            % all outer elements are from the checkerboard
            outerElements = combinedElements(~isInner);
            outerModelNames = {outerElements.modelName};
            testCase.assertTrue(all(strcmp(outerModelNames, checkerboard.name)));
            
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
