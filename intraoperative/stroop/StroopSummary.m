function [acc,rt] = StroopSummary(resp)
% [acc,rt] = StroopSummary(resp)
% acc, nCond x 1, mean
% rt,nCond x 2,  mean and sem

nCond = max(resp(:,1));
acc = nan(nCond,1); % congruent, incongruent and neutral
rt = nan(nCond,2);
correct = resp(:,3)==resp(:,4);

for i = 1:nCond
    cond = resp(:,1) == i;
    nTrial = nnz(cond);
    
    % acc and rt
    idx = cond & correct;
    acc(i) = nnz(idx)/nTrial;
    rt(i,1) = nanmean(resp(idx,5));
    rt(i,2) = nanstd(resp(idx,5))/sqrt(nnz(idx));
end
