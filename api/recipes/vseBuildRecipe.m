function recipe = vseBuildRecipe(outerModel, innerModels, styleSets, varargin)
%% Combine models and styles to make a stand-alone RenderToolbox recipe.
%
% The idea here is that the caller can create various models and styles
% that are independent of each other, then use this function to combine
% them into a recipe.  Keeping the inputs independent until the last minute
% should help us generate myriad recipes by re-combining models and styles.
%
% recipe = vseBuildRecipe(outerModel, innerModels, styleSets) combines the
% given outerModel (a VseModel) with zero or more innerModels (an array of
% VseModel), to make one big model.  This big model is then combined with
% each array of VseStyles in the given styleSets to produce a rendering
% mappings and conditions, one for each style set.
%
% Returns one stand-alone RenderToolbox recipe which represents the
% "product" of the model and style inputs.
%
% vseBuildRecipe( ... 'hints', hints) specify a RenderToolbox
% hints struct to use for the recipe.  You might want to specify things
% like hints.renderer, hints.recipeName, hints.imageHeight, etc. See
% rtbDefaultHints().
%
% recipe = vseBuildRecipe(outerModel, innerModels, styles)
%

parser = MipInputParser();
parser.addRequired('outerModel', @(val) isa(val, 'VseModel'));
parser.addRequired('innerModels', @(val) isempty(val) || isa(val, 'VseModel'));
parser.addRequired('styleSets', @iscell);
parser.addParameter('hints', rtbDefaultHints(), @isstruct);
parser.parseMagically('caller');

hints = rtbDefaultHints(hints);

%% Combine models into one.
bigModel = VseModel.bigModel(outerModel, innerModels);

if isempty(hints.recipeName)
    if isempty(bigModel.name)
        hints.recipeName = 'virtualScene';
    else
        hints.recipeName = bigModel.name;
    end
end

resourceFolder = rtbWorkingFolder('folderName', 'resources', 'hints', hints);
bigSceneFile = fullfile(resourceFolder, [hints.recipeName '.mat']);
mexximpSave(bigModel.model, bigSceneFile);


%% Genereate mappings for each style set.
nStyleSets = numel(styleSets);
bigStyleNames = cell(1, nStyleSets);
bigConfigs = cell(1, nStyleSets);
bigMaterials = cell(1, nStyleSets);
bigIlluminants = cell(1, nStyleSets);
for ss = 1:nStyleSets
    styles = styleSets{ss};
    models = [outerModel innerModels];
    
    % get a name to represent this ss-th style set
    styleName = VseStyle.bigName(styles, 'prefix', sprintf('%d', ss));
    bigStyleNames{ss} = styleName;
    
    % combine renderer configs across this style set
    config = VseStyle.bigRendererConfig(styles);
    bigConfigs{ss} = VseMapping.reify(config, 'group', styleName);
    
    % roll out materials from this style set, over the given models
    materials = vseBigMaterials(models, styles, 'group', styleName);
    bigMaterials{ss} = materials;
    
    % roll out illuminants from this style set, over the given models
    illuminants = vseBigIlluminants(models, styles, 'group', styleName);
    bigIlluminants{ss} = illuminants;
end

allMappings = [bigConfigs{:} bigMaterials{:} bigIlluminants{:}];
if isempty(allMappings)
    mappingsFile = '';
else
    mappingsFile = fullfile(resourceFolder, [hints.recipeName '_Mappings.json']);
    rtbWriteJson(allMappings, 'fileName', mappingsFile);
end


%% Generate the conditions file.
names = {'imageName', 'groupName'};
values = cat(2, bigStyleNames', bigStyleNames');

conditionsFile = fullfile(resourceFolder, [hints.recipeName '_Conditions.txt']);
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
