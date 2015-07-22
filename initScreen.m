% initScreen
% Only works on GL version of psychtoolbox
%
% June, 2010 Nandy      Update to include Eyelink Initialization
%

% make sure we are working with an OpenGL version of PTB
AssertOpenGL;
% initialize Screen
screens=Screen('Screens');
screenNumber=max(screens);

[win, winRect] = Screen('OpenWindow',screenNumber,[],[],32);
if ~exist('initScreenBypassDisplaySettingCheck','var') || ~initScreenBypassDisplaySettingCheck
    if ~all(winRect == expmnt.screenRect)
        clear screen
        error('Screen size should be set to %d (h) x %d (w)',expmnt.screenRect(3),expmnt.screenRect(4));
    end
    frameDur = Screen('GetFlipInterval',win);
    if round(1/frameDur) ~= expmnt.refreshRate
        clear screen
        error('Screen refresh rate should be set to %d Hz',expmnt.refreshRate);
    end
end

% hide the cursor and show the initial background screen, set other
% commonly used colors
HideCursor;
backgroundEntry = expmnt.bgColor;
Screen('FillRect',win,backgroundEntry);
Screen(win,'TextSize',expmnt.instructSize);
Screen(win,'TextFont',expmnt.instructFont);
textEntry = expmnt.instructColor;
Screen('Flip',win);

maxpriority = MaxPriority(win);

if expmnt.useEyeTracker == 1
    % initialize eyelink
    if EyelinkInit()~= 1
        error('Eyelink initialization failed!');
    end
    % continue with the rest of eyelink initialization
    elHandle=EyelinkInitDefaults(win);
    
    %Added by Helga 10/18/13, to match the color of callibration/validation to the task color
        elHandle.backgroundcolour = BlackIndex(win);
        elHandle.foregroundcolour = GrayIndex(win, .51);    
        if ~isempty(elHandle.callback)            
            PsychEyelinkDispatchCallback(elHandle);
        end
    
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
end

% center of the screen
[winCenterX,winCenterY]=RectCenter(winRect);
% height and width of the screen
winWidth  = RectWidth(winRect);
winHeight = RectHeight(winRect);
