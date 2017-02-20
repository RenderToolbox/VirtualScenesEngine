classdef VseElementMapper < handle
    % Map mexximp scene elements to renderer native elements.
    
    properties
        elementMap;
    end
    
    methods
        function buildElementMap(obj, scene, nativeScene)
        end
    end
    
    methods
        function obj = VseElementMapper()
            obj.elementMap = containers.Map( ...
                'KeyType', 'char', ...
                'ValueType', 'any');
        end
        
        function key = keyForElement(obj, mexximpElement)
            if isempty(mexximpElement.path)
                key = '';
                return;
            end
            rawKey = evalc('disp(mexximpElement.path)');
            key = rawKey(~isspace(rawKey));
        end
        
        function clear(obj)
            obj.elementMap.remove(obj.elementMap.keys());
        end
        
        function put(obj, mexximpElement, nativeElement)
            if isempty(nativeElement)
                return;
            end
            
            key = obj.keyForElement(mexximpElement);
            if obj.elementMap.isKey(key)
                % only add if new nativeElement
                alreadyIn = obj.elementMap(key);
                if any(nativeElement == alreadyIn)
                    return;
                end
                alreadyIn{end+1} = nativeElement;
                obj.elementMap(key) = alreadyIn;
            else
                % new cell for this nativeElement
                obj.elementMap(key) = {nativeElement};
            end
        end
        
        function nativeElements = get(obj, mexximpElement)
            key = obj.keyForElement(mexximpElement);
            if ~obj.elementMap.isKey(key)
                nativeElements = {};
                return;
            end
            nativeElements = obj.elementMap(key);
        end
        
        function nativeElements = getMany(obj, mexximpElements)
            nMany = numel(mexximpElements);
            nativeMany = cell(1, nMany);
            for mm = 1:nMany
                nativeMany{mm} = obj.get(mexximpElements(mm));
            end
            nativeElements = cat(2, nativeMany{:});
        end
    end
end
