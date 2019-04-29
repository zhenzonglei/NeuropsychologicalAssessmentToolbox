function [acc,rt] = stroopSummary(resp)
% [acc,rt] = stroopSummary(resp)
% acc, 3x1, mean
% rt,3x2,  mean and sem
acc = nan(3,1); % congruent, incongruent and neutral
rt = nan(3,2);
correct = resp(:,3)==resp(:,4);

for i = 1:3
    cond = resp(:,1) == i;
    nTrial = nnz(cond);
    
    % acc and rt
    idx = cond & correct;
    acc(i) = nnz(idx)/nTrial;
    rt(i,1) = nanmean(resp(idx,5));
    rt(i,2) = nanstd(resp(idx,5))/sqrt(nnz(idx));
end
