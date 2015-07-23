%Run a block of trials

% set target and tolerance
targColor = expmnt.target.color;
targLength = round(expmnt.target.length *expmnt.ppd);
tol = (relaxationConst *expmnt.ppd)^2;

[center(1),center(2)] =  RectCenter(winRect);

minDur = expmnt.minContactTime;
mxTrialDur = expmnt.mxTrialDur;

eccFix_R = expmnt.eccFix.r;
target_R = expmnt.target.r;
%Offset of the fixation from the center
[x,y] = pol2cart(data.stim.eccFixPhi',eccFix_R);
delta_center_to_fixation = round([x,y]*expmnt.ppd);
data.stim.delta_gazeCenter_to_plus = delta_center_to_fixation;  % in pixel units
[x,y] = pol2cart(data.stim.tarPhi',target_R);
delta_center_to_cross = round([x, y]*expmnt.ppd); % in pixel units
data.stim.delta_center_to_cross = delta_center_to_cross;
%target location in screen coordinates
targetXY = bsxfun(@plus, center , delta_center_to_cross);
data.stim.targXY = targetXY;

for ii = 2:expmnt.nTrial+1
    
    playOneTrial;
    % getting ready
    
end
Priority(0);