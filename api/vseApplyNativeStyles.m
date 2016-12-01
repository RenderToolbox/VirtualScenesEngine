function nativeScene = vseApplyNativeStyles(scene, nativeScene, mappings, names, conditionValues, cc, styles, elementFilterInfo, hints)
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


%% Apply each style to the scene.
isNativeStyle = ~strcmp('mexximp', {conditionStyles.destination});
for ss = find(isNativeStyle)
    style = conditionStyles(ss);
    
    % select elements that this style wants
    elements = style.selectElements(elementFilterInfo);
    nativeScene = style.applyToSceneElements(nativeScene, elements, hints);
    
    % apply to the scene overall
    nativeScene = style.applyToWholeScene(nativeScene, hints);
end
