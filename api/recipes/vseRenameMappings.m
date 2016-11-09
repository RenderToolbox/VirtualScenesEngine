function renamedMappings = vseRenameMappings(vseMappings, varargin)
% Rename and re-index mappings to fit a particular model.

parser = MipInputParser();
parser.addRequired(vseMappings, @(val) isa(val, 'VseMapping'));
parser.addParameter('name', {vseMappings.name});
parser.addParameter('index', {vseMappings.index});
parser.addParameter('group', {vseMappings.group});
parser.addParameter('operation', {vseMappings.operation});
parser.parseMagically('caller');

if isempty(vseMappings)
    renamedMappings = [];
    return;
end

rawMappings = struct( ...
    'name', name, ...
    'index', index, ...
    'group', group, ...
    'operation', operation, ...
    'broadType', {vseMappings.broadType}, ...
    'destination', {vseMappings.destination}, ...
    'specificType', {vseMappings.specificType}, ...
    'properties', {vseMappings.props});
renamedMappings = rtbValidateMappings(rawMappings);
