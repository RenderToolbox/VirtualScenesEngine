%% Create ToolboxToolbox configuration for VirtualScenesAssets.

config = [ ...
    tbToolboxRecord( ...
    'name', 'MagicInputParser', ...
    'type', 'include'), ...
    tbToolboxRecord( ...
    'name', 'mexximp', ...
    'type', 'include'), ...
    tbToolboxRecord( ...
    'name', 'RenderToolbox4', ...
    'type', 'include'), ...
    tbToolboxRecord( ...
    'name', 'VirtualScenesAssets', ...
    'type', 'include'), ...
    tbToolboxRecord( ...
    'name', 'VirtualScenesEngine', ...
    'type', 'git', ...
    'url', 'https://github.com/RenderToolbox/VirtualScenesEngine.git'), ...
    ];

pathHere = fileparts(mfilename('fullpath'));
configPath = fullfile(pathHere, 'vseToolboxConfig.json');
tbWriteConfig(config, 'configPath', configPath);