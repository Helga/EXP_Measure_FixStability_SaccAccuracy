%
% Main routine for measuring fixation stability
%
% NOTE: This code uses Psychtoolbox 3.x
%
% History: Dec 10, 2013   HM based on code from BST(Lord of the Rings
% exoeriment)

clear all
clear mex
KbName('UnifyKeyNames');

%%%% comment out this line when runing real experiment
%initScreenBypassDisplaySettingCheck = 1;
expmnt.task = 'stability measurement';
expmnt.subj = input('Subj ID:','s');
expmnt.DomEye = input('Dominant eye(R or L):','s');
dataFileName       = [expmnt.subj '.mat']; % experiment parameters + response data
eyeTrackerBaseName = [expmnt.subj]; % eyetracker data
bkupFileName       = [expmnt.subj '_backup.mat']; % backup file

if ~exist(dataFileName,'file')
    %%% NEW SUBJECT %%%
    %%% All experimental parameters should be listed here.
    %%% They should not be anywhere else in the code.
    
    % The display
    expmnt.ppd = 26.36; % pixels per degree
    expmnt.screenRect =[0 0 1024 768] ;
    %change it back to this for running it for eye-tracker[0 0 1024 768]; % pixels
    
    expmnt.bgColor = [0 0 0];
    expmnt.refreshRate =  85; %Hz
    
    
    expmnt.relaxationConst = 0.5;%relxation constant for contacting the target,  in degress
    
    %% Eccentric gaze contingent marker (plus)
    %Eccentric markers are located on an 8 equally-distanced (pseudorandom)
    %points on a contour. If the radious of the contour is set to zero,
    %markers will appear at the center of the gaze
    expmnt.eccFix.length =  .4;
    expmnt.eccFix.color =   [127 127 127]%  [0 255 0];    
    expmnt.eccFix.r = 6;%degree, distance from center of screen.     
    
        
    %% Fixation target (cross)
    %fixations targets appear randomly at one of the 8 equally-disctanced
    %contour around the eccentric marker
    expmnt.target.length =  .4;
    expmnt.target.color = [127 127 127]% [0 255 0];    
    expmnt.target.r = 3; %degree, distance from the eccentric marker (plus).
    
    
    %% Trials and Blocks
    expmnt.nSuperBlock = inf; % no end point
    expmnt.nTrial = 8;% trial per block. We need to measure stability for 8 points on the contour
    expmnt.plan = addSuperBlock(expmnt);
    expmnt.thisBlock = 1;
    
    % The game
    expmnt.minContactTime = 0.5; %second, to dismiss a target
    expmnt.mxTrialDur = 10; %second, maximum trial duration
    expmnt.dirftPrepDur = 10; %second, trial duration for estimating drift
    expmnt.iti = 0; %second, inter-trial interval
    expmnt.trialBeep = sin(2*pi*0.06*(0:500)); % a new trial
    expmnt.acquiredBeep  = sin(2*pi*0.037*(0:900)); % target acquired
    expmnt.missedBeep  = [sin(2*pi*0.01*(0:2000)) zeros(1,1000) sin(2*pi*0.01*(0:2000))]; % target missed
    expmnt.data = {};
    expmnt.bestTime = inf;
    expmnt.staticPlus_display_time = 3%.2;%seconds, to show the plus before the target appears

    % Eye tracking
    expmnt.useEyeTracker = 1; % real eyetracker (set to 0 for mouse)
    expmnt.eyeCalInterval = 5; % in number of blocks
    expmnt.eyeCal = []; % blocks that started with eye tracker calibration
    
    % Misc
    expmnt.expDuration = 0;
    expmnt.instructFont = 'Courier';
    expmnt.instructSize = 24;
    
    expmnt.instructColor = [127 127 127];
    
    expmnt.saveInterval = 1; % how often data is saved
    
    % Initialize rand and randn
    expmnt.randState = sum(100*clock);
    expmnt.randnState = sum(100*clock);
    
else
    % Files associated with the subject
    % if a data file already exists for this subject, continue
    % from the point the subject left off
    load(dataFileName);
    rand('state',expmnt.randState);   % recover the last rand & randn
    randn('state',expmnt.randnState); % states from previous run
end

% pre-allocate space for storing gaze sequence information
% 1st column stores x position, 2nd column y position
maxGazeIter = 2^ceil(log(expmnt.mxTrialDur*(expmnt.nTrial+5)*1000)/log(2)); % length of the gaze record, at the rate 1 per ms
gazeSeq = single(zeros(maxGazeIter,2));
gazeTime = double(zeros(maxGazeIter,2));
gazePupil = single(zeros(maxGazeIter,1));
gazeStimIdx = uint16(zeros(maxGazeIter,1));

lastEyeCalBlk = -inf;
lastSavedBlk = -inf;

% initalize screen and screen-related parameters
initScreen; % screen will go blank at this point (bad if you are debugging)
%%% RUN THE EXPERIMENT
sessionStart = clock;
done = 0; % this flag is set within 'runBlock' if the subject wants to quit
while (~done)
    if expmnt.plan(end,1) < expmnt.thisBlock
        expmnt.plan = addSuperBlock(expmnt);
    end
    runBlock; % also save data for record and recovery
end;
%%% BOOK KEEPING AND CLEANUP
sessionStop = clock;
sessionDur = etime(sessionStop, sessionStart);
expmnt.expDuration = expmnt.expDuration + sessionDur;
msg = {};
msg{1} = sprintf('Session Duration: %d minutes', round(sessionDur/60));
msg{3} = sprintf('Backing up data ... ');
giveInstruction(win,msg,textEntry,backgroundEntry);
save(bkupFileName, 'expmnt');
save(dataFileName, 'expmnt');
msg{4} = 'Done!';
giveInstruction(win,msg,textEntry,backgroundEntry);
WaitSecs(0.5)
cleanup;
