function [scene, mappings] = vseApplyMexximpStyles(scene, mappings, names, conditionValues, cc, styles, elementInfo, hints)
%% Apply styles to the mexximp scene, for a particular condition.
%
% This function is where VseStyles meet Render Toolbox conditions.  Its job
% is to get the array of styles for the current condition, choose the
% styles that are intended for the mexximp scene, and apply them in order
% to the scene.
%

%% Choose styles for this condition.
conditionName = rtbGetNamedValue(names, conditionValues, 'styleName', '');
if ~isfield(styles, conditionName)
    return;
end
conditionStyles = styles.(conditionName);


%% Apply each style to the scene.
for ss = 1:numel(conditionStyles)
    style = conditionStyles{ss};
    
    if ~strcmp('mexximp', style.destination)
        continue;
    end
    
    % select elements that this style wants
    elements = style.selectElements(elementInfo);
    if ~isempty(elements)
        scene = style.applyToSceneElements(scene, elements, hints);
    end
    
    % apply to the scene overall
    scene = style.applyToWholeScene(scene, hints);
end
