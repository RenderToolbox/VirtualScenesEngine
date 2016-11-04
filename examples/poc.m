%% Early proof of concept for the VirtualScenesEngine.
%
% TODO
% style can shuffle values within each type

%tbUse('VirtualScenesEngine', 'reset', 'full');


%% Model.
clear;
clc;

modelFile = vsaGetFiles('Objects', 'RingToy', 'nameFilter', 'blend$');
model = mexximpCleanImport(modelFile{1});
model = mexximpCentralizeCamera(model, 'viewAxis', [1 1 1]);
model = mexximpAddLanterns(model);


%% Styles.
colorCheckerFiles = vsaGetFiles('Reflectances', 'ColorChecker', 'fullPaths', false);
colorCheckerStyle = VseStyle('ColorChecker');
colorCheckerStyle.addManyMaterials(colorCheckerFiles);

boringStyle = VseStyle('Boring');
boringStyle.addValue('materials', ...
    VseStyleValue('materials', 'matte', 'destination', 'Generic') ...
    .withProperty('diffuseReflectance', 'spectrum', '300:0.5 800:0.5'));


%% Combo.
combo = VseCombo(model);
combo.addStyle(colorCheckerStyle);
combo.addStyle(boringStyle);


%% VirtualScene.
virtualScene = VseVirtualScene(combo, 'name', 'poc');

% bigModel = virtualScene.bigModel();
% mexximpScenePreview(bigModel);

%% Convert to Recipe.
hints.fov = deg2rad(60);
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.renderer = 'Mitsuba';

recipe = vseVirtualSceneToRecipe(virtualScene, 'hints', hints);


%% Render!
recipe = rtbExecuteRecipe(recipe);
