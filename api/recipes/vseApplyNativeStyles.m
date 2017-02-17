function nativeScene = vseApplyNativeStyles(scene, nativeScene, mappings, names, conditionValues, cc, styles, elementInfo, elementMapper, hints)
%% Apply styles to the native scene, for a particular condition.
%
% This function is where VseStyles meet Render Toolbox conditions.  Its job
% is to get the array of styles for the current condition, choose the
% styles that are intended for the native scene, and apply them in order to
% the scene.
%

%% Choose styles for this condition.
conditionName = rtbGetNamedValue(names, conditionValues, 'styleName', '');
if ~isfield(styles, conditionName)
    return;
end
conditionStyles = styles.(conditionName);

if isempty(conditionStyles)
    return;
end


%% Build a map from mexximp elements to native scene elements.
%   this allows us to pass native scene elements directly to the styles
%   and avoids having to search the native scene for each selected element
elementMapper.buildElementMap(scene, nativeScene);


%% Apply each style to the scene.
for ss = 1:numel(conditionStyles)
    style = conditionStyles{ss};
    
    if ~strcmp(hints.renderer, style.destination)
        continue;
    end
    
    % select elements that this style wants
    mexximpElements = style.selectElements(elementInfo);
    nativeElements = elementMapper.getMany(mexximpElements);
    if ~isempty(nativeElements)
        nativeScene = style.applyToSceneElements(nativeScene, nativeElements, hints);
    end
    
    % apply to the scene overall
    nativeScene = style.applyToWholeScene(nativeScene, hints);
end
