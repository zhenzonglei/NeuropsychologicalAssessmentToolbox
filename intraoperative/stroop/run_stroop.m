function run_stroop(handles)
% run_stroop(handles)
% handles, gui handles


%% extract variable from handles
% patient ID
patientID = get(handles.PatientID,'String');
% fprintf('patient ID: %s\n',patientID)

% site ID
siteID =   get(handles.SiteID,'String');
% fprintf('site ID: %s\n',siteID)

% task
str = get(handles.Task,'String');
val = get(handles.Task,'Value');
task = str{val};
% fprintf('task: %s\n',task)

% stim type
str = get(handles.stimtype,'String');
val = get(handles.stimtype,'Value');
stimType = str{val};
% fprintf('stimulus type: %s\n',stimType);

% stim duration
stimDur = str2double(get(handles.StimDuration,'String'));
if isnan(stimDur)
    errordlg('You must enter a numeric value for stimulus duration','Bad Input','modal')
end
% fprintf('stimulus duration: %.2f\n',stimDur)

% SOA or ISI: stimulus onset asynchrony
SOA = str2double(get(handles.SOA,'String'));
if isnan(SOA)
    errordlg('You must enter a numeric value for SOA','Bad Input','modal')
end
% fprintf('SOA: %.2f\n',SOA)

% Trial number
nTrial =  str2double(get(handles.TrialNum,'String'));
if isnan(nTrial)
    errordlg('You must enter a numeric value for run duration','Bad Input','modal')
end
% fprintf('Trial number per condition: %.2f\n',nTrial)

%% run stroop task
resp = stroop(patientID,siteID,task,stimType,nTrial,stimDur,SOA);

%% disp response for single trials 
drawnow
nTrial = size(resp,1);
xlim(handles.axes1,[0 nTrial]);
hold(handles.axes1,'on')
xlabel(handles.axes1,'Trial ID');
ylabel(handles.axes1,'Reaction time(ms)');
for t = 1:nTrial
    % disp single trial RT
    if resp(t,3)==resp(t,4)
        plot(handles.axes1, [t,t], [0, resp(t, 5)],'-g','LineWidth',2);
    else
        plot(handles.axes1, [t,t], [0, resp(t, 5)],'-r','LineWidth',2);
    end
end

%% calcaute and disp averge accuracy and RT across trials
[acc,rt] = stroopSummary(resp);
cond_name = {'Congruent','Incongruent'};
% show acc
hold(handles.axes2,'on')
for i = 1:length(acc)
  h = bar(handles.axes2, i,acc(i)*100);
   if i == 1
        set(h,'FaceColor','b');
   else
        set(h,'FaceColor','r');
    end
end
hold(handles.axes2,'off')
% ylabel(handles.axes2,'Accuracy(%s)');
set(handles.axes2,'Xtick',1:length(cond_name), 'XtickLabel',cond_name);

% show rt
bar(handles.axes3,rt);
% ylabel(handles.axes3,'Reaction time(ms)');
set(handles.axes3,'Xtick',1:length(cond_name), 'XtickLabel',cond_name);

% print acc and rt
for i = 1:length(acc)
    fprintf('%s:ACC-%.2f%%,RT-%.2fms\n', cond_name{i},acc(i)*100,rt(i))
end




