function [styles, inner, outer, recipes] = vseProofOfConept(varargin)
%% Proof of concept for the VirtualScenesEngine.

parser = inputParser();
parser.addParameter('aioPrefs', [], @isstruct);
parser.addParameter('outer', {}, @iscell);
parser.addParameter('inner', {}, @iscell);
parser.addParameter('styles', [], @isstruct);
parser.addParameter('hints', [], @isstruct);
parser.addParameter('showFigures', true, @islogical);
parser.parse(varargin{:});
aioPrefs = parser.Results.aioPrefs;
outer = parser.Results.outer;
inner = parser.Results.inner;
styles = parser.Results.styles;
hints = parser.Results.hints;
showFigures = parser.Results.showFigures;


%% Confgigure where to find assets.
if isempty(aioPrefs)
    aioPrefs.locations = aioLocation( ...
        'name', 'VirtualScenesExampleAssets', ...
        'strategy', 'AioFileSystemStrategy', ...
        'baseDir', fullfile(vseaRoot(), 'examples'));
end

%% Choose some base scenes.
if isempty(outer)
    mill = VseModel.fromAsset('BaseScenes', 'Mill', ...
        'aioPrefs', aioPrefs, ...
        'nameFilter', 'blend$');
    
    library = VseModel.fromAsset('BaseScenes', 'Library', ...
        'aioPrefs', aioPrefs, ...
        'nameFilter', 'blend$');
    
    outer = {mill, library};
end


%% Choose some objects to insert into the base scenes.
if isempty(inner)
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
    
    inner = {[], [xylophone barrel ringToy]};
end

%% Define some styles that are independent of the models.
if isempty(styles)
    
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
end

%% Choose batch render options.
if isempty(hints)
    hints.fov = deg2rad(60);
    hints.imageHeight = 240;
    hints.imageWidth = 320;
    hints.renderer = 'Mitsuba';
end

%% Make recipes that cross the base scenes, objects, and styles.

nBaseScenes = numel(outer);
nObjectSets = numel(inner);
recipes = cell(nBaseScenes, nObjectSets);
for bb = 1:nBaseScenes
    baseScene = outer{bb};
    
    for oo = 1:nObjectSets
        objectSet = inner{oo};
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
if ~showFigures
    return;
end

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
