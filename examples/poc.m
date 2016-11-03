%% Early proof of concept for the VirtualScenesEngine.
%
% TODO
% separate vsaGetInfo, vsaGetFiles( ... filter? absolute?)
% separate vsaListTypes, vsaListAssets(assetType)
% virtal scene make name of iith style -- concat unique names
% style can shuffle values within each type
% get big scene out of VseVirtualScene

tbUse('VirtualScenesEngine', 'reset', 'full');


%% Model.
clear;
clc;

[~, files] = vsaGet('Objects', 'RingToy');
model = mexximpCleanImport(files{1});
model = mexximpCentralizeCamera(model);
model = mexximpAddLanterns(model);


%% Styles.
[~, files] = vsaGet('Reflectances', 'ColorChecker');
colorCheckerStyle = VseStyle('ColorChecker');
colorCheckerStyle.addManyMaterials(files);

boringStyle = VseStyle('Boring');
boringStyle.addValue('materials', ...
    VseStyleValue('materials', 'matte', 'destination', 'Generic') ...
    .withProperty('diffuseReflectance', 'spectrum', 0.5));


%% Combo.
combo = VseCombo(model);
combo.addStyle(colorCheckerStyle);
combo.addStyle(boringStyle);


%% VirtualScene.
virtualScene = VseVirtualScene(combo, 'name', 'poc');


%% Render.
hints.fov = deg2rad(60);
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.renderer = 'Mitsuba';

recipe = vseVirtualSceneToRecipe(virtualScene, 'hints', hints);
