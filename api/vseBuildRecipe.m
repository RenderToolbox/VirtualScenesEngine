function recipe = vseBuildRecipe(outerModel, innerModels, varargin)
%% Combine models and styles to make a stand-alone RenderToolbox recipe.
%
% The idea here is that the caller can create various models and styles
% that are independent of each other, then use this function to combine
% them into a recipe.  Keeping the inputs independent until the last minute
% should help us generate myriad recipes by re-combining models and styles.
%
% recipe = vseBuildRecipe(outerModel, innerModels, styles)
% combines the given outerModel (a VseModel) with zero or
% more innerModels (an array of VseModel), to make one big model.  This big
% model is then combined with the given styles (struct of VseStyle
% arrays), with one rendering condition per field of the given styles
% struct.
%
% Returns one stand-alone RenderToolbox recipe which represents the
% "product" of the models and styles.
%
% vseBuildRecipe( ... 'hints', hints) specify a RenderToolbox
% hints struct to use for the recipe.  You might want to specify things
% like hints.renderer, hints.recipeName, hints.imageHeight, etc. See
% rtbDefaultHints().
%
% recipe = vseBuildRecipe(outerModel, innerModels, styles, varargin)
%

parser = MipInputParser();
parser.addRequired('outerModel', @(val) isa(val, 'VseModel'));
parser.addRequired('innerModels', @(val) isempty(val) || isa(val, 'VseModel'));
parser.addParameter('hints', rtbDefaultHints(), @isstruct);
parser.parseMagically('caller');

% let parser collect extra struct or named parameters as named styles
styles = parser.Unmatched;

hints = rtbDefaultHints(hints);


%% Combine models into one.
[bigModel, outerElements, innerElements] = VseModel.combine(outerModel, innerModels);

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


%% Organize model elements for easy filtering per style, later.
elementFilterInfo = VseStyle.elementFilterInfo(outerModel.name, outerElements, false);
if ~isempty(innerModels)
    innerInfo = VseStyle.elementFilterInfo({innerModels.name}, innerElements, true);
    elementFilterInfo = [elementFilterInfo innerInfo];
end


%% Generate the conditions file.
conditionsVariables = {'imageName', 'styleName'};

styleNames = fieldnames(styles);
conditionsValues = cat(2, styleNames', styleNames');

conditionsFile = fullfile(resourceFolder, [hints.recipeName '_Conditions.txt']);
rtbWriteConditionsFile(conditionsFile, conditionsVariables, conditionsValues);


%% Wire up hook functions that will apply styles.
hints.batchRenderStrategy = RtbAssimpStrategy(hints);

hints.batchRenderStrategy.remodelPerConditionAfterFunction = ...
    @(scene, mappings, names, conditionValues, cc) vseApplyMexximpStyles( ...
    scene, mappings, names, conditionValues, cc, styles, elementFilterInfo, hints);

hints.batchRenderStrategy.converter.remodelAfterMappingsFunction = ...
    @(scene, nativeScene, mappings, names, conditionValues, cc) vseApplyNativeStyles( ...
    scene, nativeScene, mappings, names, conditionValues, cc, styles, elementFilterInfo, hints);


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
    'hints', hints);
recipe.input.styles = styles;
