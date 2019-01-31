function [acc,rt] = wmSummary(resp)
% [acc,rt] = stroopSummary(resp)
% acc, 2x1, match and nonmatch
% rt, 2x1,  mathc and nonmatch

% respone matrix, totalTrial x 5 x n stimType. 
% first column,  cond index,
% second column, stim index,
% third column, true answer,
% fourth column, reponse answer
% fifth colunm,  reaction time

match = resp(:,1) == 1;
nonmatch = resp(:,1) == 2;
correct = resp(:,3)==resp(:,4);
nTrial = length(match)/2;

% disp acc and rt for match condition
idx = match & correct;
match_acc = nnz(idx)/nTrial;
match_rt = nanmean(resp(idx,5));

% disp acc and rt for nonmatch condition
idx = nonmatch & correct;
nonmatch_acc = nnz(idx)/nTrial;
nonmatch_rt = nanmean(resp(idx,5));

acc = [match_acc;nonmatch_acc];
rt = [match_rt;nonmatch_rt];
