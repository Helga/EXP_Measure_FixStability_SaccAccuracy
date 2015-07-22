% cleanup routine

clear screen
ShowCursor
if expmnt.useEyeTracker == 1
    Eyelink('ShutDown');
end
clear mex

