function fMRI_somatotopy_mapping(subjectID,runID,blockDur,cueType)
% fMRI_somatotopy_mapping(subjectID,runID,blockDur,cueType)
% Subject presses R key to indicate she/he is ready.
% Then, the experimenter presses S key to begin the experiment.
% cueType: static or dynamic cue to indicate task switching

%% Arguments
if nargin < 4, cueType  = 'static'; end % static or dynamic
if nargin < 3, blockDur = 5;end
if nargin < 2, runID = 1;end

%% Print test information
fprintf('Runing fMRI Somatotopy Mapping\n');
fprintf('Subject ID: %s\n',subjectID);
fprintf('Run ID: %d\n',runID);
fprintf('Block Duration: %.2f\n',blockDur);

%% preprare the screen
sca; % close all screen
Screen('Preference', 'SkipSyncTests', 1);% skip sync tests

% Setup PTB with some default values
PsychDefaultSetup(2);
% Set the screen number to the secondary monitor
screenNumber = max(Screen('Screens'));
% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
% black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect]= PsychImaging('OpenWindow', screenNumber, white);
% Flip to clear
Screen('Flip', window);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

%% Make texture for task
stimImg  = strcat('stimuli','\', extractfield(dir(fullfile('stimuli','*.JPG')),'name'))';
nTask = length(stimImg);
stimTexture = zeros(nTask,1);
for i = 1:length(stimImg)
    img = imread(stimImg{i});
    stimTexture(i) = Screen('MakeTexture', window,img);
end

%% Design
% Group ten motor task into two sets
blockSet = [1,6,4,12,2,7;
            9,8,11,3,5,10]';
nBlock = size(blockSet,1);

% The order of blocks(set)
% 1, foot,leftleg,forearm ,eye,lip;
% 2, rightleg,upperarm,hand,jaw,tongue,
order = randperm(2);
setOrder = [order,fliplr(order)];
nSet = length(setOrder);
switchCueDur = 0.5;

%% Set keys
startKey = KbName('s');
escKey = KbName('ESCAPE');
readyKey = KbName('r');

% RespondKey1 = KbName('2@');
% RespondKey2 = KbName('3#');
% RespondKey = KbName('1!');

%% Check ready for subject
Screen('DrawTexture', window, stimTexture(end-1));
Screen('Flip', window);

% Wait ready signal
while KbCheck; end
while true
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown && keyCode(readyKey)
        break;
    elseif keyIsDown && keyCode(escKey)
        sca;
        return
    end
end
Screen('Flip', window);

%% Wait trigger to begin the (MRI)experiment
while KbCheck; end
while true
    [keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown && keyCode(startKey)
        break
    elseif keyIsDown && keyCode(escKey),
        Screen('CloseAll'); ShowCursor;
        disp('ESC is pressed to abort the program.');
        return;
    end
end

%% Run fMRI experiment 
%Iterate for block sets
for s = 1:nSet
    blocks = blockSet(randperm(nBlock),setOrder(s));
    
    % begining baseline
    Screen('DrawDots', window, [xCenter, yCenter], 40, [0 0 0], [], 2);
    tBegin = Screen('Flip', window);
    while GetSecs - tBegin < blockDur-2,
        % empty the key buffer
        while KbCheck, end
        keyIsDown = KbCheck;
        if keyIsDown
            sca; return;
        end
    end
    
    % static cue for task switching
    if strcmp(cueType,'static')
        while GetSecs - tBegin < blockDur,
            Screen('DrawDots', window, [xCenter, yCenter], 40, [1 0 0], [], 2);
            Screen('Flip', window);
        end
        
    % dynamic cue for task switching
    else    
        while GetSecs - tBegin < blockDur,
            Screen('DrawDots', window, [xCenter, yCenter], 40, [1 0 0], [], 2);
            tSwitch = Screen('Flip', window);
            while GetSecs - tSwitch < switchCueDur,  end
            
            tSwitch = Screen('Flip', window);
            while GetSecs - tSwitch < switchCueDur,  end
        end
    end
    
    % Iterate for block within a block sets
    for b = 1:nBlock 
        % show task instruction
        Screen('DrawTexture', window,  stimTexture(blocks(b)));
        tCue = Screen('Flip', window);
        
        % check the key
        while GetSecs -tCue < blockDur-2,
            % empty the key buffer
            while KbCheck, end
            keyIsDown = KbCheck;
            if keyIsDown 
                sca; return;
            end
        end
        
        % static cue for task switching
        if strcmp(cueType,'static')
            while GetSecs - tCue < blockDur,
                Screen('DrawDots', window, [xCenter, yCenter], 40, [1 0 0], [], 2);
                Screen('Flip', window);
            end
            
        % dynamic cue for task switching
        else
            while GetSecs - tCue < blockDur,
                Screen('DrawDots', window, [xCenter, yCenter], 40, [1 0 0], [], 2);
                tSwitch = Screen('Flip', window);
                while GetSecs - tSwitch < switchCueDur,  end
                
                tSwitch = Screen('Flip', window);
                while GetSecs - tSwitch < switchCueDur,  end
            end
            
        end
    end
end

% Ending baseline
Screen('DrawDots', window, [xCenter, yCenter], 40, [0 0 0], [], 2);
tEnd = Screen('Flip', window);
while GetSecs - tEnd < blockDur,  end

% Disp ending instruction
endDur = 5;
Screen('DrawTexture', window, stimTexture(end));
tEnd = Screen('Flip', window);
while GetSecs - tEnd < endDur,  end
sca;

%% Save data
outFile = fullfile('data',sprintf('%s-run%d-%s.mat',subjectID,runID,date));
fprintf('Results were saved to: %s\n',outFile);
save(outFile);


