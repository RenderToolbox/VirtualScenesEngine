classdef VseStyleTests < matlab.unittest.TestCase
    % Test basic behaviors for Style objects.
    
    properties
        outputFolder = fullfile(tempdir(), 'VseStyleTests');
    end
    
    methods (TestMethodSetup)
        function cleanUpTempFiles(testCase)
            if 7 == exist(testCase.outputFolder, 'dir')
                rmdir(testCase.outputFolder, 's');
            end
            mkdir(testCase.outputFolder);
        end
    end
    
    methods
        function info = makeElementInfo(testCase)
            elements = struct( ...
                'name', {'name-a', 'name-b', 'name-c'}, ...
                'type', {'type-1', 'type-2', 'type-3'}, ...
                'path', []);
            
            inner = VseModel.elementInfo(elements, 'inner', true);
            outer = VseModel.elementInfo(elements, 'outer', false);
            
            info = [inner outer];
        end
    end
    
    methods (Test)
        
        function testSelectAll(testCase)
            style = VseStyle();
            style.applyToOuterModels = true;
            style.applyToInnerModels = true;
            style.modelNameFilter = '';
            style.elementTypeFilter = '';
            style.elementNameFilter = '';
            
            info = testCase.makeElementInfo();
            selectedElements = style.selectElements(info);
            testCase.assertNumElements(selectedElements, 6);
        end
        
        function testSelectNone(testCase)
            style = VseStyle();
            style.applyToOuterModels = false;
            style.applyToInnerModels = false;
            style.modelNameFilter = '';
            style.elementTypeFilter = '';
            style.elementNameFilter = '';
            
            info = testCase.makeElementInfo();
            selectedElements = style.selectElements(info);
            testCase.assertEmpty(selectedElements);
        end
        
        
        function testSelectUnique(testCase)
            style = VseStyle();
            style.applyToOuterModels = true;
            style.applyToInnerModels = false;
            style.modelNameFilter = 'outer';
            style.elementTypeFilter = '2';
            style.elementNameFilter = 'b';
            
            info = testCase.makeElementInfo();
            selectedElements = style.selectElements(info);
            testCase.assertNumElements(selectedElements, 1);
            testCase.assertFalse(selectedElements.isInner);
            testCase.assertEqual(selectedElements.modelName, 'outer');
            testCase.assertEqual(selectedElements.type, 'type-2');
            testCase.assertEqual(selectedElements.name, 'name-b');
        end
        
        function testSelectInnerElements(testCase)
            style = VseStyle();
            style.applyToOuterModels = false;
            style.applyToInnerModels = true;
            style.modelNameFilter = '';
            style.elementTypeFilter = '';
            style.elementNameFilter = '';
            
            info = testCase.makeElementInfo();
            selectedElements = style.selectElements(info);
            testCase.assertNumElements(selectedElements, 3);
            isInner = [selectedElements.isInner];
            testCase.assertTrue(all(isInner));
        end
        
        function testSelectOuterElements(testCase)
            style = VseStyle();
            style.applyToOuterModels = true;
            style.applyToInnerModels = false;
            style.modelNameFilter = '';
            style.elementTypeFilter = '';
            style.elementNameFilter = '';
            
            info = testCase.makeElementInfo();
            selectedElements = style.selectElements(info);
            testCase.assertNumElements(selectedElements, 3);
            isOuter = ~[selectedElements.isInner];
            testCase.assertTrue(all(isOuter));
        end
        
        function testSelectModelName(testCase)
            style = VseStyle();
            style.applyToOuterModels = true;
            style.applyToInnerModels = true;
            style.modelNameFilter = 'outer';
            style.elementTypeFilter = '';
            style.elementNameFilter = '';
            
            info = testCase.makeElementInfo();
            selectedElements = style.selectElements(info);
            testCase.assertNumElements(selectedElements, 3);
            modelNames = {selectedElements.modelName};
            testCase.assertTrue(all(strcmp(modelNames, 'outer')));
        end
        
        function testSelectElementType(testCase)
            style = VseStyle();
            style.applyToOuterModels = true;
            style.applyToInnerModels = true;
            style.modelNameFilter = '';
            style.elementTypeFilter = '3';
            style.elementNameFilter = '';
            
            info = testCase.makeElementInfo();
            selectedElements = style.selectElements(info);
            testCase.assertNumElements(selectedElements, 2);
            elementTypes = {selectedElements.type};
            testCase.assertTrue(all(strcmp(elementTypes, 'type-3')));
        end
        
        function testSelectElementName(testCase)
            style = VseStyle();
            style.applyToOuterModels = true;
            style.applyToInnerModels = true;
            style.modelNameFilter = '';
            style.elementTypeFilter = '';
            style.elementNameFilter = 'name-a';
            
            info = testCase.makeElementInfo();
            selectedElements = style.selectElements(info);
            testCase.assertNumElements(selectedElements, 2);
            elementNames = {selectedElements.name};
            testCase.assertTrue(all(strcmp(elementNames, 'name-a')));
        end
        
        function testResolveResource(testCase)
            % look for a resource in the test fixture folder
            fixtureName = 'BigBall.blend';
            fixtureFolder = fullfile(fileparts(mfilename('fullpath')), 'fixture');
            hints.workingFolder = fixtureFolder;
            
            style = VseStyle();
            resolvedName = style.resolveResource(fixtureName, hints, ...
                'outputFolder', testCase.outputFolder, ...
                'outputPrefix', 'testPrefix');
            testCase.assertNotEmpty(resolvedName);
            
            expectedRelativePath = fullfile('testPrefix', 'BigBall.blend');
            testCase.assertEqual(resolvedName, expectedRelativePath);
            
            expectedFullPath = fullfile(testCase.outputFolder, expectedRelativePath);
            testCase.assertEqual(exist(expectedFullPath, 'file'), 2);
        end
    end
end