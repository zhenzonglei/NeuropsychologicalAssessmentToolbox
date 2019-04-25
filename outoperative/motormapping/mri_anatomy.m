function mri_anatomy(subjectID,runID,modality,SubjResp)
% mri_anatomy(subjectID,runID,runDur,modality,SubjResp)
% Subject presses 1! or 2@ or 3# or 4$ key indicate she/he is ready.
% Then, the scanner or experimenter presses S key to begin the experiment.
% modality: field, t1, t2, dwi
% Zonglei Zhen @ 2019.03

if nargin < 4, SubjResp = false; end

%% run total time in sec unit 
if strcmp(modality,'field')
    runTotalTime = 2*60 + 27;
elseif  strcmp(modality,'t1')
    runTotalTime = 6*60 + 3;
elseif  strcmp(modality,'t2')
    runTotalTime = 5*60 + 18;
elseif  strcmp(modality,'dwi')
    runTotalTime = 14*60 + 19;
end

%% Print test information
fprintf('Runing %s\n',modality);
fprintf('Subject ID: %s\n',subjectID);
fprintf('Run ID: %d\n',runID);
fprintf('Total duration for one run: %.2f min\n',runTotalTime/60);

%% preprare the screen
sca; % close all screen
Screen('Preference', 'SkipSyncTests', 1);% skip sync tests
HideCursor;

% Setup PTB with some default values
PsychDefaultSetup(2);
% Set the screen number to the secondary monitor
screenNumber = max(Screen('Screens'));
% Define black, white and grey
% white = WhiteIndex(screenNumber);
% grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect]= PsychImaging('OpenWindow', screenNumber, black);
% Flip to clear
Screen('Flip', window);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

%% Make texture for auxiliary instruction
stimDir = fullfile('stimuli','stimuli_with_pace');
beginInst = Screen('MakeTexture', window, imread(fullfile(stimDir,'mri_begin.JPG')));
endInst = Screen('MakeTexture', window, imread(fullfile(stimDir,'mri_end.JPG')));

% cue duration 
cueDur = 2;

%% Set keys
startKey = KbName('s');
escKey = KbName('ESCAPE');
respondKey3 = KbName('3#');
respondKey4 = KbName('4$');

%% present the begining instruction
Screen('DrawTexture', window, beginInst);
Screen('Flip', window);
% Check ready for subject
if SubjResp
    while KbCheck; end
    while true
        [keyIsDown, ~, keyCode] = KbCheck();
        responseKey = keyCode(respondKey3) | keyCode(respondKey4);
        if keyIsDown && responseKey
            break;
        elseif keyIsDown && keyCode(escKey)
            sca;
            return
        end
    end
    Screen('Flip', window);
else
    WaitSecs(5)
end
fprintf('***** The subject is READY. Please RUN MRI *****\n');

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

%% Run anatomy MRI experiment 
Screen('DrawDots', window, [xCenter, yCenter], 40, [1 1 1]*0.5, [], 3);
tBegin = Screen('Flip', window);
while GetSecs - tBegin < runTotalTime,
    [keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown && keyCode(escKey)
        sca; return;
    end
end

% Disp ending instruction
Screen('DrawTexture', window, endInst);
tEnd = Screen('Flip', window);
while GetSecs - tEnd < cueDur,  end
sca;

%% Save data
date =  strrep(strrep(datestr(clock),':','-'),' ','-');
outFile = fullfile('data',sprintf('%s-%s-run%d-%s.mat',subjectID,modality,runID,date));
fprintf('Data were saved to: %s\n',outFile);
save(outFile);



