%% Early proof of concept for the VirtualScenesEngine.

%tbUse('VirtualScenesEngine', 'reset', 'full');


%% Choose some of our 3D model assets.
clear;
clc;

ringToyFile = vsaGetFiles('Objects', 'RingToy', 'nameFilter', 'blend$');
ringToy = mexximpCleanImport(ringToyFile{1});
ringToy = mexximpCentralizeCamera(ringToy, 'viewAxis', [1 1 1]);
ringToy = mexximpAddLanterns(ringToy);

xylophoneFile = vsaGetFiles('Objects', 'Xylophone', 'nameFilter', 'blend$');
xylophone = mexximpCleanImport(xylophoneFile{1});
xylophone = mexximpCentralizeCamera(xylophone, 'viewAxis', [1 1 1]);
xylophone = mexximpAddLanterns(xylophone);


%% Define some styles that are independent of the models.
colorCheckerStyle = VseStyle('ColorChecker');
colorCheckerFiles = vsaGetFiles('Reflectances', 'ColorChecker', 'fullPaths', false);
colorCheckerStyle.addManyMaterials(colorCheckerFiles);

boringStyle = VseStyle('Boring');
boringStyle.addMaterial( ...
    VseStyleValue('materials', 'matte', 'destination', 'Generic') ...
    .withProperty('diffuseReflectance', 'spectrum', '300:0.5 800:0.5'));

textureStyle = VseStyle('Textures');
textureFiles = vsaGetFiles('Textures', 'OpenGameArt', 'fullPaths', false);
textureStyle.addManyTextureMaterials(textureFiles);
textureStyle.shuffle = true;

lightUpStyle = VseStyle('LightUp');
lightUpStyle.addMaterial( ...
    VseStyleValue('materials', 'matte', 'destination', 'Generic') ...
    .withProperty('diffuseReflectance', 'spectrum', '300:0 800:0'));
d65 = vsaGetFiles('Illuminants', 'D65', 'fullPaths', false);
lightUpStyle.addManyIlluminants(d65);
lightUpStyle.setMeshIlluminantSelector([true false]);


%% Cross the models and the styles.
ringToyCombo = VseCombo(ringToy);
ringToyCombo.addStyle(colorCheckerStyle);
ringToyCombo.addStyle(boringStyle);
ringToyCombo.addStyle(textureStyle);
ringToyCombo.addStyle(lightUpStyle);

xylophoneCombo = VseCombo(xylophone);
xylophoneCombo.addStyle(colorCheckerStyle);
xylophoneCombo.addStyle(boringStyle);
xylophoneCombo.addStyle(textureStyle);
xylophoneCombo.addStyle(lightUpStyle);


%% Build up virtual scenes from combos.
ringToyScene = VseVirtualScene(ringToyCombo, 'name', 'RingToy');

xylophoneScene = VseVirtualScene(xylophoneCombo, 'name', 'Xylophone');
ringTransform = mexximpScale(0.3 * [1 1 1]) ...
    * mexximpRotate([0.5 0.5 0], deg2rad(45)) ...
    * mexximpTranslate([0 0 1]);
xylophoneScene.addInnerCombo(ringToyCombo, ringTransform);

%mexximpScenePreview(xylophoneScene.bigModel);

%% Convert to scenes to recipes for rendering.
hints.fov = deg2rad(20);
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.renderer = 'Mitsuba';

ringToyRecipe = vseVirtualSceneToRecipe(ringToyScene, 'hints', hints);
xylophoneRecipe = vseVirtualSceneToRecipe(xylophoneScene, 'hints', hints);


%% Render!
ringToyRecipe = rtbExecuteRecipe(ringToyRecipe);
xylophoneRecipe = rtbExecuteRecipe(xylophoneRecipe);

