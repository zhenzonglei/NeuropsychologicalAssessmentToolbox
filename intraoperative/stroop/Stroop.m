function [test,outFile] = Stroop(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
% [test,outFile] = Stroop(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
if nargin < 7, SOA = 2;end
if nargin < 6, stimDur = 1; end
if nargin < 5, nTrial = 10; end

%% setting for test
% close all;
% clear
% patientID = 'PP';
% siteID = 'A1-2-1';
% task = 'Arrow discrimination';
% stimType = 'Arrow-Position';
% nTrial = 3;
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
Screen('Preference', 'SkipSyncTests', 1);% Skip synIRF tests
screenNumber = max(Screen('Screens'));% Set the screen to the secondary monitor
screenColor = BlackIndex(screenNumber);% Define background color
[windowPtr, windowRect]= PsychImaging('OpenWindow', screenNumber, screenColor);% Open the screen
Screen('Flip', windowPtr);% Flip to clear
[xCenter, yCenter] = RectCenter(windowRect);% Get the centre coordinate of the windowPtr in pixels

%% Making stimulus
if strcmp(stimType,'Color-Word')
    % Color is relevant feature(RF)£¬and word is irrelevant feature(IRF)
    RF = [1 0 0; 0 1 0];  nRF = size(RF,1);
    IRF = {'ºì','ÂÌ','²Ê'};nIRF = length(IRF);
    % Stim id for each condtion
    stimCond = [1,5;2,4;3,6]; nCond = size(stimCond,1);
    

elseif strcmp(stimType,'Word-Position')
    % Word is relevant feature(RF)£¬and position is irrelevant feature(IRF)
    RF = {'×ó','ÓÒ'};nRF = length(RF);
    IRF = [xCenter-100,xCenter+100]; nIRF = length(IRF);
    % Stim id for each condtion
    stimCond = [1,4;2,3]; nCond = size(stimCond,1);
    
elseif strcmp(stimType,'Arrow-Position')
    % Arrow is relevant feature(RF), and position is irrelevant feature(IRF)
    arrowImg = {'left.jpg','right.jpg'};nRF = length(arrowImg);
    RF = zeros(nRF,1);
    for i = 1:length(arrowImg)
        img = imread(fullfile('stimuli','Arrow',arrowImg{i}));
        RF(i) = Screen('MakeTexture', windowPtr, img);
    end
    
    % cueRect = [0.6*xCenter, yCenter-0.4*xCenter, 1.4*xCenter, yCenter+0.4*xCenter];
    IRF = [0.1*xCenter, yCenter-0.4*xCenter, 0.9*xCenter, yCenter+0.4*xCenter;
        1.1*xCenter, yCenter-0.4*xCenter, 1.9*xCenter, yCenter+0.4*xCenter];
    nIRF = size(IRF,1);

    % Stim id for each condtion
    stimCond = [1,4;2,3]; nCond = size(stimCond,1);
    
    %     mask = ones(size(img))*255*0.9;
    %     mask = Screen('MakeTexture', windowPtr, mask);
end

% Combine RF and IRF to generate stimulus
[Rid,IRid] = meshgrid(1:nRF, 1:nIRF);
stim = [Rid(:),IRid(:)]; % all possible stimuli, each row is a stimulus

% Stim id for each condtion
nStim = nRF*nIRF;
cond = zeros(nStim,1);
for i = 1:size(stimCond,1) % congruent,1; incongruent, 2; neutral,3;
    cond(stimCond(i,:)) = i;
end

% Answers for each stimulus
stimAnswer = stim(:,1);

%% Generate test matrix,totalTrial x 5 array.
% We randomly generate the stimulus sequence many times(randnum) and select
% the sequenIRFe which show least repetition
totalTrial = nTrial * nCond;
randnum = 1000;
rng('shuffle');
trialStimIDbase = zeros(totalTrial,randnum);
repCost = zeros(totalTrial,1);
for r = 1:randnum
    trialStimID  = zeros(nTrial,nCond);
    for i = 1:nCond
        trialStimID(:,i) = randsample(stimCond(i,:),nTrial,true);
    end
    trialStimID = reshape(trialStimID,[],1);
    
    % shuffle the stim
    idx = randperm(totalTrial);
    trialStimID = trialStimID(idx,:);
    trialStimIDbase(:,r) = trialStimID;
    
    % find number of repetitions for each stim
    stimDiff = [true; diff(trialStimID) ~= 0; true]; % TRUE if values change
    diffNum = diff(find(stimDiff)); % Number of repetitions
    stimRep = repelem(diffNum,diffNum); % Number of repetitions for each stim
    repCost(r) = sum(stimRep);
end
[~,minrep] = min(repCost);
trialStimID = trialStimIDbase(:,minrep);

% Cond id for each trial
condID = cond(trialStimID);

% Answer for each trial
answer = stimAnswer(trialStimID);

% Make jitter
totalTrial = length(trialStimID);
jitter = normrnd(0,0.3,totalTrial,1);

%% setting test matrix:
% First column, cond index, second column, stim index,
% Third column, true answer, fourth column, reponse answer
% Fifth colunm, reaction time
test = nan(totalTrial,5);
test(:,1) = condID;
test(:,2) = trialStimID;
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
if strcmp(task,'Word discrimination')
    beginInstruction = fileread(fullfile('stimuli', 'Worddiscrimination.txt'));
elseif strcmp(task,'Color discrimination')
    beginInstruction = fileread(fullfile('stimuli', 'Colordiscrimination.txt'));
elseif strcmp(task,'Arrow discrimination')
    beginInstruction = fileread(fullfile('stimuli', 'Arrowdiscrimination.txt'));
end
beginInstruction = double(native2unicode(beginInstruction));
Screen('TextSize', windowPtr, insSize);
DrawFormattedText(windowPtr, beginInstruction,'center', 'center', insColor);
Screen('Flip', windowPtr);

% Wait subject to be ready
while KbCheck(); end
while true
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown && keyCode(leftKey), break;
    elseif keyIsDown && keyCode(escKey), sca; return
    end
end
readyInstruction = double(native2unicode('²âÊÔÂíÉÏ¿ªÊ¼'));
DrawFormattedText(windowPtr, readyInstruction,'center', 'center',insColor);
Screen('Flip', windowPtr);

%% Wait trigger to begin the test
while KbCheck(); end
while true
    [keyIsDown,~,keyCode] = KbCheck();
    if keyIsDown && keyCode(startKey), break;
    elseif keyIsDown && keyCode(escKey), sca; return;
    end
end

%% show the stimui and wait respons
if strcmp(stimType,'Color-Word')
    Screen('TextSize', windowPtr, textSize);
%     txtCenter = yCenter+50;
    for t = 1:totalTrial
        % Show stimulus
        r = stim(test(t,2),1); textColor = RF(r,:);
        ir = stim(test(t,2),2);stimText = double(native2unicode(IRF{ir}));
        [~,~,textBound] = DrawFormattedText(windowPtr, stimText,...
            'center','center',textColor);
        tStart = Screen('Flip', windowPtr);
        
        % Wait response
        while KbCheck(), end % empty the key buffer
        while GetSecs - tStart < stimDur
            [keyIsDown, tEnd, keyCode] = KbCheck();
            if keyIsDown
                if keyCode(escKey), sca; return;
                elseif keyCode(leftKey), response = 1;
                elseif keyCode(rightKey), response = 2;
                else, response = 3;
                end
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
    
elseif strcmp(stimType,'Word-Position')
    Screen('TextSize', windowPtr, textSize);
    for t = 1:totalTrial
        % Show stimulus
        r = stim(test(t,2),1); stimTxt = double(native2unicode(RF{r}));
        ir = stim(test(t,2),2);textPos = IRF(ir);
        [~,~,textBound] = DrawFormattedText(windowPtr, stimTxt,...
            textPos,'center',insColor);
        tStart = Screen('Flip', windowPtr);
        
        % Wait response
        while KbCheck(), end % empty the key buffer
        while GetSecs - tStart < stimDur
            [keyIsDown, tEnd, keyCode] = KbCheck();
            if keyIsDown
                if keyCode(escKey), sca; return;
                elseif keyCode(leftKey), response = 1;
                elseif keyCode(rightKey), response = 2;
                else, response = 3; 
                end
                test(t, 4) = response; % response key
                test(t, 5) = tEnd - tStart; % reaction time
                break;% break when get response
            end
        end
        
        % Show mask rect
        Screen('FillRect', windowPtr, maskColor, textBound);
        Screen('Flip', windowPtr);
        
        % Trial jitter
        while GetSecs - tStart < SOA + jitter(t), end
    end
    
elseif strcmp(stimType,'Arrow-Position')
    for t = 1:totalTrial
        % Show mask rect
        Screen('FillRect', windowPtr, maskColor, IRF(1,:));
        Screen('FillRect', windowPtr, maskColor, IRF(2,:));
        
        % Show stimulus
        r = stim(test(t,2),1); stimArrow = RF(r);
        ir = stim(test(t,2),2);stimRect = IRF(ir,:);
        Screen('DrawTexture', windowPtr, stimArrow,[],stimRect);
        tStart = Screen('Flip', windowPtr);
        
        % Wait response
        while KbCheck(), end % empty the key buffer
        while GetSecs - tStart < stimDur
            [keyIsDown, tEnd, keyCode] = KbCheck();
            if keyIsDown
                if keyCode(escKey),sca; return;
                elseif keyCode(leftKey), response = 1;
                elseif keyCode(rightKey),response = 2;
                else, response = 3; 
                end
                test(t, 4) = response; % response key
                test(t, 5) = tEnd - tStart; % reaction time
                break;
            end
        end
        
%         % Show mask rect
%         Screen('FillRect', windowPtr, maskColor, IRF(1,:));
%         Screen('FillRect', windowPtr, maskColor, IRF(2,:));
%         Screen('Flip', windowPtr);
        
        % Trial jitter
        while GetSecs - tStart < SOA + jitter(t), end
    end
end


%% Disp ending instruction
WaitSecs(1);
Screen('TextSize', windowPtr, insSize);
endInstruction = double(native2unicode('²âÊÔ½áÊø'));
DrawFormattedText(windowPtr,endInstruction,'center','center',insColor);
Screen('Flip', windowPtr);
WaitSecs(1);
sca;

% %% Save data
% date = strrep(strrep(datestr(clock),':','-'),' ','-');
% outFile = fullfile('data',sprintf('%s_%s_%s_%s_sd%.2f_soa%.2f_nt%d_%s.mat',...
%     patientID,siteID,task,stimType,stimDur,SOA,totalTrial,date));
% fprintf('Results were saved to: %s\n',outFile);
% save(outFile,'test','patientID','siteID','task','stimType',...
%     'stimDur','SOA','nTrial');


