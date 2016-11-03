classdef VseStyleValue
    % Container for typed, complex values like materials and illuminants.
    
    properties
        destination;
        broadType;
        specificType;
        props;
    end
    
    methods
        function obj = VseStyleValue(broadType, specificType, varargin)
            parser = MipInputParser();
            parser.addRequired('broadType', @ischar);
            parser.addRequired('specificType', @ischar);
            parser.addParameter('destination', '', @ischar);
            obj = parser.parseMagically(obj);
        end
        
        function obj = withProperty(obj, name, valueType, value)
            prop = struct( ...
                'name', name, ...
                'valueType', valueType, ...
                'value', value);
            
            if isempty(obj.props)
                obj.props = prop;
            else
                existingIndex = strcmp(name, {obj.props.name});
                if any(existingIndex)
                    obj.props(existingIndex) = prop;
                else
                    obj.props(end+1) = prop;
                end
            end
        end
    end
end
