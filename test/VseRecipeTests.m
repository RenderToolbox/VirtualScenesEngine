classdef VseRecipeTests < matlab.unittest.TestCase
    % Test basic behaviors for building RenderToolbox recipes.
    
    properties
        checkerboardFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'CheckerBoard.blend');
        ballSceneFile = fullfile(fileparts(mfilename('fullpath')), 'fixture', 'BigBall.blend');
        tempFolder = fullfile(tempdir(), 'VseRecipeTests');
    end
    
    methods (TestMethodSetup)
        function resetFixtureAssets(testCase)
            % fresh temp folder
            if 7 == exist(testCase.tempFolder, 'dir')
                rmdir(testCase.tempFolder, 's')
            end
        end
    end
    
    methods (Test)
        

    end
end
