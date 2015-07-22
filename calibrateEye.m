% Eye calibration

eyeTrackerSetupState = {'CALIBRATION','VALIDATION'};
eyeTrackerSetupStateCmd = {'c','v'};

stateIndx = 1;
clear instruction
while stateIndx <= length(eyeTrackerSetupState)
    % instructions for calibration/validation
    instruction{1} = sprintf('Eye Tracker Setup Step %g: %s', ...
        stateIndx,eyeTrackerSetupState{stateIndx});
    instruction{3} = 'Targets (rings) will be presented at various';
    instruction{4} = 'on-screen locations. Fixate on each target.';
    instruction{5} = 'Press spacebar to move on to the next target.';
    instruction{6} = 'Once the screen goes blank, wait for experimeter';
    instruction{7} = 'instructions and press ESC to proceed';    
    instruction{9} = 'Press spacebar to continue';
    instruction{10} = 'Press "q" to skip';
    giveInstruction(win,instruction,textEntry,backgroundEntry);
    [cont, keycode] = getContinueResponse;
    eyeCalSkipped = 0;
    if ~cont
        eyeCalSkipped = 1;
        break
        
    end    
    % this is for experimenter use only: display the eye image on the computer monitor
    if keycode(KbName('return'))
        % display eye-image
        EyelinkDoTrackerSetup(elHandle,elHandle.ENTER_KEY);
        WaitSecs(1);
        FlushEvents('KeyDown');
        continue;
    end
    FlushEvents('KeyDown');
    
    % Calibrate/Validate
    result=EyelinkDoTrackerSetup(elHandle,eyeTrackerSetupStateCmd{stateIndx});
    fprintf(1,'EXPMNT: eye-tracker %s result=%g\n',eyeTrackerSetupState{stateIndx},result);
    WaitSecs(1);
    FlushEvents('KeyDown');
    
    stateIndx = stateIndx + 1;
end
FlushEvents('KeyDown');