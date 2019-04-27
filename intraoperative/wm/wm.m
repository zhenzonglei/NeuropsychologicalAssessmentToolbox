function [test, outFile] = wm(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
% [test, outFile] = wm(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
if nargin < 7, SOA = 2;end
if nargin < 6, stimDur = 1; end
if nargin < 5, nTrial = 10; end

% close all; 
% clear
% patientID = 'PP';
% siteID = 'A1-2';
% task = 'oneback';
% stimType = 'adult';
% nTrial = 12;
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


%% Get filename of all stimulus
parDir = fullfile('stimuli');
filename = fullfile(parDir,'verbal.txt');
fileID = fopen(filename);
stim = textscan(fileID,'%s');
stim = stim{1}; 
fclose(fileID);
n_stim = length(stim); 

%% Config for all trials
rng('shuffle');
same_prop = 0.5; % prop of the same trials
condID = randsample([1,2], nTrial,true,[same_prop,1-same_prop]);% same,1, different, 2
condID(1) = 2; % the first trial must be different.


% Stim vector
stimID = randsample(n_stim,nTrial,false);
same = find(condID == 1);
stimID(same) = stimID(same-1);


% Jitter 
jitter = normrnd(0,0.3,nTrial,1);

%% setting test matrix: a nTrial x 5 array. 
% first column, cond id,
% second column, stim id,
% third column, true answer,
% fourth column, reponse answer
% fifth colunm,  reaction time
test = nan(nTrial,5);
test(:,1) = condID;
test(:,2) = stimID;
test(:,3) = condID;


%% preprare the screen
sca;% close all screen
PsychDefaultSetup(2);% Setup PTB to 'featureLevel' of 2
Screen('Preference','TextEncodingLocale','UTF-8');
Screen('Preference', 'SkipSyncTests', 1);% skip sync tests

% Set the screen number to the secondary monitor 
screenNumber = max(Screen('Screens'));
% Define black, white and grey
white = WhiteIndex(screenNumber);

% Open the screen
[windowPtr, windowRect]= PsychImaging('OpenWindow', screenNumber, white/2);
Screen('Flip', windowPtr);% Flip to clear

% Get the centre coordinate of the windowPtr in pixels
[xCenter, yCenter] = RectCenter(windowRect);

%% Screen font and text setting
Screen('TextFont', windowPtr,'-:lang=zh-cn');
Screen('TextSize', windowPtr, 50);

%%  Keyboard
% Define the keyboard keys that are listened for. 
escKey = KbName('escape'); % stop and exit
leftKey = KbName('1'); %1-match
rightKey = KbName('3'); % 2s-not match
startKey = KbName('s'); % start key to run the test


%% Present the begining instruction
if strcmp(task,'oneback')
    beginInstruction = fileread(fullfile(parDir, 'oneback.txt'));
else
    beginInstruction = fileread(fullfile(parDir, 'twoback.txt'));
end
beginInstruction = double(native2unicode(beginInstruction));
DrawFormattedText(windowPtr, beginInstruction,'center', 'center', [0 0 1],10);
Screen('Flip', windowPtr);

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
DrawFormattedText(windowPtr, readyInstruction,'center', 'center', [0 0 1],10);
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
Screen('TextSize', windowPtr, 150);
txtCenter = yCenter+50;
for t = 1:nTrial
    % Show stimulus
    stimTxt = double(native2unicode(stim{stimID(t)}));
    DrawFormattedText(windowPtr, stimTxt,'center',txtCenter,[0 0 1],10);
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
            test(t, 4) = response; % key
            test(t, 5) = (tEnd - tStart)*1000; % reaction time
            break;
        end
    end
    
    % Show fixation
    Screen('DrawDots', windowPtr, [xCenter, yCenter],...
        40, [1 1 1], [], 3);
    Screen('Flip', windowPtr);
    
    % Trial jitter
    while GetSecs - tStart < SOA + jitter(t), end
end
%% Disp ending instruction
Screen('DrawDots', windowPtr, [xCenter, yCenter], 40, [1 1 1], [], 3);
WaitSecs(1);

endInstruction = double(native2unicode('测试结束'));
DrawFormattedText(windowPtr,endInstruction,'center', txtCenter, [0 0 1],10);
Screen('Flip', windowPtr);
WaitSecs(1);
sca;

%% Save data
date =  strrep(strrep(datestr(clock),':','-'),' ','-');
outFile = fullfile('data',sprintf('%s_%s_%s_%s_sd%.2f_soa%.2f_nt%d_%s.mat',...
    patientID,siteID,task,stimType,stimDur,SOA,nTrial,date));
fprintf('Results were saved to: %s\n',outFile);
save(outFile,'test','patientID','siteID','task','stimType',...
    'stimDur','SOA','nTrial');


