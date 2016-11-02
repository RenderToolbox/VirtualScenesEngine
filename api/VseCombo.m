classdef VseCombo < handle
    % Combination of a 3D model and a style.
    
    properties
        name;
        model;
        style;
    end
    
    methods
        function obj = VseCombo(model, style, varargin)
            parser = MipInputParser();
            parser.addRequired('model', @isstruct);
            parser.addRequired('style', @(val) isa(val, 'VseStyle'));
            parser.addParameter('name', '', @ischar);
            parser.parseMagically(obj);
            
            if isempty(obj.name)
                obj.name = obj.style.name;
            end
        end
    end
end
