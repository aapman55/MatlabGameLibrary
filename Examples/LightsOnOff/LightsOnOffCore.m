classdef LightsOnOffCore < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        window;                 % Game window
        gameState;              % Current game state
        gameMatrix;             % The game matrix
        gameMatrixButtons;      % clickable lights
        mainMenu;               % ButtonList object
        Rows = 5;               % Default number of rows
        Cols = 5;               % Default number of columns
    end
    
    methods
        %================================
        % Constructor
        %================================
        function obj = LightsOnOffCore()
            obj.window = Window(1280,700,'Lights On/Off v0.1');
            obj.window.setClearColor(.8,.8,0);
            obj.window.setResizable(0);
            obj.gameState = GameStates.MAINMENU;
            
            % Build main menu
            buttonWidth = 400;
            buttonHeight = 100;
            tempX = obj.window.width/2 - buttonWidth/2;       %
            start = Button(tempX, 3*buttonHeight, buttonWidth, buttonHeight);
            start.setAllTexts('START');
            start.setFontSize(35);
            start.setAllTextColors(1,1,1);
            start.setNormalTextColor(0,0,0);
            start.setAllColors(0,0,0);
            start.setNormalColor(1,1,1);
            
            exit  = Button(tempX, 5* buttonHeight, buttonWidth, buttonHeight);
            exit.setAllTexts('EXIT');
            exit.setFontSize(35);
            exit.setAllTextColors(1,1,1);
            exit.setNormalTextColor(0,0,0);
            exit.setAllColors(0,0,0);
            exit.setNormalColor(1,1,1);
            
            obj.mainMenu = ButtonList();
            obj.mainMenu.add(start);
            obj.mainMenu.add(exit);
            
            obj.gameMatrixButtons = ButtonList();
        end
        
        %================================
        % main game loop
        %================================
        function start(obj)
            
            while(~obj.window.isCloseRequested)
                switch obj.gameState
                    case GameStates.MAINMENU
                        obj.mainMenuLoop();
                    case GameStates.INGAME
                        obj.inGameLoop();
                end                        
               
                obj.window.update();
            end
            
            % Clean up
            obj.window.destroyWindow();
        end
        
        %================================
        % Main menu loop
        %================================
        function mainMenuLoop(obj)
           
            % Check buttons
            pressedIndex = obj.mainMenu.checkButtons(   obj.window.mouseX,...
                                                        obj.window.height - obj.window.mouseY,...
                                                        obj.window.hasClicked());
            % draw menu
            obj.mainMenu.drawAll();
            
            % Draw Title
            text(obj.window.width/2, 0, 'Lights On/Off','Color',[1,1,1],...
                                                        'fontSize', 70,...
                                                        'VerticalAlignment','top',...
                                                        'HorizontalAlignment','center');
            
            % When the start button is clicked
            if (pressedIndex == 1)
                obj.gameState = GameStates.INGAME;
                % Create a clean light matrix
                obj.createMatrix(obj.Cols,obj.Rows);
                % Shuffle matrix
                obj.shuffleMatrix(5);
                % Clear game Lights list
                obj.gameMatrixButtons.clear();
                % Calculate button size
                buttonSize = min(obj.window.width/obj.Cols,obj.window.height/obj.Rows);
                % Total height
                totalHeight = obj.Rows * buttonSize;
                % Total width
                totalWidth = obj.Cols * buttonSize;
                % beginX
                beginX = obj.window.width/2 - totalWidth /2;
                % beginY
                beginY = obj.window.height/2 - totalHeight/2;
                
                % Generate buttons
                for j=1:obj.Cols
                    for i=1:obj.Rows                    
                        tempButton = Button(beginX+(j-1)*buttonSize,...
                                            beginY+(i-1)*buttonSize,...
                                            buttonSize,...
                                            buttonSize);
                        % Add to list
                        obj.gameMatrixButtons.add(tempButton);
                    end                    
                end
                obj.updateLightButtons();

            elseif (pressedIndex == 2)
                obj.window.isCloseRequested = 1;
            end
        end
        
        %================================
        % In game loop
        %================================
        function inGameLoop(obj)          
            
           
            % Check success
            if (obj.checkWin())
                text(obj.window.width/2, obj.window.height/2,   'Success!',...
                                                                'HorizontalAlign','center',...
                                                                'VerticalAlign','middle',...
                                                                'fontSize',100);
                text(obj.window.width/2, obj.window.height/4*3,   'Press m to continue',...
                                                                'HorizontalAlign','center',...
                                                                'VerticalAlign','middle',...
                                                                'fontSize',35);
                
                if (obj.window.getKeyDown('m'))
                    obj.gameState = GameStates.MAINMENU;
                    obj.window.clearInputEvents();
                end
            else
                clicked = obj.window.hasClicked();
                if (clicked)
                    clickedIndex = obj.gameMatrixButtons.checkButtons( obj.window.mouseX,...
                                                               obj.window.height - obj.window.mouseY,...
                                                               clicked);                                                           
                    if (clickedIndex > 0)
                        obj.clickAction(floor((clickedIndex-1)/obj.Rows)+1,rem(clickedIndex-1,obj.Rows)+1);
                        obj.updateLightButtons();
                    end
                end
                
                obj.gameMatrixButtons.drawAll();
            end
        end
        
        %================================
        % Check success
        %================================
        function isWin = checkWin(obj)
            isWin = prod(obj.gameMatrix(:));
        end
        %================================
        % Create Matrix
        %================================
        function createMatrix(obj, sizeX, sizeY)
           obj.gameMatrix = ones(sizeY,sizeX); 
        end
        
        %================================
        % Shuffle Matrix
        %================================
        function shuffleMatrix(obj, amountOfTimes)
            [sizeY, sizeX] = size(obj.gameMatrix);
            for i=1:amountOfTimes
                ranX = randi(sizeX, 1);
                ranY = randi(sizeY, 1);
                obj.clickAction(ranX, ranY);
            end
        end
        
        %================================
        % Click action
        %================================
        function clickAction(obj, indexX, indexY)
            [sizeY, sizeX] = size(obj.gameMatrix);
            % Toggle clicked square
            obj.gameMatrix(indexY, indexX) = obj.toggle(obj.gameMatrix(indexY, indexX));
            % Toggle left square
            if (indexX > 1)
                obj.gameMatrix(indexY, indexX-1) = obj.toggle(obj.gameMatrix(indexY, indexX-1));
            end
            % Toggle Right square
            if (indexX < sizeX)
                obj.gameMatrix(indexY, indexX+1) = obj.toggle(obj.gameMatrix(indexY, indexX+1));
            end
            % Toggle upper square
            if (indexY > 1)
                obj.gameMatrix(indexY-1, indexX) = obj.toggle(obj.gameMatrix(indexY-1, indexX));
            end
            % Toggle lower square
            if (indexY < sizeY)
                obj.gameMatrix(indexY+1, indexX) = obj.toggle(obj.gameMatrix(indexY+1, indexX));
            end
        end
        
        %===============================
        % updateLightButtons
        %===============================
        function updateLightButtons(obj)
            for i=1:length(obj.gameMatrix(:))
                if obj.gameMatrix(i) == 1
                    obj.gameMatrixButtons.list(i).setAllColors(1,1,1);
                else
                    obj.gameMatrixButtons.list(i).setAllColors(0,0,0);
                end
            end
        end
        
        %================================
        % Toggle Light
        %================================
        function valOut = toggle(~, value)
            valOut = value* -1 +1;
        end
    end
    
end

