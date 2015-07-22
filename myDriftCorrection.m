%repeat the drift check until you find a value below threshold

d = 10;
tries = 0;
[refPt_x, refPt_y] = RectCenter(winRect);

while d > 5
    tries = tries + 1
    
    flushEvents('KeyDown');
    result=EyelinkDoDriftCorrect(elHandle);
    fprintf(1,'EXPMNT: eye-tracker drift-correction result=%g\n',result);
    
    WaitSecs(0.5);
    FlushEvents('KeyDown');
    Eyelink('StartRecording');
    eye_used = Eyelink('EyeAvailable');
    
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
           % pupilSize = elEvent.pa(eye_used+1);
            % do we have valid data and is the pupil visible?
            if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA && elEvent.pa(eye_used+1)>0.5
                eyeavail = 1;
                eyePos_x = x;
                eyePos_y = y;
                
                %Added by Helga 1/23/14
                d = (eyePos_x - refPt_x)^2 +  (eyePos_y - refPt_y)^2;
                
%             else
%                 eyeavail = 0;
%                 Screen('FillRect',win,backgroundEntry);
%                 Screen('Flip',win);
%                 if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA
%                     eyePos_x = x;
%                     eyePos_y = y;
%                 else
%                     eyePos_x = nan;
%                     eyePos_y = nan;
%                 end
            end
        end
    end
end
'***HELGA , Drift correction is done****'
tries

 FlushEvents('KeyDown');
    Eyelink('StartRecording');