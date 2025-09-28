function [xPos,yPos] = getStimLocs(prefs,win,nItems)
% segment the inner window into four quadrants - for xCoords, 1st
% row = positions in left half of display, 2nd row = right half.
% For yCoords - 1st row = top half, 2nd row = bottom half
xCoords = [linspace((win.foreRect(1)+prefs.stimSize),win.centerX-prefs.stimSize,300); linspace(win.centerX+prefs.stimSize,(win.foreRect(3)-prefs.stimSize),300)];
yCoords = [linspace((win.foreRect(2)+prefs.stimSize),win.centerY-prefs.stimSize,300); linspace(win.centerY+prefs.stimSize,(win.foreRect(4)-prefs.stimSize),300)];
xLocInd = randperm(size(xCoords,2)); yLocInd = randperm(size(yCoords,2));

% Pick x,y coords for drawing stimuli on this trial, making sure
% that all stimuli are seperated by >= prefs.minDist
if nItems ==1
    xPos = [xCoords(randi(2),xLocInd(1))];  % pick randomly from first and second x rows (L/R halves)
    yPos = [yCoords(randi(2),yLocInd(1))];  % pick randomly from first and second y rows (Top/Bottom).
elseif nItems ==2
    randomPosition = randi(2);
    if randomPosition == 1
        xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2))]; % pick one left and one right item
        yPos = [yCoords(randi(2),yLocInd(1)),yCoords(randi(2),yLocInd(2))]; % pick randomly, top or bottom
    else
        xPos = [xCoords(randi(2),xLocInd(1)),xCoords(randi(2),xLocInd(2))]; % pick randomly, left or right!
        yPos = [yCoords(1,yLocInd(1)),yCoords(2,yLocInd(2))]; % pick one top, one bottom!
    end
elseif nItems ==3
    xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4))]; % one L one R
    yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4))]; % one top one bottom for e/ L/R
    % let's use the same scheme as 4 items, but randomly leave one
    % out!
    randomOrder = randperm(4);
    xPos = xPos(randomOrder(1:3));
    yPos = yPos(randomOrder(1:3));
elseif nItems ==4
    xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4))]; % one L one R
    yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4))]; % one top one bottom for e/ L/R
elseif nItems ==5
    randomPosition = randi(2); % pick one of two quadrants to stick the second item
    while 1
        if randomPosition == 1
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>prefs.minDist
                %             if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>prefs.minDist
                break;
            end
        elseif randomPosition == 2
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(2,xLocInd(5))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt((xPos(2)-xPos(5))^2+(yPos(2)-yPos(5))^2)>prefs.minDist
                break;
            end
        end
    end
elseif nItems ==6
    randomPosition = randi(2); % put extra squares in top or bottom half;
    while 1
        if randomPosition == 1
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(1,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>prefs.minDist
                if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>prefs.minDist
                    break;
                end
            end
        else
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(2,yLocInd(5)),yCoords(2,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(3)-xPos(5))^2+abs(yPos(3)-yPos(5))^2)>prefs.minDist
                if sqrt((xPos(4)-xPos(6))^2+(yPos(4)-yPos(6))^2)>prefs.minDist
                    break;
                end
            end
        end
    end
elseif nItems == 8
    while 1
        xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
        xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6)),xCoords(1,xLocInd(7)),xCoords(2,xLocInd(8))];
        yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(1,yLocInd(6)),yCoords(2,yLocInd(7)),yCoords(2,yLocInd(8))];
        % make sure that w/in quadrant points satisfy the minimum
        % distance requirement
        if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>prefs.minDist
            if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>prefs.minDist
                if sqrt((xPos(3)-xPos(7))^2+(yPos(3)-yPos(7))^2)>prefs.minDist
                    if sqrt((xPos(4)-xPos(8))^2+(yPos(4)-yPos(8))^2)>prefs.minDist
                        break;
                    end
                end
            end
        end
    end
end

end

