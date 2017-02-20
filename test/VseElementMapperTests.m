classdef VseElementMapperTests < matlab.unittest.TestCase
    % Test basic behaviors for mapping mexximp elements to other objects.
    
    methods
        function elements = makeElemens(testCase)
            elements = struct( ...
                'name', {'name-a', 'name-b', 'name-c'}, ...
                'type', {'type-1', 'type-2', 'type-3'}, ...
                'path', {{'cameras', 1}, {'materials', 7}, {'rootNode', 'children', 42}});
        end
    end
    
    methods (Test)
        function testPutGet(testCase)
            object = VseElementMapper();
            elements = testCase.makeElemens();
            
            mapper = VseElementMapper();
            mapper.put(elements(1), object);
            results = mapper.get(elements(1));
            testCase.assertNumElements(results, 1);
            testCase.assertEqual(results{1}, object);
        end
        
        function testGetNone(testCase)
            elements = testCase.makeElemens();
            mapper = VseElementMapper();
            results = mapper.get(elements(1));
            testCase.assertEmpty(results);
        end
        
        function testPutGetDuplicates(testCase)
            object = VseElementMapper();
            elements = testCase.makeElemens();
            
            mapper = VseElementMapper();
            mapper.put(elements(1), object);
            mapper.put(elements(1), object);
            mapper.put(elements(1), object);
            results = mapper.get(elements(1));
            testCase.assertNumElements(results, 1);
            testCase.assertEqual(results{1}, object);
        end
        
        function testPutGetMany(testCase)
            objects = {VseElementMapper(), VseStyle(), VseModel()};
            elements = testCase.makeElemens();
            
            mapper = VseElementMapper();
            mapper.put(elements(1), objects{1});
            mapper.put(elements(1), objects{2});
            mapper.put(elements(1), objects{3});
            results = mapper.get(elements(1));
            testCase.assertNumElements(results, 3);
            testCase.assertEqual(results, objects);
        end
        
        function testClear(testCase)
            object = VseElementMapper();
            elements = testCase.makeElemens();
            
            mapper = VseElementMapper();
            mapper.put(elements(1), object);
            results = mapper.get(elements(1));
            testCase.assertNumElements(results, 1);
            testCase.assertEqual(results{1}, object);
            
            mapper.clear();
            results = mapper.get(elements(1));
            testCase.assertEmpty(results);
        end
    end
end
