function bigIlluminants = vseBigIlluminants(models, styles, varargin)
% Apply illuminant styles to meshes in the given models.
%
% The idea here is to "reify" the given styles so they can be applied to
% the given 3D models.  This has two parts.  First, iterates the given
% models and styles in parallel, to form pairs or mesh arrays and
% styles.  Then, for each pair of (mesh array, style), "unroll" the
% style over the meshes in the array.  The result is a big array of
% mappings that crosses the given models with the given styles.
%
% bigIlluminants = vseBigIlluminants(models, styles) iterates the
% given models (array of VseModel) and styles (an array of VseStyles),
% wrapping styles as needed, to form pairs.  In each pair, applies an
% illuminant in the style to selected mexximp meshes in the model and
% "reifies" the result as a RenderToolbox mapping that points to the
% specific mesh by name and index.
%
% vseBigIlluminants( ... 'group', group) specifies a group name to use for
% the generated mappings.  The default is '', don't use any group name.
%
% Returns a big array of RenderToolbox mappings which represents the given
% meshes "crossed" with the given styles.
%

parser = MipInputParser();
parser.addRequired('models', @(val) isa(val, 'VseModel'));
parser.addRequired('styles', @(val) isempty(val) || isa(val, 'VseStyle'));
parser.addParameter('group', '', @ischar);
parser.parseMagically('caller');


%% "Unroll" styles to get one for each array of meshes.
nModels = numel(models);
modelStyles = VseStyle.wrappedStyles(styles, 1:nModels);


%% "Unroll" each style over its corresponding array of meshes.
workingIlluminants = cell(1, nModels);
meshIndexOffset = 0;
for mm = 1:nModels
    if isempty(modelStyles)
        style = [];
    else
        style = modelStyles(mm);
    end
    meshes = models(mm).model.meshes;
    meshSelector = models(mm).areaLightMeshSelector;
    
    % select meshes for this model using the corresponding selector
    selectedMeshes = meshes(meshSelector);
    
    % get the name and index of each selected mesh
    %   index is offset for each model
    names = {selectedMeshes.name};
    indexes = num2cell(find(meshSelector) + meshIndexOffset);
    meshIndexOffset = meshIndexOffset + numel(meshes);
    
    % make style mappings concrete using mesh names and indexes
    if ~isempty(style)
        nSelected = numel(selectedMeshes);
        styleIlluminants = style.getWrapped('illuminants', 1:nSelected);
        workingIlluminants{mm} = VseMapping.reify(styleIlluminants, ...
            'name', names, ...
            'index', indexes, ...
            'operation', 'blessAsAreaLight', ...
            'group', group);
    end
end
bigIlluminants = [workingIlluminants{:}];
