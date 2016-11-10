classdef VseMapping
    % Utility for building Render Toolbox mappings.
    
    properties
        broadType = '';
        destination = '';
        group = '';
        index = [];
        name = '';
        operation = '';
        specificType = '';
        props;
    end
    
    methods
        function obj = VseMapping(varargin)
            parser = MipInputParser();
            parser.addProperties(obj);
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
    
    methods (Static)
        function reified = reify(mappings, varargin)
            parser = MipInputParser();
            parser.addRequired('mappings', @(val) isempty(val) || isa(val, 'VseMapping'));
            parser.addParameter('name', []);
            parser.addParameter('index', []);
            parser.addParameter('group', []);
            parser.addParameter('operation', []);
            parser.parseMagically('caller');
            
            if isempty(mappings)
                reified = [];
                return;
            end
            
            if isempty(name)
                name = {mappings.name};
            end
            
            if isempty(index)
                index = {mappings.index};
            end
            
            if isempty(group)
                group = {mappings.group};
            end
            
            if isempty(operation)
                operation = {mappings.operation};
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
