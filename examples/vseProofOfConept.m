%% Early proof of concept for the VirtualScenesEngine.

clear;
clc;

%% Confgigure where to find assets.
aioPrefs.locations = aioLocation( ...
    'name', 'VirtualScenesExampleAssets', ...
    'strategy', 'AioFileSystemStrategy', ...
    'baseDir', fullfile(vseaRoot(), 'examples'));


%% Choose some base scenes.
mill = VseModel.fromAsset('BaseScenes', 'Mill', ...
    'aioPrefs', aioPrefs, ...
    'nameFilter', 'blend$');

library = VseModel.fromAsset('BaseScenes', 'Library', ...
    'aioPrefs', aioPrefs, ...
    'nameFilter', 'blend$');

baseScenes = {mill, library};


%% Choose some objects to insert into the base scenes.
xylophone = VseModel.fromAsset('Objects', 'Xylophone', ...
    'aioPrefs', aioPrefs, ...
    'nameFilter', 'blend$');
xylophone.transformation = mexximpTranslate([0 1 -3]);
xylophone.transformationRelativeToCamera = true;

barrel = VseModel.fromAsset('Objects', 'Barrel', ...
    'aioPrefs', aioPrefs, ...
    'nameFilter', 'blend$');
barrel.transformation = mexximpTranslate([-1 0 -3]);
barrel.transformationRelativeToCamera = true;

ringToy = VseModel.fromAsset('Objects', 'RingToy', ...
    'aioPrefs', aioPrefs, ...
    'nameFilter', 'blend$');
ringToy.transformation = mexximpTranslate([1 -1 -3]);
ringToy.transformationRelativeToCamera = true;

objectSets = {[], [xylophone barrel ringToy]};


%% Define some styles that are independent of the models.

% lights
blessAreaLights = VseMitsubaAreaLights( ...
    'name', 'blessAreaLights', ...
    'applyToInnerModels', false);

plainLights = VseMitsubaEmitterSpectra( ...
    'name', 'plainLights', ...
    'pluginType', 'area', ...
    'propertyName', 'radiance');
plainLights.addSpectrum('300:0.1 800:0.1');

redBlueLights = VseMitsubaEmitterSpectra( ...
    'name', 'redBlueLights', ...
    'pluginType', 'area', ...
    'propertyName', 'radiance');
redBlueLights.addSpectrum('300:0.2 800:0.0');
redBlueLights.addSpectrum('300:0.0 800:0.2');

% materials
plainDiffuse = VseMitsubaDiffuseMaterials( ...
    'name', 'plainDiffuse');
plainDiffuse.addSpectrum('300:1 800:1');

colorCheckerFiles = aioGetFiles('Reflectances', 'ColorChecker', ...
    'aioPrefs', aioPrefs, ...
    'fullPaths', false);
colorCheckerDiffuse = VseMitsubaDiffuseMaterials( ...
    'name', 'colorCheckerDiffuse', ...
    'applyToInnerModels', false);
colorCheckerDiffuse.addManySpectra(colorCheckerFiles);

textureFiles = aioGetFiles('Textures', 'OpenGameArt', ...
    'aioPrefs', aioPrefs, ...
    'fullPaths', false);
texturedDiffuse = VseMitsubaDiffuseMaterials( ...
    'name', 'texturedDiffuse', ...
    'applyToOuterModels', false);
texturedDiffuse.addManyTextures(textureFiles);

styles.none = {};
styles.plain = {blessAreaLights, plainLights, plainDiffuse};
styles.colorsAndTextures = {blessAreaLights, redBlueLights, colorCheckerDiffuse, texturedDiffuse};


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
        recipes{bb, oo} = vseBuildRecipe(baseScene, objectSet, ...
            'hints', hints, ...
            styles);
    end
end


%% Render the shoes off those recipes.
for bb = 1:nBaseScenes
    for oo = 1:nObjectSets
        recipes{bb, oo} = rtbExecuteRecipe(recipes{bb, oo});
    end
end


%% Show each rendering in its own, separately scaled plot.
for bb = 1:nBaseScenes
    for oo = 1:nObjectSets
        radianceDataFiles = recipes{bb, oo}.rendering.radianceDataFiles;
        nFiles = numel(radianceDataFiles);
        for ff = 1:nFiles
            [~, imageName] = fileparts(radianceDataFiles{ff});
            name = sprintf('%s_%s', ...
                recipes{bb, oo}.input.hints.recipeName, ...
                imageName);
            imagesFolder = rtbWorkingFolder( ...
                'folderName', 'images', ...
                'rendererSpecific', true, ...
                'hints', recipes{bb, oo}.input.hints);
            montageFile = fullfile(imagesFolder, [name '.png']);
            
            srgbImage = rtbMakeMontage(radianceDataFiles(ff), ...
                'outFile', montageFile, ...
                'toneMapFactor', 100, ...
                'isScale', true);
            
            figure();
            imshow(uint8(srgbImage));
            title(name, 'Interpreter', 'none');
            drawnow();
        end
    end
end