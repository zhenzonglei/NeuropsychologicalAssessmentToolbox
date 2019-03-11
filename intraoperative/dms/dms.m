function [resp, outFile] = dms(patientID,siteID,task,stimType,nTrial,stimDur,delayTime)
% [resp,outFile] = dms(patientID,siteID,task,stimType,nTrial,stimDur,delayTime)
if nargin < 7, delayTime = 1;end
if nargin < 6, stimDur = 0.5; end
if nargin < 5, nTrial = 10; end

%% Print test information
fprintf('Runing working memory test\n')
fprintf('patient ID: %s\n',patientID)
fprintf('site ID: %s\n',siteID)
fprintf('task: %s\n',task)
fprintf('stimulus type: %s\n',stimType);
fprintf('stimulus duration: %.2f\n',stimDur)
fprintf('delayTime: %.2f\n',delayTime)
fprintf('Trial number: %.2f\n',nTrial)


%% Get filename of all stimulus
parDir = fullfile('stimuli',stimType);
stimImg  = strcat(parDir,'\', extractfield(dir(fullfile(parDir,'*.jpg')),'name'))';

%% Generate response matrix for all trials
% respone matrix, nTrial x 7 array. 
% first column,  cond index,
% second column, targ stim index(i.e.,true answer)
% third column,  distract stim index
% fourth column, targ location, 1-left, 2-right
% fifth colunm,  distract location, 1-left, 2-right
% sixth column, reponse answer
% sventh colunm,  reaction time
resp = nan(nTrial,5);

% Condition vector, only one condtion 1-dms
resp(:,1) = 1;

% Stim vector
for i = 1:nTrial
    resp(i,2:3) = randsample(1:length(stimImg),2);
    resp(i,4:5) = randsample([1,2],2);
end

% make jitter
a = -0.5; b = 0.5;
jitter = a + (b-a).*rand(nTrial,1);

%% preprare the screen
% close all screen
sca;
% skip sync tests
Screen('Preference', 'SkipSyncTests', 1);
% Setup PTB with some default values
PsychDefaultSetup(2);
% Set the screen number to the secondary monitor
screenNumber = max(Screen('Screens'));
% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
% black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect]= PsychImaging('OpenWindow', screenNumber, grey);
% Flip to clear
Screen('Flip', window);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

%% Make texture for  instruction
% fixation = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction', 'fixation.jpg')));
instruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','instruction.jpg')));
endInstruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','end.jpg')));



 %% Make texture for stimulus
stimID = unique(resp(:,2:3));
stimTexture = [];
for i = 1:length(stimID)
    img = imread(stimImg{stimID(i)});
    stimTexture(i) = Screen('MakeTexture', window,img);
end

%% show instruction and fixation
% instruction
Screen('DrawTexture', window, instruction);
Screen('Flip', window);
KbStrokeWait;


%  Keyboard
% Define the keyboard keys that are listened for. 
escapeKey = KbName('ESCAPE'); % stop and exit
leftKey = KbName('LeftArrow'); %1-match
rightKey = KbName('RightArrow'); % 2-not match

%% show the stimui and wait respons
fprintf('Run %s task for %s\n',task, stimType);
% Map stimID  to textureID
textureID = resp(:,2:3);
tag = true(size(textureID));
for i = 1:length(stimID)
    idx = textureID==stimID(i);
    textureID(idx & tag) = i;
    tag(idx) = false;
end

cueRect = [0.6*xCenter, yCenter-0.4*xCenter, 1.4*xCenter, yCenter+0.4*xCenter];
probeRect = [0.1*xCenter, yCenter-0.4*xCenter, 0.9*xCenter, yCenter+0.4*xCenter; 
    1.1*xCenter, yCenter-0.4*xCenter, 1.9*xCenter, yCenter+0.4*xCenter];

respTimeWindow = 3;
initFixDur =2;

for t = 1:nTrial
    % show init fixation
    Screen('DrawDots', window, [xCenter, yCenter], 40, [0 0 0], [], 2);
    tInit = Screen('Flip', window);
    while GetSecs - tInit < initFixDur,  end
       
    % show cue(sample) stimulus
    Screen('DrawTexture', window,  stimTexture(textureID(t,1)),[],cueRect');
    tCue = Screen('Flip', window);   
    % cue(sample) duration
    while GetSecs -tCue < stimDur,  end
    
    % show fixation
    Screen('DrawDots', window, [xCenter, yCenter], 40, [0 0 0], [], 2);
    tFix = Screen('Flip', window);
    % delay time
    while GetSecs - tFix < delayTime,  end
    
    % show probe(test) stimulus
    Screen('DrawTextures', window, stimTexture(textureID(t,resp(t,4:5))), [], probeRect')
    tTest = Screen('Flip', window);
    
    % empty the key buffer
    while KbCheck, end
    
    % wait response    
    response = false;
    while GetSecs - tTest < respTimeWindow %+ jitter(t)
        if ~response
            [keyIsDown, tKey, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(escapeKey)
                    sca; return;
                elseif keyCode(leftKey)
                    response = 1;
                elseif keyCode(rightKey)
                    response = 2;
                else
                    response = 3;
                end
                % collect the trial data
                resp(t, 6) = response;
                resp(t, 7) = (tKey - tTest)*1000;
                
                % back to grey screen
                Screen('FillRect', window, grey);
                Screen('Flip', window);
            end
        end
    end
end

%% Disp ending instruction
Screen('DrawTexture', window, endInstruction);
Screen('Flip', window);
WaitSecs(stimDur);
sca;

%% Save data
outFile = fullfile('data',sprintf('%s_%s_%s_%s_sd%.2f_delay%.2f_nt%d.mat',...
    patientID,siteID,task,stimType,stimDur,delayTime,nTrial));
fprintf('Results were saved to: %s\n',outFile);
save(outFile,'resp','patientID','siteID','task','stimType',...
    'stimDur','delayTime','nTrial');


