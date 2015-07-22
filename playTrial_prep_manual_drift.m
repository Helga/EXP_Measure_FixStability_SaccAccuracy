%Fixate on the central cross to begin the block
% set the fixation
fixationLength = round(expmnt.eccMarker.length *expmnt.ppd);
fixationColor = expmnt.eccMarker.color;
targColor = expmnt.target.color;
targLength = round(expmnt.target.length *expmnt.ppd);
% set the stimulus rects
stimIdx = 1;

relaxationConst= expmnt.relaxationConst;

% set reference point and tolerance
[refPt_x, refPt_y] = RectCenter(winRect);
tolsq = (relaxationConst *expmnt.ppd)^2;
stableGaze = 0;
minDur = expmnt.minContactTime;
mxTrialDur = expmnt.mxTrialDur;

% getting ready
if expmnt.useEyeTracker == 1
    Priority(1);
end
oldEyePos_x = nan;
oldEyePos_y = nan;
FlushEvents('KeyDown');
Screen('FillRect',win,backgroundEntry)
WaitSecs(expmnt.iti);
% at the beginning of the next frame
eyeSampleTime = nan;
trial_end_time = nan;
t1 = nan;
trial_start_time = Screen('Flip',win);
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
                    eyePos_x = x;
                    eyePos_y = y;
                else
                    eyeavail = 0;
                    Screen('FillRect',win,backgroundEntry);
                    Screen('Flip',win);
                    if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA
                        eyePos_x = x;
                        eyePos_y = y;
                    else
                        eyePos_x = nan;
                        eyePos_y = nan;
                    end
                end
            end
        end
        
   else
        % Query current mouse cursor position (our "pseudo-eyetracker")
        if GetSecs-eyeSampleTime < 0.001 % keep the millisecond rate
            eyeavail = 0;
        else
            eyeavail = 1;
            [eyePos_x, eyePos_y, buttons]=GetMouse;
            pupilSize = 1;
            eyeSampleTime = GetSecs;
        end
    end
    
   
    
    %     % Redraw if eye-position has changed
    if eyeavail && (eyePos_x~=oldEyePos_x || eyePos_y~=oldEyePos_y)
        
        Screen('fillrect', win, backgroundEntry);
        drawCross(win,[round(refPt_x) ,round(refPt_y)], targLength, targColor);
      %  drawFixation(win,[round(eyePos_x) ,round(eyePos_y)], fixationLength, fixationColor);
        vblTS = Screen('Flip',win);
    end
    
    % Save gaze data and test for stable fixation
    if eyeavail && (eyePos_x~=oldEyePos_x || eyePos_y~=oldEyePos_y)
        
        % store the eye position
        gazeSeq(thisGaze,:) = [eyePos_x eyePos_y];
        gazeTime(thisGaze,:) = [vblTS eyeSampleTime];
        gazePupil(thisGaze,:) = pupilSize;
        gazeStimIdx(thisGaze,1) = stimIdx;
        thisGaze = thisGaze+1;
        % time-out, or exit with stable gaze
        if eyeSampleTime-trial_start_time > expmnt.dirftPrepDur 
            trial_end_time = eyeSampleTime;
            Snd('Play',expmnt.missedBeep);
            break
        end
        
      %  dissqr = (eyePos_x-refPt_x)^2+(eyePos_y-refPt_y)^2;
    %    if tolsq >= dissqr % within bound
%             if ~stableGaze
%                 stableGaze = 1;
%                 t1 = eyeSampleTime;
%                 
%             else
%                 if eyeSampleTime-t1 >= minDur
%                     trial_end_time = eyeSampleTime;
%                     Snd('Play',expmnt.acquiredBeep);
%                     break;
%                 end
%             end
%         else
%             % reset the flag
%             stableGaze = 0;
%             t1 = nan;
%         end
        % Keep track of last gaze position:
        oldEyePos_x=eyePos_x;
        oldEyePos_y=eyePos_y;
    end
    
    if GetSecs-trial_start_time > expmnt.dirftPrepDur 
        trial_end_time = GetSecs;
        Snd('Play',expmnt.missedBeep);
        break
    end
    %WaitSecs(0.001);
end


% store the timing data for this trial
data.stim.targXY(1,:) = [refPt_x, refPt_y];
data.stim.trial_start_time(1) = trial_start_time;
data.stim.stable_gaze_start_time(1) = nan;
data.stim.trial_end_time(1) = trial_end_time;

mean(gazeSeq(thisGaze,:))

 est_drift = double(nanmean(gazeSeq(1:thisGaze,:))- [winCenterX,winCenterY]);



