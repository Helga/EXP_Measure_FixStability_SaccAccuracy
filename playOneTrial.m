if expmnt.useEyeTracker == 1
    Priority(1);
end

oldEyePos = center;
FlushEvents('KeyDown');
Screen('FillRect',win,backgroundEntry)
WaitSecs(expmnt.iti);

% at the beginning of the next frame
trial_end_time = nan;
stable_gaze_start_time = nan;
trial_start_time = Screen('Flip',win);
fixation_on_time = 0;
target_on_time = 0;
Snd('Play',expmnt.trialBeep);
trial_acquired_time = nan;

state = 'fixation'
% Infinite display loop: the display is updated Whenever "gaze position"
% changes. Loop aborts on stable fixation exceed the minimum required time.
while strcmp(state, 'finish') == 0
    eyeavail = 0;
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
                    eyePos = [x, y];
                    
                else
                    eyeavail = 0;
                    Screen('FillRect',win,backgroundEntry);
                    Screen('Flip',win);
                    if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA
                        eyePos = [x, y];
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
    
    if eyeavail
        % Save gaze data and test for stable fixation
        % store the eye position
        gazeSeq(thisGaze,:) = eyePos;
        gazeTime(thisGaze,:) = [vblTS eyeSampleTime];
        gazePupil(thisGaze,:) = pupilSize;
        gazeStimIdx(thisGaze,1) = ii;
        thisGaze = thisGaze+1;
        
        % Keep track of last gaze position:
        oldEyePos=eyePos;
        switch state
            case 'fixation'
                if fixation_on_time == 0
                    Screen('FillRect', win, backgroundEntry);
                    ST_fix_coord = round(delta_center_to_fixation(ii,:) + center);%location of the ecentric fixation
                    drawFixation(win,center, fixationLength, fixationColor); %draw the plus at the center of the screen
                    drawFixation(win,round(ST_fix_coord), 2, [255 255 255]); %draw the eccentric fixation cue
                    
                    fixation_on_time = Screen('Flip',win);
                elseif (GetSecs - fixation_on_time > expmnt.staticPlus_display_time)
                    state ='show_target';
                end
                
            case 'show_target'
                if gaze_changed
                    
                    if target_on_time == 0 || (GetSecs - target_on_time <expmnt.mxTrialDur) %if this is the first time we are in state or we still need to show the target
                        
                        newEye = round(eyePos - delta_center_to_fixation(ii,:) );%show the gaze-contingent plus
                        newEye = newEye - est_drift; %remove the drift
                        target_coord = round(targetXY(ii,:)- est_drift);
                        if target_on_time == 0
                            GC_plus_coord = newEye;%for book keeping. the initial location of the gaze contingent plus
                        end
                        Screen('FillRect', win, backgroundEntry);
                        %draw fixation (plus)
                        drawFixation(win,newEye, fixationLength, fixationColor);
                        %                 %draw target (cross)
                        drawCross(win, target_coord, targLength, targColor);
                        temp = Screen('Flip',win);
                        if target_on_time == 0
                            target_on_time = temp;
                        end
                        
                        distsq = sum((newEye - target_coord ).^2);
                        
                        if distsq <= tol
                            if ~stableGaze
                                stableGaze = 1;
                                stable_gaze_start_time = eyeSampleTime;
                            else
                                if eyeSampleTime-stable_gaze_start_time >= expmnt.minContactTime;
                                    trial_acquired_time = eyeSampleTime;
                                    Snd('Play',expmnt.acquiredBeep);
                                    state = 'finish';
                                    break;
                                end
                            end
                        else % out of bound
                            stableGaze = 0;
                            stable_gaze_start_time = nan;
                        end
                    end
                    % time-out,
                    if (GetSecs - target_on_time >expmnt.mxTrialDur)
                        Screen('fillrect', win, backgroundEntry);
                        Screen('Flip',win);
                        state = 'finish';
                        Snd('Play',expmnt.missedBeep);
                        break
                    end
                end
                
                
            otherwise
                error('Unknown state!');
        end
        trial_end_time = GetSecs;
        
        
        
    end
    
end

% store the timing data for this trial
data.stim.trial_start_time(ii) = trial_start_time;
data.stim.stable_gaze_start_time(ii) = stable_gaze_start_time;
data.stim.trial_end_time(ii) = trial_end_time;
data.stim.fixation_on_time(ii) = fixation_on_time;
data.stim.target_on_time (ii) = target_on_time;
data.stim.trial_acquired_time(ii) = trial_acquired_time;
data.stim.ST_fix_coord(ii,:) = ST_fix_coord;
data.stim.GC_plus_coord(ii,:) = GC_plus_coord;