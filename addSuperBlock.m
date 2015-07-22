function plan = addSuperBlock(expmnt)
% Extend the existing plan by one superblock. Return the extended plan
% plan = [blk, ecc_Marker_phi, target_phi]

rep = expmnt.nTrial;
plan = [];
phi_targets = Shuffle(0:rep-1) * 2*pi/8;
for blk_num = 1:rep
    temp = [ones(rep,1)*blk_num Shuffle(0:rep-1)' * 2*pi/8 ones(rep,1)*phi_targets(blk_num)];
    plan = [plan;temp];
end

if isfield(expmnt, 'plan')
    plan(:,1) = plan(:,1) + expmnt.plan(end,1);
    plan = [expmnt.plan; plan];
end
% [ti ri] = ndgrid(repmat(1:1,[1 rep]),1:1);
% ti = Shuffle(ti);
%
% % rep = ceil(expmnt.nTrial / numel(expmnt.target.radius));
% % [ti ri] = ndgrid(repmat(1:numel(expmnt.target.radius),[1 rep]),1:numel(expmnt.ring.radius));
%
% ti = ti(1:expmnt.nTrial,:);
% ri = ri(1:expmnt.nTrial,:);
% blk = ri;
% ri = ri(:,Shuffle(1:size(ri,2)));
% plan = [blk(:), ri(:), ti(:)];
