classdef VseMapping
    % Utility for building Render Toolbox mappings.
    
    properties
        broadType;
        destination;
        group;
        index;
        name;
        operation;
        specificType;
        props;
    end
    
    methods
        function obj = VseMapping(varargin)
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
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
    
    methods (Static)
        function reified = reify(mappings, varargin)
            parser = MipInputParser();
            parser.addRequired(mappings, @(val) isa(val, 'VseMapping'));
            parser.addParameter('name', {vseMappings.name});
            parser.addParameter('index', {vseMappings.index});
            parser.addParameter('group', {vseMappings.group});
            parser.addParameter('operation', {vseMappings.operation});
            parser.parseMagically('caller');
            
            if isempty(mappings)
                reified = [];
                return;
            end
            
            rawMappings = struct( ...
                'name', name, ...
                'index', index, ...
                'group', group, ...
                'operation', operation, ...
                'broadType', {mappings.broadType}, ...
                'destination', {mappings.destination}, ...
                'specificType', {mappings.specificType}, ...
                'properties', {mappings.props});
            reified = rtbValidateMappings(rawMappings);
        end
    end
end
