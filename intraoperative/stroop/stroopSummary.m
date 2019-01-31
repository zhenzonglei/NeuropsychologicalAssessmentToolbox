function [acc,rt] = stroopSummary(resp)
% [acc,rt] = stroopSummary(resp)
% acc, 2x1, cogruent and incongruent
% rt, 2x1,  cogruent and incongruent

congruent = resp(:,1) == 1;
incongruent = resp(:,1) == 2;
correct = resp(:,3)==resp(:,4);
nTrial = length(congruent)/2;

% acc and rt for congruent
idx = congruent & correct;
congruent_acc = nnz(idx)/nTrial;
congruent_rt = nanmean(resp(idx,5));

% acc and rt for incongruent
idx = incongruent & correct;
incongruent_acc = nnz(idx)/nTrial;
incongruent_rt = nanmean(resp(idx,5));

acc = [congruent_acc;incongruent_acc];
rt = [congruent_rt;incongruent_rt];
