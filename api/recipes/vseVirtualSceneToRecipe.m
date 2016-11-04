function recipe = vseVirtualSceneToRecipe(virtualScene, varargin)
%% Convert a virtual scene to a stand-alone RenderToolbox recipe.
%
% recipe = vseVirtualSceneToRecipe(virtualScene) converts the given
% VseVirtualScene object into a RenderToolbox4 recipe that can be executed
% with rtbExecuteRecipe().
%
% vseVirtualSceneToRecipe( ... 'hints', hints) specify a RenderToolbox
% hints struct to use for the recipe.  You might want to specify things
% like hints.renderer, hints.recipeName, hints.imageHeight, etc. See
% rtbDefaultHints().
%
% recipe = vseVirtualSceneToRecipe(virtualScene, varargin)

parser = MipInputParser();
parser.addRequired('virtualScene', @(val) isa(val, 'VseVirtualScene'));
parser.addParameter('hints', rtbDefaultHints(), @isstruct);
parser.parseMagically('caller');

hints = rtbDefaultHints(hints);
if isempty(hints.recipeName)
    hints.recipeName = virtualScene.name;
end


%% Combine models into one.
bigModel = virtualScene.bigModel();
resourceFolder = rtbWorkingFolder('folderName', 'resources', 'hints', hints);
bigSceneFile = fullfile(resourceFolder, [virtualScene.name '.mat']);
mexximpSave(bigModel, bigSceneFile);


%% Genereate mappings for each style.
nStyles = virtualScene.styleCount();
bigStyleNames = cell(1, nStyles);
bigConfigs = cell(1, nStyles);
bigMaterials = cell(1, nStyles);
bigIlluminants = cell(1, nStyles);
for ss = 1:nStyles
    % combine ss-th style name across all combos in the scene
    styleName = virtualScene.bigStyleName(ss);
    bigStyleNames{ss} = styleName;
    
    % renderer config
    config = virtualScene.bigRendererConfig(ss);
    bigConfigs{ss} = rtbValidateMappings(config);
    
    % materials
    [materials, materialIndices] = virtualScene.bigMaterialValues(ss);
    bigMaterials{ss} = vseStyleValuesToMappings( ...
        materials, materialIndices, {}, 'update', styleName);
    
    % illuminants
    [illuminants, meshIndices, meshNames] = virtualScene.bigIlluminantValues(ss);
    bigIlluminants{ss} = vseStyleValuesToMappings( ...
        illuminants, meshIndices, meshNames, 'blessAsAreaLight', styleName);
end

allMappings = [bigConfigs{:} bigMaterials{:} bigIlluminants{:}];
mappingsFile = fullfile(resourceFolder, [virtualScene.name '_Mappings.json']);
rtbWriteJson(allMappings, 'fileName', mappingsFile);


%% Generate the conditions file.
names = {'imageName', 'groupName'};
values = cat(2, bigStyleNames', bigStyleNames');

conditionsFile = fullfile(resourceFolder, [virtualScene.name '_Conditions.txt']);
rtbWriteConditionsFile(conditionsFile, names, values);


%% Build the actual recipe.
executive = { ...
    @rtbMakeRecipeSceneFiles, ...
    @rtbMakeRecipeRenderings, ...
    @(recipe)rtbMakeRecipeMontage(recipe, 'toneMapFactor', 100, 'isScale', true), ...
    };

recipe = rtbNewRecipe( ...
    'executive', executive, ...
    'parentSceneFile', bigSceneFile, ...
    'conditionsFile', conditionsFile, ...
    'mappingsFile', mappingsFile, ...
    'hints', hints);
