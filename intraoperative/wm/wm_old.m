function [resp, outFile] = wm(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
% [resp,outFile] = stroop(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
if nargin < 7, SOA = 1;end
if nargin < 6, stimDur = 0.5; end
if nargin < 5, nTrial = 10; end

%% Print info
fprintf('Runing stroop test\n')
fprintf('patient ID: %s\n',patientID)
fprintf('site ID: %s\n',siteID)
fprintf('task: %s\n',task)
fprintf('stimulus type: %s\n',strjoin(stimType,'-'));
fprintf('stimulus duration: %.2f\n',stimDur)
fprintf('SOA: %.2f\n',SOA)
fprintf('Trial number: %.2f\n',nTrial)

stimType = lower(stimType);
nStimType = length(stimType);

if strcmp(task, 'Oneback')
    back = 1;
elseif strcmp(task,'Twoback')
    back = 2;
else
    error('Wrong task name');
end
%% Get filename of all stimulus
stimImg = [];
stimLabel = [];
for i = 1:nStimType
    parDir = fullfile('stimuli',stimType{i});
    thisTypeImg = strcat(parDir,'\', extractfield(dir(fullfile(parDir,'*.jpg')),'name'))';
    stimImg = [stimImg;thisTypeImg];
    stimLabel = [stimLabel; i*ones(length(thisTypeImg),1)];
end

%% Generate response matrix for all trials
% respone matrix, totalTrial x 5 array. 
% first column,  cond index,
% second column, stim index,
% third column, true answer,
% fourth column, reponse answer
% fifth colunm,  reaction time
totalTrial = nTrial*2;
resp = nan(totalTrial,5,nStimType);
for s = 1:nStimType
    % Condition vector, 1-match,2-not match
    match = randsample(3:totalTrial,nTrial);
    resp(match,1,s) = 1;
    nonmatch = isnan(resp(:,1,s));
    resp(nonmatch,1,s) = 2;
    
    % Stim vector
    stim = randsample(find(stimLabel==s),totalTrial);
    for i = sort(match)
         stim(i) = stim(i-back);
    end
    resp(:,2,s) = stim;
    
    % Answer vector,1-match,2-not match
    resp(:,3,s) = resp(:,1,s);
end

% make jitter
a = -0.5; b = 0.5;
jitter = a + (b-a).*rand(totalTrial,1);

 
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
onebackInstruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','oneback.jpg')));
twobackInstruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','twoback.jpg')));
restInstruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','rest.jpg')));
endInstruction = Screen('MakeTexture', window, imread(fullfile('stimuli','instruction','end.jpg')));
if strcmp(task,'Oneback')
    instruction = onebackInstruction;
else
    instruction = twobackInstruction;
end

%% Make texture for stimulus
stimID = unique(resp(:,2,:));
stimTexture = [];
for i = 1:length(stimID)
    stimTexture(:,:,:,i) = Screen('MakeTexture', window, imread(stimImg{stimID(i)}));
end

%% show instruction and fixation
% instruction
Screen('DrawTexture', window, instruction);
Screen('Flip', window);
KbStrokeWait;

% % begin 
% Screen('DrawTexture', window, beginInstruction);
% Screen('Flip', window);
% WaitSecs(stimDur);
% 
% % fixation
% Screen('DrawTexture', window, fixation);
% Screen('Flip', window);
% WaitSecs(stimDur);

%%  Keyboard
% Define the keyboard keys that are listened for. 
escapeKey = KbName('ESCAPE'); % stop and exit
leftKey = KbName('LeftArrow'); %1-match
rightKey = KbName('RightArrow'); % 2-not match

%% show the stimui and wait respons
stimOrder = randperm(nStimType);
for s = stimOrder
    fprintf('Run %s task for %s\n',task, stimType{s});
    thisResp = resp(:,:,s);
    % map stimID  to textureID
    textureID = thisResp(:,2);
    for i = 1:length(stimID)
        textureID(textureID==stimID(i)) = i;
    end
    
    for t = 1:totalTrial
        % show stimulus
        Screen('DrawTexture', window,  stimTexture(:,:,:,textureID(t)));
        tStart = Screen('Flip', window);
        stimOn = true;
        
        % empty the key buffer
        while KbCheck, end
        
        % wait response
        while GetSecs - tStart < SOA + jitter(t)
            if GetSecs -tStart > stimDur && stimOn
                Screen('DrawDots', window, [xCenter, yCenter], 40, [1 0 0], [], 2);
                Screen('Flip', window);
                stimOn = false;
            end
            
            response = false;
            if ~response
                [keyIsDown, tEnd, keyCode] = KbCheck;
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
                    thisResp(t, 4) = response;
                    thisResp(t, 5) = (tEnd - tStart)*1000;
                end
            end
        end
    end
    resp(:,:,s)= thisResp;

    if s ~= stimOrder(end)
        Screen('DrawTexture', window, restInstruction);
        Screen('Flip', window);
        KbStrokeWait;
    end
end

% back to original order
[~,I] = sort(stimOrder);
resp = resp(:,:,I);

%% Disp ending instruction
Screen('DrawTexture', window, endInstruction);
Screen('Flip', window);
WaitSecs(stimDur);
sca;


%% Save data
outFile = fullfile('data',sprintf('%s_%s_%s_%s_sd%.2f_soa%.2f_nt%d.mat',...
    patientID,siteID,task,strjoin(stimType,'-'),stimDur,SOA,totalTrial));
fprintf('Results were saved to: %s\n',outFile);
save(outFile,'resp','patientID','siteID','task','stimType',...
    'stimDur','SOA','nTrial');


