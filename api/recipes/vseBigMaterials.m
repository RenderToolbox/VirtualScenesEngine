function bigMaterials = vseBigMaterials(modelMaterials, styles, varargin)
% Apply material styles to mexximp materials, for specific 3D models.
%
% The idea here is to take the materials arrays from several mexximp
% models, and for each choose a corresponding style.  Then, for each
% pair of (material array, style), "unroll" the style over the materials in
% the array.  The result is a big array of mappings that crosses the given
% materials with the given styles.  This "reifies" the styles so they can be
% applied to specific 3D models.
%
% bigMaterials = vseBigMaterials(modelMaterials, styles) iterates the given
% modelMaterials (cell array with each element an array of mexximp
% materials) and styles (an array of VseStyles) to form pairs.  In each
% pair, applies a material in the style to one of the mexximp materials and
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
parser.addRequired('modelMaterials', @isCell);
parser.addRequired('styles', @(val) isa(val, 'VseStyle'));
parser.addParameter('group', '', @ischar);
parser.parseMagically('caller');


%% "Unroll" styles to get one for each array of materials.
nModels = numel(modelMaterials);
modelStyles = VseStyle.wrappedStyles(styles, 1:nModels);


%% "Unroll" each style over its corresponding array of materials.
workingMaterials = cell(1, nModels);
materialIndexOffset = 0;
for mm = 1:nModels
    style = modelStyles(mm);
    materials = modelMaterials{mm};
    
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
        indexes{nn} = mPathGet(materials(nn), p);
    end
    materialIndexOffset = materialIndexOffset + nMaterials;
    
    % make style mappings concrete using material names and indexes
    styleMaterials = style.getWrapped('materials', 1:nMaterials);
    workingMaterials{mm} = VseMapping.reify(styleMaterials, ...
        'name', names, ...
        'index', indexes, ...
        'operation', 'update', ...
        'group', group);
end
bigMaterials = [workingMaterials{:}];
