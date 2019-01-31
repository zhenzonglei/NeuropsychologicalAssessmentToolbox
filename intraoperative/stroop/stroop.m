function [resp,outFile] = stroop(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
% [resp,outFile] = stroop(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
if nargin < 7, SOA = 2;end
if nargin < 6, stimDur = 0.6; end
if nargin < 5, nTrial = 20; end


%% Print test information
fprintf('Runing stroop test')
fprintf('Runing stroop test\n')
fprintf('patient ID: %s\n',patientID)
fprintf('site ID: %s\n',siteID)
fprintf('task: %s\n',task)
fprintf('stimulus type: %s\n',stimType);
fprintf('stimulus duration: %.2f\n',stimDur)
fprintf('SOA: %.2f\n',SOA)
fprintf('Trial number: %.2f\n',nTrial)

%% Get filename of all stimulus
parDir = fullfile('stimuli',stimType);
stimImg  = strcat(parDir,'\', extractfield(dir(fullfile(parDir,'*.jpg')),'name'))';

%% Generate response matrix for all trials
% respone matrix, totalTrial x 5 array. 
% first column,  cond index,
% second column, stim index,
% third column, true answer,
% fourth column, reponse answer
% fifth colunm,  reaction time
totalTrial = nTrial*2;
resp = nan(totalTrial,5);

% Create condition vector
resp(:,1) = [ones(nTrial,1);2*ones(nTrial,1)];

% Extract stim info from file name
word = []; color = [];
for s = 1:length(stimImg)
    [~,stimImgName,~]= fileparts(stimImg{s});
    str = strsplit(stimImgName,'-');
    word = [word;str(1)];
    color = [color;str(2)];
end

% Create stimuli index vector 
index = cellfun(@strcmp, word,color);
congruent = randsample(find(index),nTrial,true);
incongruent = randsample(find(~index),nTrial,true);
resp(:,2) = [congruent;incongruent];

% Create true answer vector,red-1, green-2,blue-3
label = {'red','green','blue'};
if strcmp(task,'Letter recognition')
    task_stim = word;
else
    task_stim = color;
end
for i = 1:length(label)
    idx = strcmp(task_stim(resp(:,2)),label{i});
    resp(idx,3) = i;
end

% Randomly shuffle stimulus
resp = Shuffle(resp,2);

% make jitter 
a = -0.5; b = 1.5;
jitter = a + (b-a).*rand(totalTrial,1);

%%  Keyboard
% Define the keyboard keys that are listened for. 
escapeKey = KbName('ESCAPE'); % stop and exit
leftKey = KbName('LeftArrow'); %1-red
rightKey = KbName('RightArrow'); % 2-green
downKey = KbName('DownArrow'); % 3-blue

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

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);

% Flip to clear
Screen('Flip', window);

%% Make texture for  instruction
fixation = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction', 'fixation.jpg')));
beginInstruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','begin.jpg')));
colorInstruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','color.jpg')));
wordInstruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','word.jpg')));
endInstruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','end.jpg')));
if strcmp(task,'Letter recognition')
    instruction = wordInstruction;
else
    instruction = colorInstruction;
end

%% Make texture for stimulus
stimID = unique(resp(:,2));
stimTexture = [];
for i = 1:length(stimID)
    stimTexture(i) = Screen('MakeTexture', window, imread(stimImg{stimID(i)}));
end

% Map stimID to textureID
textureID = resp(:,2);
tag = true(size(textureID));
for i = 1:length(stimID)
    idx = textureID==stimID(i);
    textureID(idx & tag) = i;
    tag(idx) = false;
end


%% show instruction and fixation
% instruction
Screen('DrawTexture', window, instruction);
Screen('Flip', window);
KbStrokeWait;

% begin 
Screen('DrawTexture', window, beginInstruction);
Screen('Flip', window);
WaitSecs(stimDur);

% % fixation
% Screen('DrawTexture', window, fixation);
% Screen('Flip', window);
% WaitSecs(stimDur);

%% show the stimui and wait respons
for t = 1:totalTrial
    % show stimulus
    Screen('DrawTexture', window,  stimTexture(textureID(t)));
    tStart = Screen('Flip', window);
    stimOn = true;
    
    % empty the key buffer
    while KbCheck, end
    
    % wait response     
    response = 0; 
    while GetSecs - tStart < SOA + jitter(t)
        if GetSecs -tStart > stimDur && stimOn
            Screen('DrawDots', window, [xCenter, yCenter], 30, [0 0 0], [], 2);
            % Screen('DrawTexture', window, fixation);
            Screen('Flip', window);
            stimOn = false;
        end
        
        if ~response
            [keyIsDown, tEnd, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(escapeKey)
                    sca; return;
                elseif keyCode(leftKey)
                    response = 1;
                elseif keyCode(downKey)
                    response = 2;
                elseif keyCode(rightKey)
                    response = 3;
                else
                    response = 4;
                end
                % collect the trial data
                resp(t, 4) = response;
                resp(t, 5) = (tEnd - tStart)*1000;
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
outFile = fullfile('data',sprintf('%s_%s_%s_%s_sd%.2f_soa%.2f_nt%d.mat',...
    patientID,siteID,task,stimType,stimDur,SOA,totalTrial));
fprintf('Results were saved to: %s\n',outFile);
save(outFile,'resp','patientID','siteID','task','stimType',...
    'stimDur','SOA','nTrial');


