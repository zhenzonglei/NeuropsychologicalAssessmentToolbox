function [acc,rt] = WMSummary(resp)
% [acc,rt] = WMSummary(resp)
% acc, 1x1, mean
% rt, 2x1,  mean and sem

% respone matrix, nTrial x 5
% first column,  cond index, second column, stim index,
% third column, true answer, fourth column, reponse answer
% fifth colunm,  reaction time

nTrial = size(resp,1);
correct  = resp(:,3) == resp(:,4);
acc = nnz(correct)/nTrial;
rt(1,1) = nanmean(resp(correct,5));
rt(2,1) = nanstd(resp(correct,5))/sqrt(nTrial);
