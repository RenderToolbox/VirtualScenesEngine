function mappings = vseStyleValuesToMappings(styleValues, indices, names, operation, group)
% Expand styleValues into equivalent RenderToolbox mappings.

parser = MipInputParser();
parser.addRequired('styleValues', @(val) isempty(val) || isa(val, 'VseStyleValue'));
parser.addRequired('indices', @isnumeric);
parser.addRequired('names', @iscell);
parser.addRequired('operation', @ischar);
parser.addRequired('group', @ischar);
parser.parseMagically('caller');

if isempty(styleValues)
    mappings = [];
    return;
end

if isempty(names)
    names = '';
end

rawMappings = struct( ...
    'broadType', {styleValues.broadType}, ...
    'destination', {styleValues.destination}, ...
    'group', group, ...
    'index', num2cell(indices), ...
    'name', names, ...
    'operation', operation, ...
    'specificType', {styleValues.specificType}, ...
    'properties', {styleValues.props});
mappings = rtbValidateMappings(rawMappings);
