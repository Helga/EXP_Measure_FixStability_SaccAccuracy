% runBlock

% initialize data block
idx = find(expmnt.plan(:,1)==expmnt.thisBlock);
thisplan = expmnt.plan(idx,:);

data.eyeTracked = 0;
% each of the following has nTrial+1 entries.  The first one is the
% fixation trial (run by playTrial_prep)
% data.stim.ringIdx = [thisplan(1,2) thisplan(:,2)']; % 0 for the peripheral fixation ring
data.stim.eccMarkerPhi = [nan thisplan(:,2)']; % 0 for the peripheral fixation ring
data.stim.tarPhi = [nan thisplan(:,3)'];
data.stim.targXY = nan(length(data.stim.tarPhi),2);
data.stim.trial_start_time = nan(size(data.stim.eccMarkerPhi)); % trial start time (exp computer time)
data.stim.stable_gaze_start_time = nan(size(data.stim.eccMarkerPhi)); % stable contact time (exp computer time)
data.stim.trial_end_time = nan(size(data.stim.eccMarkerPhi)); % trial end time (exp computer time)
data.stim.trial_acquired_time = nan(size(data.stim.eccMarkerPhi)); % trial end time (exp computer time)

thisGaze = 1;
thisStim = 1;

% initial blank screen
WaitSecs(0.2);
FlushEvents('KeyDown');
Screen('FillRect',win,expmnt.bgColor);
Screen('Flip',win);

% calibrate eye tracker if needed
if expmnt.useEyeTracker == 1
    % eyetracker data file (one file per block)
    eyeTrackerFileName = [eyeTrackerBaseName num2str(expmnt.thisBlock,'%03d') '.edf'];
    Eyelink('OpenFile', eyeTrackerFileName);
    data.eyeTracked = 1; % assume eye calibration is skipped
    if expmnt.thisBlock - lastEyeCalBlk >= expmnt.eyeCalInterval
        calibrateEye;
        if ~eyeCalSkipped
            lastEyeCalBlk = expmnt.thisBlock;
            data.eyeTracked = 2; %2 means that a calibration has been ran
        end
    end
end

% provide instructions
clear instruction
instruction{1} = sprintf('Main Experiment: Block #%d', ...
    expmnt.thisBlock);
instruction{3} = '1) Fixate on the central mark (IMPORTANT!!)';
instruction{4} = ' and press the space bar.';
instruction{7} = 'Trials will begin automatically.';
instruction{9} = '2) For each trial, your task is to make and ';
instruction{10} = 'maintain contact between + and X.';
instruction{11} = 'Do this as fast and as reliable as you can.';
instruction{12} = 'The discs will be dismissed when you ';
instruction{13} = 'have established stable contact.';
instruction{15} = 'You WIN by speed!';
instruction{16} = 'Press spacebar to begin';
instruction{17} = 'Press "q" to quit';
giveInstruction(win,instruction,textEntry,backgroundEntry);
userQuit = ~getContinueResponse;
if userQuit
    done = 1;
    return
end

% central fixation and drift correction
if expmnt.useEyeTracker == 1
   
  %  myDriftCorrection; %Added by Helga 1/29/14
    FlushEvents('KeyDown');
    result=EyelinkDoDriftCorrect(elHandle);
    fprintf(1,'EXPMNT: eye-tracker drift-correction result=%g\n',result);
   
    WaitSecs(0.1);
    FlushEvents('KeyDown'); 
else
    giveInstruction(win,{'+'},textEntry,backgroundEntry);
    getContinueResponse;
    WaitSetMouse(randi(winWidth),randi(winHeight),win); % set cursor and wait for it to take effect
end


% start recording eye-position data
if expmnt.useEyeTracker == 1
    Eyelink('StartRecording');
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == elHandle.BINOCULAR; % if both eyes are tracked
        eye_used = elHandle.LEFT_EYE; % use left eye
    end
end

% --- % The game
 
    playTrial_prep_manual_drift
    playTrials_with_est_drift_new
    

% --- %
% Store data
data.numGazeIter = thisGaze-1;
data.gazeSeq     = gazeSeq(1:thisGaze-1,:);
data.gazeTime    = gazeTime(1:thisGaze-1,:);
data.gazePupil   = gazePupil(1:thisGaze-1,:);
data.gazeStimIdx = gazeStimIdx(1:thisGaze-1);
expmnt.data{end+1} = data;
expmnt.thisBlock = expmnt.thisBlock+1;
expmnt.randState = rand('state');
expmnt.randnState = randn('state');

% Provide performance summary
Screen('FillRect',win,expmnt.bgColor);
Screen('Flip',win);
timeToAcq = nanmedian(data.stim.trial_end_time(2:end)-data.stim.trial_start_time(2:end));
msg = {};
msg{1} =     sprintf('Your time this block: %.02f seconds per item',timeToAcq);
if ~isfield(expmnt,'bestTime') || timeToAcq < expmnt.bestTime
    expmnt.bestTime = timeToAcq;
    msg{2} = 'THIS IS YOUR BEST TIME!!!';
else
    msg{2} = sprintf('Your best time:       %.02f seconds per time',expmnt.bestTime);
end
msg{3} = sprintf('You missed %d out of %d', sum(isnan(data.stim.trial_acquired_time(2:end))), expmnt.nTrial);

% Save data while the subject is reading the score (saving data take a few
% seconds
if expmnt.thisBlock-1-lastSavedBlk > expmnt.saveInterval
    msg{5} = 'Saving data ...';
    giveInstruction(win,msg,textEntry,backgroundEntry);
    save(dataFileName, 'expmnt');
    lastSavedBlk = expmnt.thisBlock-1;
end
msg{5} = 'Saving the file. Press spacebar to continue';
giveInstruction(win,msg,textEntry,backgroundEntry);
getContinueResponse;

% stop recording eye-position data
if expmnt.useEyeTracker == 1
    Eyelink('StopRecording');
    Eyelink('closefile');
    
    status=Eyelink('ReceiveFile',eyeTrackerFileName, pwd,1);
    if status~=0
        fprintf('Failed to receive eye tracker data file. Status: %d\n', status);
    end
    if exist(eyeTrackerFileName, 'file') == 2
        fprintf('Eye tracker data file ''%s'' can be found in ''%s''\n', eyeTrackerFileName, pwd );
    else
        fprintf('Eye tracker data file location unknown!\n')
    end
end
