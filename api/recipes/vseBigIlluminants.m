function bigIlluminants = vseBigIlluminants(modelMeshes, modelMeshSelectors, styles, varargin)
% Apply illuminant styles to mexximp meshes, for specific 3D models.
%
% The idea here is to take mesh arrays from several mexximp
% models, and for each choose a corresponding style.  Then, for each
% pair of (mesh array, style), "unroll" the style over the meshes in
% the array.  The result is a big array of mappings that crosses the given
% meshes with the given styles.  This "reifies" the styles so they can be
% applied to specific 3D models.
%
% bigIlluminants = vseBigIlluminants(modelMeshes, modelMeshSelectors,
% styles) iterates the given modelMeshes (cell array with each element an
% array of mexximp meshes), modelMeshSelectors (cell array with each
% element a logical array), and styles (an array of VseStyles) to form
% triples.  In each triple, selectes a subset of meshes using the mesh
% selector, then applies an illuminant in the style to one of the mexximp
% materials and "reifies" the result as a RenderToolbox mapping that points
% to the specific mesh by name and index.
%
% vseBigIlluminants( ... 'group', group) specifies a group name to use for
% the generated mappings.  The default is '', don't use any group name.
%
% Returns a big array of RenderToolbox mappings which represents the given
% meshes "crossed" with the given styles.
%

parser = MipInputParser();
parser.addRequired('modelMeshes', @isCell);
parser.addRequired('modelMeshSelectors', @isCell);
parser.addRequired('styles', @(val) isa(val, 'VseStyle'));
parser.addParameter('group', '', @ischar);
parser.parseMagically('caller');


%% "Unroll" styles to get one for each array of meshes.
nModels = numel(modelMeshes);
modelStyles = VseStyle.wrappedStyles(styles, 1:nModels);


%% "Unroll" each style over its corresponding array of meshes.
workingIlluminants = cell(1, nModels);
meshIndexOffset = 0;
for mm = 1:nModels
    style = modelStyles(mm);
    meshes = modelMeshes{mm};
    meshSelector = modelMeshSelectors{mm};
    
    % select meshes for this model using the corresponding selector
    selectedMeshes = meshes(meshSelector);
    
    % get the name and index of each selected mesh
    %   index is offset for each model
    names = {selectedMeshes.name};
    indexes = num2cell(find(meshSelector) + meshIndexOffset);
    meshIndexOffset = meshIndexOffset + nMeshes;
    
    % make style mappings concrete using mesh names and indexes
    nSelected = numel(selectedMeshes);
    styleIlluminants = style.getWrapped('illuminants', 1:nSelected);
    workingIlluminants{mm} = VseMapping.reify(styleIlluminants, ...
        'name', names, ...
        'index', indexes, ...
        'operation', 'blessAsAreaLight', ...
        'group', group);
end
bigIlluminants = [workingIlluminants{:}];
