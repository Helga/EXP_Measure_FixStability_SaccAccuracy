function WaitSetMouse(newX, newY, windowPtrOrScreenNumber)

% set and wait for new cursor position to take effect

t0 = GetSecs;
while GetSecs-t0<5 % wait for new cursor position to be set, time out after five second
    SetMouse(newX,newY,windowPtrOrScreenNumber);
    [mx, my, buttons]=GetMouse(windowPtrOrScreenNumber);
    if mx==newX & my==newY
        break;
    end
end
