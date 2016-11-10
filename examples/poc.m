%% Early proof of concept for the VirtualScenesEngine.

% tbUse('VirtualScenesEngine', 'reset', 'full');
clear;
clc;


%% Choose some base scenes.
mill = VseModel.fromAsset('BaseScenes', 'Mill', 'nameFilter', 'blend$');
mill.selectAreaLightsByName('Light');

library = VseModel.fromAsset('BaseScenes', 'Library', 'nameFilter', 'blend$');
library.selectAreaLightsByName('Light');

baseScenes = {mill, library};


%% Choose some objects to insert into the base scenes.
xylophone = VseModel.fromAsset('Objects', 'Xylophone', 'nameFilter', 'blend$');
xylophone.transformation = mexximpTranslate([0 1 -3]);
xylophone.transformationRelativeToCamera = true;

barrel = VseModel.fromAsset('Objects', 'Barrel', 'nameFilter', 'blend$');
barrel.transformation = mexximpTranslate([-1 0 -3]);
barrel.transformationRelativeToCamera = true;

ringToy = VseModel.fromAsset('Objects', 'RingToy', 'nameFilter', 'blend$');
ringToy.transformation = mexximpTranslate([1 -1 -3]);
ringToy.transformationRelativeToCamera = true;
ringToy.selectAreaLightsAll();

objectSets = {[], xylophone, [xylophone barrel ringToy]};


%% Define some styles that are independent of the models.
plainStyle = VseStyle('name', 'Plain');
plainStyle.addMaterial(VseMapping( ...
    'broadType', 'materials', ...
    'specificType', 'matte', ...
    'destination', 'Generic') ...
    .withProperty('diffuseReflectance', 'spectrum', '300:1 800:1'));
plainStyle.addManyIlluminants({'300:0.1 800:0.1'});

colorCheckerStyle = VseStyle('name', 'ColorChecker');
colorCheckerFiles = vsaGetFiles('Reflectances', 'ColorChecker', 'fullPaths', false);
colorCheckerStyle.addManyMaterials(colorCheckerFiles);
colorCheckerStyle.addManyIlluminants({'300:0.1 800:0.1'});

textureStyle = VseStyle('name', 'Texture');
textureFiles = vsaGetFiles('Textures', 'OpenGameArt', 'fullPaths', false);
textureStyle.addManyTextureMaterials(textureFiles);
textureStyle.addManyIlluminants({'300:0.2 800:0.0', '300:0.0 800:0.1'});

styleSets = {[], colorCheckerStyle, [plainStyle textureStyle]};


%% Make recipes that cross the base scenes, objects, and styles.
hints.fov = deg2rad(60);
hints.imageHeight = 240;
hints.imageWidth = 320;
hints.renderer = 'Mitsuba';

nBaseScenes = numel(baseScenes);
nObjectSets = numel(objectSets);
recipes = cell(nBaseScenes, nObjectSets);
for bb = 1:nBaseScenes
    baseScene = baseScenes{bb};
    
    for oo = 1:nObjectSets
        objectSet = objectSets{oo};
        recipes{bb, oo} = vseBuildRecipe(baseScene, objectSet, styleSets, 'hints', hints);
    end
end


%% Render the shoes off those recipes.
for bb = 1:nBaseScenes
    for oo = 1:nObjectSets
        recipes{bb, oo} = rtbExecuteRecipe(recipes{bb, oo});
    end
end
