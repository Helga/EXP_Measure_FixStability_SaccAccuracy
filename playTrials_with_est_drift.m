%Run a block of trials

% set target and tolerance
targColor = expmnt.target.color;
targLength = round(expmnt.target.length *expmnt.ppd);
tol = (relaxationConst *expmnt.ppd)^2;

[center(1),center(2)] =  RectCenter(winRect);


eccMarker_R = expmnt.eccMarker.r;
target_R = expmnt.target.r;
%Offset of the fixation from the center
[x,y] = pol2cart(data.stim.eccMarkerPhi',eccMarker_R);
delta_gazeCenter_to_plus = round([x,y]*expmnt.ppd);
data.stim.delta_gazeCenter_to_plus = delta_gazeCenter_to_plus;  % in pixel units
[x,y] = pol2cart(data.stim.tarPhi',target_R);
delta_plus_to_cross = round([x, y]*expmnt.ppd); % in pixel units
data.stim.delta_plus_to_cross = delta_plus_to_cross;
%target location in screen cooridinates
targetXY = delta_gazeCenter_to_plus + delta_plus_to_cross ;
targetXY = targetXY + center;
data.stim.targXY = targetXY;


for ii = 2:expmnt.nTrial+1
    
    
    % getting ready
    if expmnt.useEyeTracker == 1
        Priority(1);
    end
    
    oldEyePos = center;
    FlushEvents('KeyDown');
    Screen('FillRect',win,backgroundEntry)
    WaitSecs(expmnt.iti);
    
    % at the beginning of the next frame
    t2 = nan;
    t1 = nan;
    t0 = Screen('Flip',win);
    Snd('Play',expmnt.trialBeep);
    
    % Infinite display loop: the display is updated Whenever "gaze position"
    % changes. Loop aborts on stable fixation exceed the minimum required time.
    while 1
        % Get eye coordinates
        if expmnt.useEyeTracker == 1
            err=Eyelink('CheckRecording');
            if(err~=0)
                error('Eyelink not recording eye-position data');
            end
            if Eyelink('NewFloatSampleAvailable') > 0
                % get the sample in the form of an event structure
                eyeSampleTime = GetSecs;
                elEvent = Eyelink('NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = elEvent.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = elEvent.gy(eye_used+1);
                    pupilSize = elEvent.pa(eye_used+1);
                    % do we have valid data and is the pupil visible?
                    if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA && elEvent.pa(eye_used+1)>0.5
                        eyeavail = 1;
                        est_drift
                        eyePos = [x, y] - est_drift;
                        
                    else
                        eyeavail = 0;
                        Screen('FillRect',win,backgroundEntry);
                        Screen('Flip',win);
                        if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA
                            eyePos = [x, y] - est_drift;
                        else
                            eyePos = [nan, nan];
                        end
                    end
                end
            end
        else
            % Query current mouse cursor position (our "pseudo-eyetracker")
            if GetSecs-eyeSampleTime < 0.001 % keep the millisecond rate
                eyeavail = 0;
            else
                % Query current mouse cursor position (our "pseudo-eyetracker")
                eyeavail = 1;
                [eyePos(1), eyePos(2), buttons]=GetMouse;
                pupilSize = 1;
                eyeSampleTime = GetSecs;
            end
        end
        
        % Redraw if eye-position has changed
        gaze_changed = ~isequal(eyePos, oldEyePos);
        if eyeavail && gaze_changed
            newEye = delta_gazeCenter_to_plus(ii,:) + eyePos;%show the fixation at newEye on the screem
            Screen('FillRect', win, backgroundEntry);
            %draw fixation (plus)
            drawFixation(win,round(newEye), fixationLength, fixationColor);
            %                 %draw target (cross)
            drawCross(win, round(targetXY(ii,:)), targLength, targColor);
            vblTS = Screen('Flip',win);
            
            
            % Save gaze data and test for stable fixation
            % store the eye position
            gazeSeq(thisGaze,:) = eyePos;
            gazeTime(thisGaze,:) = [vblTS eyeSampleTime];
            gazePupil(thisGaze,:) = pupilSize;
            gazeStimIdx(thisGaze,1) = ii;
            thisGaze = thisGaze+1;
            
            % time-out, or exit with stable gaze
            if eyeSampleTime-t0 > mxTrialDur
                t2 = eyeSampleTime;
                Snd('Play',expmnt.missedBeep);
                break
            end
            distsq = sum((newEye - data.stim.targXY(ii, :)).^2);
            
            if tol >= distsq
                if ~stableGaze
                    stableGaze = 1;
                    t1 = eyeSampleTime;
                else
                    if eyeSampleTime-t1 >= minDur
                        t2 = eyeSampleTime;
                        Snd('Play',expmnt.acquiredBeep);
                        break;
                    end
                end
            else % out of bound
                stableGaze = 0;
                t1 = nan;
            end
            % Keep track of last gaze position:
            oldEyePos=eyePos;
            
        end
        
        if GetSecs-t0 > mxTrialDur
            t2 = GetSecs;
            Snd('Play',expmnt.missedBeep);
            break
        end
        %WaitSecs(0.001);
    end
    
    % store the timing data for this trial
    data.stim.t0(ii) = t0;
    data.stim.t1(ii) = t1;
    data.stim.t2(ii) = t2;
end
Priority(0);