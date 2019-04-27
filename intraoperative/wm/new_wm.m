% function [test, outFile] = new_wm(patientID)
% [test, outFile] = new_wm(patientID,siteID,task,stimType,nTrial,stimDur,SOA)
% if nargin < 7, SOA = 1;end
% if nargin < 6, stimDur = 0.5; end
% if nargin < 5, nTrial = 10; end

patientID = 'PP';
siteID = 'A1-2';
task = 'oneback';
stimType=  'adult';
nTrial = 10;
stimDur =1;
SOA =2;

%% Print test information
fprintf('Runing %s task for %s\n',task, stimType);
fprintf('patient ID: %s\n',patientID)
fprintf('site ID: %s\n',siteID)
fprintf('task: %s\n',task)
fprintf('stimulus type: %s\n',stimType);
fprintf('stimulus duration: %.2f\n',stimDur)
fprintf('SOA: %.2f\n',SOA)
fprintf('Trial number: %.2f\n',nTrial)

if strcmp(task, 'oneback')
    back = 1;
elseif strcmp(task,'twoback')
    back = 2;
else
    error('Wrong task name');
end
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


% make jitter
jitter = normrnd(0,0.3,nTrial,1);
jitter = SOA + jitter;

% setting test matrix: a nTrial x 5 array. 
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

% Open the screen
[window, windowRect]= PsychImaging('OpenWindow', screenNumber, white/2);
yWidth = windowRect(4);

% Get the centre coordinate of the window in pixels
[xCenter, yCenter] = RectCenter(windowRect);
destRect = [xCenter-0.5*yWidth, 0, xCenter + 0.5*yWidth, yWidth];

% Flip to clear
Screen('Flip', window);

%% Make texture for  instruction
Screen('DrawText', window, '¹¤×÷¼ÇÒä²âÊÔ', 0, 0, [255, 0, 0, 255]);
if strcmp(task,'oneback')
    instruction = 'oneback';
else
    instruction = 'twoback';
end


%% show instruction and fixation
Screen('DrawText', window, instruction, 0, 0, [255, 0, 0, 255]);
Screen('Flip', window);
KbStrokeWait();

%%  Keyboard
% Define the keyboard keys that are listened for. 
KbName('UnifyKeyNames'); 
escapeKey = KbName('ESCAPE'); % stop and exit
leftKey = KbName('1'); %1-match
rightKey = KbName('3'); % 2-not match
 feature('DefaultCharacterSet', 'UTF8');
%% show the stimui and wait respons
for t = 1:nTrial
    % show stimulus
    stimStr = native2unicode(stim{stimID(t)});
    Screen('DrawText', window, stimStr, xCenter, yCenter, [255, 0, 0, 255]);
    tStart = Screen('Flip', window);
    stimOn = true;
    
    % empty the key buffer
    while KbCheck(), end
    
    % wait test    
    test = 0;
    while GetSecs - tStart < jitter(t)
        if GetSecs -tStart > stimDur && stimOn
            Screen('DrawDots', window, [xCenter, yCenter], 40, [1 1 1], [], 3);
            Screen('Flip', window);
            stimOn = false;
        end
        
        if ~test
            [keyIsDown, tEnd, keyCode] = KbCheck;
            if keyIsDown 
                if keyCode(escapeKey)
                    sca; return;
                elseif keyCode(leftKey)
                    test = 1;
                elseif keyCode(rightKey)
                    test = 2;
                else
                    test = 3;
                end
                % collect test data
                test(t, 4) = test;
                test(t, 5) = (tEnd - tStart)*1000;
            end
        end
    end
end

%% Disp ending instruction
Screen('DrawDots', window, [xCenter, yCenter], 40, [1 1 1], [], 3);
Screen('Flip', window);
WaitSecs(1);
sca;

% %% Save data
% date =  strrep(strrep(datestr(clock),':','-'),' ','-');
% outFile = fullfile('data',sprintf('%s_%s_%s_%s_sd%.2f_soa%.2f_nt%d_%s.mat',...
%     patientID,siteID,task,stimType,stimDur,SOA,nTrial,date));
% fprintf('Results were saved to: %s\n',outFile);
% save(outFile,'test','patientID','siteID','task','stimType',...
%     'stimDur','SOA','nTrial');


