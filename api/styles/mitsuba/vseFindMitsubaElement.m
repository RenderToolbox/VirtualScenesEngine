function mitsubaElement = vseFindMitsubaElement(mitsubaScene, mexximpElement, varargin)
%% Find an mMitsuba object corresponding to a mexximp scene element.
%
% mitsubaElement = vseFindMitsubaElement(mitsubaScene, mexximpElement)
% searches the given mitsubaScene for an mMitsuba element that corresponds
% to the given mexximpElement and returns it.  If no such element was
% found, returns [].
%
% vseFindMitsubaElement( ... 'type', type) specify the type of mMitsuba
% element to search for, like 'sensor' or 'bsdf'.  The default is taken
% from the given mexximpElement.type.
%
% vseFindMitsubaElement( ... 'delete', delete) whether or not to delete the
% mMitsuba element if found.  The default is false, don't delete it.
%

parser = inputParser();
parser.addRequired('mitsubaScene', @isobject);
parser.addRequired('mexximpElement', @isstruct);
parser.addParameter('type', '', @ischar);
parser.addParameter('delete', false, @islogical);
parser.parse(mitsubaScene, mexximpElement, varargin{:});
mitsubaScene = parser.Results.mitsubaScene;
mexximpElement = parser.Results.mexximpElement;
type = parser.Results.type;
delete = parser.Results.delete;

if isempty(type)
    type = mexximpElement.broadType;
end

% search for exact name by itself, or formatted index_name pattern
name = mexximpElement.name;
index = mexximpElement.path{end};
[mitsubaId, idMatcher] = mexximpCleanName(name, index);
if isempty(idMatcher)
    searchPattern = '';
else
    searchPattern = sprintf('^%s$|%s', mitsubaId, idMatcher);
end

mitsubaElement = mitsubaScene.find(searchPattern, 'type', type);

