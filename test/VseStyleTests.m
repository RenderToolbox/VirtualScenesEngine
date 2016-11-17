classdef VseStyleTests < matlab.unittest.TestCase
    % Test basic behaviors for Style objects.
    
    properties
        checkerboardFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'CheckerBoard.blend');
        ballSceneFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'BigBall.blend');
    end
    
    methods (Test)
        
        function testCombineRendererConfigs(testCase)
            % two styles, with overlapping integrator config
            styleOne = VseStyle('name', 'one');
            styleOne.addRendererConfig(VseMapping( ...
                'name', 'integrator', ...
                'broadType', 'integrator', ...
                'specificType', 'path'));
            styleOne.addRendererConfig(VseMapping( ...
                'name', 'sampler', ...
                'broadType', 'sampler', ...
                'specificType', 'lowdiscrepancy'));
            styleTwo = VseStyle('name', 'two');
            styleTwo.addRendererConfig(VseMapping( ...
                'name', 'integrator', ...
                'broadType', 'integrator', ...
                'specificType', 'path'));
            styleTwo.addRendererConfig(VseMapping( ...
                'name', 'film', ...
                'broadType', 'film', ...
                'specificType', 'hdrfilm'));
            
            % remove overlap when combining configs
            bigConfig = VseStyle.bigRendererConfig([styleOne styleTwo]);
            names = {bigConfig.name};
            testCase.assertNumElements(names, 3);
            testCase.assertEqual(sort(names), {'film', 'integrator', 'sampler'});
        end
        
        function testRecycleStyles(testCase)
            style = VseStyle('name', 'a');
            indices = 1:10;
            recycled = VseStyle.wrappedStyles(style, indices);
            testCase.assertNumElements(recycled, numel(indices));
            
            names = {recycled.name};
            testCase.assertEqual(unique(names), {'a'});
        end
        
        function testAlignStyles(testCase)
            styleA = VseStyle('name', 'a');
            styleB = VseStyle('name', 'b');
            styleC = VseStyle('name', 'c');
            styleD = VseStyle('name', 'd');
            styles = [styleA styleB styleC styleD];
            
            indices = 1:numel(styles);
            aligned = VseStyle.wrappedStyles(styles, indices);
            testCase.assertNumElements(aligned, numel(indices));
            
            names = {aligned.name};
            testCase.assertEqual(names, {'a', 'b', 'c', 'd'});
        end
        
        function testRecycleMaterials(testCase)
            style = VseStyle('name', 'a');
            style.addMaterial(VseMapping('name', 'a'));
            
            indices = 1:10;
            recycled = style.getWrapped('materials', indices);
            testCase.assertNumElements(recycled, numel(indices));
            
            names = {recycled.name};
            testCase.assertEqual(unique(names), {'a'});
        end
        
        function testAlignMaterials(testCase)
            style = VseStyle('name', 'ColorChecker');
            reflectances = aioGetFiles('Reflectances', 'ColorChecker', 'fullPaths', false);
            style.addManyMaterials(reflectances);
            testCase.assertNumElements(style.materials, 24);
            
            indices = 1:numel(style.materials);
            aligned = style.getWrapped('materials', indices);
            testCase.assertNumElements(aligned, numel(indices));
            
            % material properties should match given reflectances
            props = [aligned.props];
            propValues = {props.value};
            testCase.assertEqual(propValues, reflectances);
        end
        
        function testRecycleIlluminants(testCase)
            style = VseStyle('name', 'a');
            style.addIlluminant(VseMapping('name', 'a'));
            
            indices = 1:10;
            recycled = style.getWrapped('illuminants', indices);
            testCase.assertNumElements(recycled, numel(indices));
            
            names = {recycled.name};
            testCase.assertEqual(unique(names), {'a'});
        end
        
        function testAlignIlluminants(testCase)
            style = VseStyle('name', 'Constants');
            intensities = num2cell(1:33);
            style.addManyIlluminants(intensities);
            testCase.assertNumElements(style.illuminants, 33);
            
            indices = 1:numel(style.illuminants);
            aligned = style.getWrapped('illuminants', indices);
            testCase.assertNumElements(aligned, numel(indices));
            
            % illuminant properties should match given intensities
            props = [aligned.props];
            propValues = {props.value};
            testCase.assertEqual(propValues, intensities);
        end
        
    end
end
