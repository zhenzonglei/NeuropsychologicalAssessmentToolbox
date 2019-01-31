function [acc,rt] = dmsSummary(resp)
% [acc,rt] = dmsSummary(resp)
% acc, 2x1, match and nonmatch
% rt, 2x1,  mathc and nonmatch

% respone matrix, nTrial x 7 array. 
% first column,  cond index,
% second column, targ stim index(i.e.,true answer)
% third column,  distract stim index
% fourth column, targ location, 1-left, 2-right
% fifth colunm,  distract location, 1-left, 2-right
% sixth column, reponse answer
% sventh colunm,  reaction time

nTrial = size(resp,1);
idx = resp(:,4)==resp(:,6);

acc = nnz(idx)/nTrial;
rt = nanmean(resp(idx,7));
