function bigMaterials = vseBigMaterials(models, styles, varargin)
% Apply material styles to materials in the given models.
%
% The idea here is to "reify" the given styles so they can be applied to
% the given 3D models.  This has two parts.  First, iterates the given
% models and styles in parallel, to form pairs or material arrays and
% styles.  Then, for each pair of (material array, style), "unroll" the
% style over the materials in the array.  The result is a big array of
% mappings that crosses the given models with the given styles.
%
% bigMaterials = vseBigMaterials(models, styles, varargin) iterates the
% given models (array of VseModel) and styles (an array of VseStyles),
% wrapping styles as needed, to form pairs.  In each pair, applies a
% material in the style to each of the mexximp materials in the model and
% "reifies" the result as a RenderToolbox mapping that points to the
% specific material by name and index.
%
% vseBigMaterials( ... 'group', group) specifies a group name to use for
% the generated mappings.  The default is '', don't use any group name.
%
% Returns a big array of RenderToolbox mappings which represents the given
% materials "crossed" with the given styles.
%

parser = MipInputParser();
parser.addRequired('models', @(val) isa(val, 'VseModel'));
parser.addRequired('styles', @(val) isempty(val) || isa(val, 'VseStyle'));
parser.addParameter('group', '', @ischar);
parser.parseMagically('caller');


%% "Unroll" styles to get one for each model.
nModels = numel(models);
modelStyles = VseStyle.wrappedStyles(styles, 1:nModels);


%% "Unroll" each style over its corresponding model materials.
workingMaterials = cell(1, nModels);
materialIndexOffset = 0;
for mm = 1:nModels
    if isempty(modelStyles)
        style = [];
    else
        style = modelStyles(mm);
    end
    materials = models(mm).model.materials;
    
    % get the name and index of each material
    %   index is offset for each model
    nMaterials = numel(materials);
    names = cell(1, nMaterials);
    indexes = cell(1, nMaterials);
    for nn = 1:nMaterials
        indexes{nn} = nn + materialIndexOffset;
        
        % get the data of the material property with the "name" key
        q = {'key', @(s) strcmp(s, 'name')};
        p = {'properties', q, 'data'};
        names{nn} = mPathGet(materials(nn), p);
    end
    materialIndexOffset = materialIndexOffset + nMaterials;
    
    % make style mappings concrete using material names and indexes
    if ~isempty(style)
        styleMaterials = style.getWrapped('materials', 1:nMaterials);
        workingMaterials{mm} = VseMapping.reify(styleMaterials, ...
            'name', names, ...
            'index', indexes, ...
            'operation', 'update', ...
            'group', group);
    end
end
bigMaterials = [workingMaterials{:}];
