%Run a block of trials

% set target and tolerance
targColor = expmnt.target.color;
targLength = round(expmnt.target.length *expmnt.ppd);
tol = (relaxationConst *expmnt.ppd)^2;

[center(1),center(2)] =  RectCenter(winRect);

minDur = expmnt.minContactTime;
mxTrialDur = expmnt.mxTrialDur;

eccMarker_R = expmnt.eccMarker.r;
target_R = expmnt.target.r;
%Offset of the fixation from the center
[x,y] = pol2cart(data.stim.eccMarkerPhi',eccMarker_R);
delta_gazeCenter_to_plus = round([x,y]*expmnt.ppd);
data.stim.delta_gazeCenter_to_plus = delta_gazeCenter_to_plus;  % in pixel units
[x,y] = pol2cart(data.stim.tarPhi',target_R);
delta_plus_to_cross = round([x, y]*expmnt.ppd); % in pixel units
data.stim.delta_plus_to_cross = delta_plus_to_cross;
%target location in screen coordinates
targetXY = bsxfun(@plus, center , delta_plus_to_cross + delta_gazeCenter_to_plus);
data.stim.targXY = targetXY;

for ii = 2:expmnt.nTrial+1
    
    playOneTrial;
    % getting ready
    
end
Priority(0);