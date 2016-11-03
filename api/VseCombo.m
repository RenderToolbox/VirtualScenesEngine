classdef VseCombo < handle
    % Combination of a 3D model plus some styles.
    
    properties
        name;
        model;
        styles;
    end
    
    methods
        function obj = VseCombo(model, varargin)
            parser = MipInputParser();
            parser.addRequired('model', @isstruct);
            parser.addParameter('name', '', @ischar);
            parser.parseMagically(obj);
            
        end
        
        function addStyle(obj, style)
            parser = MipInputParser();
            parser.addRequired('style', @(val) isa(val, 'VseStyle'));
            parser.parseMagically('caller');
            
            if isempty(obj.styles)
                obj.styles = style;
            else
                obj.styles(end+1) = style;
            end
        end
        
        function values = getWrappedStyles(obj, indices)
            parser = MipInputParser();
            parser.addRequired('indices', @isnumeric);
            parser.parseMagically('caller');
            
            wrappedIndices = 1 + mod(indices - 1, numel(obj.styles));
            values = obj.styles(wrappedIndices);
        end
        
    end
end
