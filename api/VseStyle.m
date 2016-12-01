classdef VseStyle < handle
    % Reusable interface for adding materials, lights, etc. to a model.
    
    properties
        name;
        destination;
        modelSelector;
        elementSelector;
    end        
        
    methods (Abstract)
        % Modify the whole scene.
        scene = applyToWholeScene(obj, scene);
        
        % Modify one mexximp or native scene element.
        scene = applyToSceneForElement(obj, scene, element);
    end
end
