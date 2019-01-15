% Clear the workspace
close all;
clearvars;
% sca;

% Screen('Preference', 'SkipSyncTests', 1);

% Setup PTB with some default values
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

% Flip to clear
Screen('Flip', window);

% Get the size of the on screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


% -----------------------------------
% Keyboard
% -----------------------------------
% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
downKey = KbName('DownArrow');

% directory
rootDir = pwd;
instrDir = 'instruction';
stimliDir = 'stimuli';

color = {'red', 'green', 'blue'};
word = {'red', 'green', 'blue'};

trialtimes = 2;

% Make the matrix which will determine our condition combinations
condMatrixBase = [sort(repmat([1 2 3], 1, 3)); repmat([1 2 3], 1, 3)];
% Duplicate the condition matrix to get the full number of trials
condMatrix = repmat(condMatrixBase, 1, trialtimes);
% Get the size of the matrix
[~, numTrials] = size(condMatrix);
% Randomise the conditions
shuffler = Shuffle(1:numTrials);
condMatrixShuffled = condMatrix(:, shuffler);

%-------------------------------------------
%           Make a response matrix
%-------------------------------------------
% This is a four row matrix the first row will record the word we present,
% the second row the color the word it written in, the third row the key
% they respond with and the final row the time they took to make there response.
respMat = nan(4, trialtimes*length(color)*length(word));


theFixation = imread([rootDir, '\', instrDir, '\', 'fixation.tif']);
theColorInstruction = imread([rootDir, '\', instrDir, '\', 'color_instruction.tif']);
thewordInstruction = imread([rootDir, '\', instrDir, '\', 'word_instruction.tif']);
theQuitInstruction = imread([rootDir, '\', instrDir, '\', 'quit_instruction.tif']);
%--------------------------------------------
%                Show stimuli
%--------------------------------------------
% Color judgement
imageTexture = Screen('MakeTexture', window, theColorInstruction);
Screen('DrawTexture', window, imageTexture);
Screen('Flip', window);
KbStrokeWait;   

% Prepare stimuli
stimuli_list = {};

for trial = 1:numTrials
    % Word and color number
    wordNum = condMatrixShuffled(1, trial);
    colorNum = condMatrixShuffled(2, trial);
    theColor = color(colorNum);
    theWord = word(wordNum);
    % Fixation
    imageTexture = Screen('MakeTexture', window, theFixation);
    Screen('DrawTexture', window, imageTexture);
    Screen('Flip', window);
    WaitSecs(0.5);
    % Stimuli
    respToBeMade = true;
    theStimuli = imread([rootDir, '\', stimliDir, '\', char(color(1,colorNum)), '_', char(word(1,wordNum)),'.tif']);
    tStart = GetSecs;
    while respToBeMade == true
        imageTexture = Screen('MakeTexture', window, theStimuli);
        Screen('DrawTexture', window, imageTexture);
        % Draw the fixation point
        Screen('DrawDots', window, [screenXpixels-10, screenYpixels-], 10, black, [], 2);
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(leftKey)
            response = 1;
            respToBeMade = false;
        elseif keyCode(downKey)
            response = 2;
            respToBeMade = false;
        elseif keyCode(rightKey)
            response = 3;
            respToBeMade = false;
        end
        Screen('Flip', window);
    end
    tEnd = GetSecs;
    rt = tEnd - tStart;
    
    % Record the trial data into out data matrix
    respMat(1, trial) = wordNum;
    respMat(2, trial) = colorNum;
    respMat(3, trial) = response;
    respMat(4, trial) = rt;
end

imageTexture = Screen('MakeTexture', window, theQuitInstruction);
Screen('DrawTexture', window, imageTexture);
Screen('Flip', window);
KbStrokeWait;
% sca;








