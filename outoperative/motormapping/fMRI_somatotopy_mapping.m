function fMRI_somatotopy_mapping(subjectID,runID,blockDur,cueType)
% fMRI_somatotopy_mapping(subjectID,runID,blockDur,cueType)
% Subject presses R key to indicate she/he is ready.
% Then, the experimenter presses S key to begin the experiment.
% cueType: static or dynamic cue to indicate task switching

%% Arguments
if nargin < 4, cueType  = 'dynamic'; end % static or dynamic
if nargin < 3, blockDur = 15;end
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

% % Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

%% Make texture for auxiliary instruction
beginInst = Screen('MakeTexture', window, imread(fullfile('stimuli','begin.JPG')));
restInst = Screen('MakeTexture', window, imread(fullfile('stimuli','rest.JPG')));
endInst = Screen('MakeTexture', window, imread(fullfile('stimuli','end.JPG')));

%% Make texture for motor task
task = {'ankle','toe','leftleg','rightleg','forearm','upperarm',...
    'wrist','finger','eye','jaw','lip','tongue'};
nTask = length(task);
stimTexture = zeros(nTask,1);
for i = 1:nTask
    img = imread(fullfile('stimuli',[task{i},'.JPG']));
    stimTexture(i) = Screen('MakeTexture', window,img);
end


%% Design
% Group ten motor task into two sets
blockSet = [1:2:nTask;2:2:nTask]';
nBlock = size(blockSet,1);

% The order of blocks(set)
order = randperm(2);
setOrder = [order,fliplr(order)];
nSet = length(setOrder);
cueDur = 1;
switchDur = 0.5;

%% Set keys
startKey = KbName('s');
escKey = KbName('ESCAPE');
readyKey = KbName('r');

% RespondKey1 = KbName('2@');
% RespondKey2 = KbName('3#');
% RespondKey = KbName('1!');

%% Check ready for subject
Screen('DrawTexture', window, beginInst);
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
    Screen('DrawTexture', window, restInst);
    tBegin = Screen('Flip', window);    
    
    while GetSecs - tBegin < blockDur - cueDur,
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
            while GetSecs - tSwitch < switchDur,  end
            
            tSwitch = Screen('Flip', window);
            while GetSecs - tSwitch < switchDur,  end
        end
    end
    
    % Iterate for block within a block sets
    for b = 1:nBlock
        % show task instruction
        Screen('DrawTexture', window,  stimTexture(blocks(b)));
        tCue = Screen('Flip', window);
        
        % check the key
        while GetSecs -tCue < blockDur - cueDur,
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
                while GetSecs - tSwitch < switchDur,  end
                
                tSwitch = Screen('Flip', window);
                while GetSecs - tSwitch < switchDur,  end
            end
            
        end
    end
end

% Ending baseline
Screen('DrawTexture', window, restInst);
tEnd = Screen('Flip', window);
while GetSecs - tEnd < blockDur,  end

% Disp ending instruction
endDur = 5;
Screen('DrawTexture', window, endInst);
tEnd = Screen('Flip', window);
while GetSecs - tEnd < endDur,  end
sca;

%% Save data
outFile = fullfile('data',sprintf('%s-run%d-%s.mat',subjectID,runID,date));
fprintf('Results were saved to: %s\n',outFile);
save(outFile);


