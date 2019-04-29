function [test,outFile] = stroop(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
% [test,outFile] = stroop(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
if nargin < 7, SOA = 2;end
if nargin < 6, stimDur = 1; end
if nargin < 5, nTrial = 10; end

% %% setting for test
% close all; 
% clear
% patientID = 'PP';
% siteID = 'A1-2-1';
% task = 'Color discrimination';
% stimType = 'Word';
% nTrial = 10;
% stimDur = 1;
% SOA = 2;

%% Print test information
fprintf('Runing stroop test\n')
fprintf('Patient ID: %s\n',patientID)
fprintf('Site ID: %s\n',siteID)
fprintf('Task: %s\n',task);
fprintf('Stimulus type: %s\n',stimType);
fprintf('Stimulus duration: %.2f\n',stimDur);
fprintf('SOA: %.2f\n',SOA);
fprintf('Trial number: %.2f\n',nTrial);

%% preprare the screen
sca;% close all screen
PsychDefaultSetup(2);% Setup PTB to 'featureLevel' of 2
Screen('Preference','TextEncodingLocale','UTF-8');
Screen('Preference', 'SkipSyncTests', 1);% Skip sync tests
screenNumber = max(Screen('Screens'));% Set the screen to the secondary monitor
screenColor = WhiteIndex(screenNumber);% Define background color
[windowPtr, windowRect]= PsychImaging('OpenWindow', screenNumber, screenColor);% Open the screen
Screen('Flip', windowPtr);% Flip to clear
[xCenter, yCenter] = RectCenter(windowRect);% Get the centre coordinate of the windowPtr in pixels

%% Making stimulus
word = {'��','��','��'};
color = [1 0 0; 0 1 0];
nw = length(word); nc = size(color,1);
n_stim = nw*nc; stim = zeros(n_stim,2);
i = 1;
for w = 1:nw
    for c = 1:nc
        stim(i,:) = [w,c];
        i = i + 1;
    end
end
% stim id for each condtion
stim_cond = [1,4;2,3;5,6];
cond = zeros(n_stim,1);% condition id for each stim: congruent,1; incongruent, 2; neutral,3;
for i = 1:3
    cond(stim_cond(i,:)) = i;
end
stim_answer = stim(:,2);

%% Generate test matrix,totalTrial x 5 array. 
% Stimulus id for each trial
stimID  = zeros(nTrial,3);
for i = 1:3
    stimID(:,i) = randsample(stim_cond(i,:),nTrial,true);
end
stimID = reshape(stimID,[],1);

% Cond id for each trial
condID = cond(stimID);

% Answer for each trial
answer = stim_answer(stimID);

% Make jitter
totalTrial = length(stimID);
jitter = normrnd(0,0.3,totalTrial,1);

%% setting test matrix: 
% First column, cond index, second column, stim index,
% Third column, true answer, fourth column, reponse answer
% Fifth colunm, reaction time
test = nan(totalTrial,5);
test(:,1) = condID;
test(:,2) = stimID;
test(:,3) = answer;

% Randomly shuffle stimulus
rng('shuffle');
idx = randperm(totalTrial);
test = test(idx,:);

%% Screen font and text setting
insSize = 75; insColor = [213, 94, 0]/255;
textSize = 200;maskColor = [0.5 0.5 0.5];
Screen('TextFont', windowPtr,'-:lang=zh-cn');

%% Keyboard
% Define the keyboard keys that are listened for.
escKey   = KbName('escape'); % stop and exit
leftKey  = KbName('1'); %1-match
rightKey = KbName('3'); % 2s-not match
startKey = KbName('s'); % start key to run the test

%% Show instruction and wait subject to be ready
if strcmp(task,'Letter discrimination')
    beginInstruction = fileread(fullfile('stimuli', 'Letterdiscrimination.txt'));
elseif strcmp(task,'Color discrimination')
    beginInstruction = fileread(fullfile('stimuli', 'Colordiscrimination.txt'));
end

beginInstruction = double(native2unicode(beginInstruction));
Screen('TextSize', windowPtr, insSize);
DrawFormattedText(windowPtr, beginInstruction,'center', 'center', insColor);
Screen('Flip', windowPtr);

% Wait subject to be ready
while KbCheck(); end
while true
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown && keyCode(leftKey)
        break;
    elseif keyIsDown && keyCode(escKey)
        sca; return
    end
end
readyInstruction = double(native2unicode('�������Ͽ�ʼ'));
DrawFormattedText(windowPtr, readyInstruction,'center', 'center',insColor);
Screen('Flip', windowPtr);

%% Wait trigger to begin the test
while KbCheck(); end
while true
    [keyIsDown,~,keyCode] = KbCheck();
    if keyIsDown && keyCode(startKey)
        break
    elseif keyIsDown && keyCode(escKey)
        disp('ESC is pressed to abort the program.');
        sca; return;
    end
end

%% show the stimui and wait respons
Screen('TextSize', windowPtr, textSize);
txtCenter = yCenter+50;
for t = 1:totalTrial
    % Show stimulus
    wi = stim(test(t,2),1); stimTxt = double(native2unicode(word{wi}));
    ci = stim(test(t,2),2);textColor = color(ci,:);
    [~,~,textBound] = DrawFormattedText(windowPtr, stimTxt,...
        'center','center',textColor);
    tStart = Screen('Flip', windowPtr);
    
    % Wait response
    while KbCheck(), end % empty the key buffer
    while GetSecs - tStart < stimDur
        [keyIsDown, tEnd, keyCode] = KbCheck();
        if keyIsDown
            if keyCode(escKey)
                sca; return;
            elseif keyCode(leftKey)
                response = 1;
            elseif keyCode(rightKey)
                response = 2;
            else
                response = 3;
            end
            
            % Insert response to the test slot
            test(t, 4) = response; % response key
            test(t, 5) = tEnd - tStart; % reaction time
            break;
        end
    end
    
    % Show mask rect
    Screen('FillRect', windowPtr, maskColor, textBound);
    Screen('Flip', windowPtr);
    
    % Trial jitter
    while GetSecs - tStart < SOA + jitter(t), end
end

%% Disp ending instruction
WaitSecs(1);
Screen('TextSize', windowPtr, insSize);
endInstruction = double(native2unicode('���Խ���'));
DrawFormattedText(windowPtr,endInstruction,'center','center',insColor);
Screen('Flip', windowPtr);
WaitSecs(1);
sca;

%% Save data
date = strrep(strrep(datestr(clock),':','-'),' ','-');
outFile = fullfile('data',sprintf('%s_%s_%s_%s_sd%.2f_soa%.2f_nt%d_%s.mat',...
    patientID,siteID,task,stimType,stimDur,SOA,totalTrial,date));
fprintf('Results were saved to: %s\n',outFile);
save(outFile,'test','patientID','siteID','task','stimType',...
    'stimDur','SOA','nTrial');


