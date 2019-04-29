function [test, outFile] = wm(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
% [test, outFile] = wm(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
if nargin < 7, SOA = 2;end
if nargin < 6, stimDur = 1; end
if nargin < 5, nTrial = 10; end
if SOA <= stimDur
    error('SOA should be larger than stimDur.');
end

%% setting for test
% close all; 
% clear
% patientID = 'PP';
% siteID = 'A1-2-1';
% task = 'Oneback';
% stimType = 'Word';
% nTrial = 4;
% stimDur = 1;
% SOA = 2;


%% Print test information
fprintf('Runing %s task for %s\n',task, stimType);
fprintf('patient ID: %s\n',patientID)
fprintf('site ID: %s\n',siteID)
fprintf('task: %s\n',task)
fprintf('stimulus type: %s\n',stimType);
fprintf('stimulus duration: %.2f\n',stimDur)
fprintf('SOA: %.2f\n',SOA)
fprintf('Trial number: %.2f\n',nTrial)


%% preprare the screen
sca;% close all screen
PsychDefaultSetup(2);% Setup PTB to 'featureLevel' of 2
Screen('Preference','TextEncodingLocale','UTF-8');
Screen('Preference', 'SkipSyncTests', 1);% skip sync tests

% Set the screen number to the secondary monitor
screenNumber = max(Screen('Screens'));
% Define black, white and grey
screenColor = BlackIndex(screenNumber);

% Open the screen
[windowPtr, windowRect]= PsychImaging('OpenWindow', screenNumber, screenColor);
Screen('Flip', windowPtr);% Flip to clear
xWidth = windowRect(3); yWidth = windowRect(4);

% Get the centre coordinate of the windowPtr in pixels
[xCenter, yCenter] = RectCenter(windowRect);


%%  Call subfunction to make stimulus
[stim,mask] = makeStimulus(windowPtr, stimType);
n_stim = length(stim);

%% Make design
if strcmp(task, 'Oneback')
    nTrial = nTrial + 1; % plus 1 trial because the first trial doesn't count.
else 
    nTrial = nTrial + 2; % plus 2 trial because the first two trial doesn't count.
end
same_prop = 0.4; % prop of the same trials


rng('shuffle');
condID = randsample([1,2], nTrial,true,[same_prop,1-same_prop]);% same,1, different, 2

% Stim vector
stimID = randsample(n_stim,nTrial,false);
if strcmp(task, 'Oneback')  
    condID(1) = 2; % the first trial must be different.
    same = find(condID == 1);
    stimID(same) = stimID(same-1);
else
    condID(1:2) = 2; % the first two trial must be different.
    same = find(condID == 1);
    stimID(same) = stimID(same-2);
end

% Jitter
jitter = normrnd(0,0.3,nTrial,1);

%% setting test matrix: a nTrial x 5 array.
% first column, cond id; second column, stim id,
% third column, true answer; fourth column, reponse answer
% fifth colunm,  reaction time
test = nan(nTrial,5);
test(:,1) = condID;test(:,2) = stimID;test(:,3) = condID;

%% Screen font and text setting
insSize = 75; insColor = [213, 94, 0]/255;
textSize = 200;textColor = [86, 180, 233]/255;
maskColor = [0.5 0.5 0.5];
Screen('TextFont', windowPtr,'-:lang=zh-cn');

%%  Keyboard
% Define the keyboard keys that are listened for.
escKey = KbName('escape'); % stop and exit
leftKey = KbName('1'); %1-match
rightKey = KbName('3'); % 2s-not match
startKey = KbName('s'); % start key to run the test

%% Show instruction and wait subject to be ready
if strcmp(task,'Oneback')
    beginInstruction = fileread(fullfile('stimuli', 'Oneback.txt'));
else
    beginInstruction = fileread(fullfile('stimuli', 'Twoback.txt'));
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
readyInstruction = double(native2unicode('测试马上开始'));
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

%% Show the stimui and wait respons
if any(strcmp({'Word','Number'},stimType)) % when stimuli are text
    Screen('TextSize', windowPtr, textSize);
    txtCenter = yCenter+50;
    for t = 1:nTrial
        % Show stimulus
        stimTxt = double(native2unicode(stim{stimID(t)}));
        [~,~,textBound] = DrawFormattedText(windowPtr, stimTxt,'center',txtCenter,textColor);
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
                test(t, 5) = (tEnd - tStart)*1000; % reaction time
                break;
            end
        end
        
        % Show mask rect
        Screen('FillRect', windowPtr, maskColor, textBound);
        Screen('Flip', windowPtr);
        
        % Trial jitter
        while GetSecs - tStart < SOA + jitter(t), end
    end
    
elseif any(strcmp({'Face','FaceGen','Flower'},stimType)) % when stimuli are image
    [iw,ih] = size(mask); height = 3/4*yWidth;
    scale = height/ih; width = iw*scale;
    destRect = [xCenter-0.5*width, yCenter-0.5*height, ...
        xCenter+0.5*width, yCenter+0.5*height];
    
    for t = 1:nTrial
        Screen('DrawTexture', windowPtr, stim(stimID(t)),[],destRect);
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
                test(t, 5) = (tEnd - tStart)*1000; % reaction time
                break;
            end
        end
        
        % Show mask
        Screen('DrawTexture', windowPtr, mask,[], destRect);
        Screen('Flip', windowPtr);
        
        % Trial jitter
        while GetSecs - tStart < SOA + jitter(t), end
    end
end
%% delete invalid trials
if strcmp(task, 'Oneback')
    test = test(2:end,:); % delete first trial for oneback.
else
    test = test(3:end,:); % delete first two trial for twoback
end
nTrial = size(test,1);

%% Disp ending instruction
WaitSecs(1);
Screen('TextSize', windowPtr, insSize);
endInstruction = double(native2unicode('测试结束'));
DrawFormattedText(windowPtr,endInstruction,'center', 'center',insColor);
Screen('Flip', windowPtr);
WaitSecs(1);
sca;

%% Save data
date = strrep(strrep(datestr(clock),':','-'),' ','-');
outFile = fullfile('data',sprintf('%s_%s_%s_%s_sd%.2f_soa%.2f_nt%d_%s.mat',...
    patientID,siteID,task,stimType,stimDur,SOA,nTrial,date));
fprintf('Results were saved to: %s\n',outFile);
save(outFile,'test','patientID','siteID','task','stimType',...
    'stimDur','SOA','nTrial');


function [stim,mask] = makeStimulus(windowPtr, stimType)
% Subfunction to make stimulus
if nargin < 2, stimType = 'Word';end
switch stimType
    case {'Word','Number'}
        filename = fullfile('stimuli',stimType,[stimType,'.txt']);
        fileID = fopen(filename);
        stim = textscan(fileID,'%s');
        stim = stim{1};
        fclose(fileID);
        mask = 0; 
        
    case {'Face','FaceGen','Flower'}
        imgformat = {'jpg','bmp','png','tif'};
        for i = 1:length(imgformat)
            filename = dir(fullfile('stimuli',stimType,['*.',imgformat{i}]));
            if ~isempty(filename), break; end
        end
        
        stim = zeros(length(filename),1);
        for f = 1:length(filename)
            img = imread(fullfile(filename(f).folder,filename(f).name));
            stim(f) = Screen('MakeTexture', windowPtr, img);
        end
        
        mask = ones(size(img))*255*0.9;
        mask = Screen('MakeTexture', windowPtr, mask);
    otherwise
        error('Wrong type of stimulus.')
end





