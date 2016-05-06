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
        currentLevel = 0;       % Variable to keep track of the level
        totalClicks = 0;        % Keep track of the c=amount of clicks
        bestScore = 9999;       % Best score
        maxLevels = 20;         % Maximum amount of Levels
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
            buttonHeight = 50;
            tempX = obj.window.width/2 - buttonWidth/2;       %
            start = Button(tempX, 4*buttonHeight, buttonWidth, buttonHeight);
            start.setAllTexts('START');
            start.setFontSize(35);
            start.setAllTextColors(1,1,1);
            start.setNormalTextColor(0,0,0);
            start.setAllColors(0,0,0);
            start.setNormalColor(1,1,1);
            
            scoreScreen = Button(tempX, 6*buttonHeight, buttonWidth, buttonHeight);
            scoreScreen.setAllTexts('BEST SCORES');
            scoreScreen.setFontSize(35);
            scoreScreen.setAllTextColors(1,1,1);
            scoreScreen.setNormalTextColor(0,0,0);
            scoreScreen.setAllColors(0,0,0);
            scoreScreen.setNormalColor(1,1,1);
            
            helpscreen = Button(tempX, 8*buttonHeight, buttonWidth, buttonHeight);
            helpscreen.setAllTexts('HELP');
            helpscreen.setFontSize(35);
            helpscreen.setAllTextColors(1,1,1);
            helpscreen.setNormalTextColor(0,0,0);
            helpscreen.setAllColors(0,0,0);
            helpscreen.setNormalColor(1,1,1);
            
            exit  = Button(tempX, 10* buttonHeight, buttonWidth, buttonHeight);
            exit.setAllTexts('EXIT');
            exit.setFontSize(35);
            exit.setAllTextColors(1,1,1);
            exit.setNormalTextColor(0,0,0);
            exit.setAllColors(0,0,0);
            exit.setNormalColor(1,1,1);
            
            obj.mainMenu = ButtonList();
            obj.mainMenu.add(start);
            obj.mainMenu.add(scoreScreen);
            obj.mainMenu.add(helpscreen);
            obj.mainMenu.add(exit);
            
            obj.gameMatrixButtons = ButtonList();
            
            if(exist('bestscore','file'))
                obj.bestScore = load('bestscore');
            end
            
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
                    case GameStates.NEXTLEVEL
                        obj.goToNextLevel();
                    case GameStates.GAMEOVER
                        obj.finishGame();
                    case GameStates.HIGHSCORE
                        obj.showScore();
                    case GameStates.HELP
                        obj.showHelp();
                end                        
               
                obj.window.update();
            end
            
            % Clean up
            obj.window.destroyWindow();
        end
        
        %===============================
        % Show Help text
        %===============================
        function showHelp(obj)
            text(0,0,'Click on a tile to toggle the color of the tile itself, and the 4 adjacent tiles (up, down, left,',...
                'fontsize',25,...
                'verticalAlignment','top',...
                'HorizontalAlignment','left');
            text(0,30,' right). To win, you must turn all tiles on (white).',...
                'fontsize',25,...
                'verticalAlignment','top',...
                'HorizontalAlignment','left');
            
            %Click to continue
             if (obj.window.hasClicked())
                 obj.gameState = GameStates.MAINMENU;
             end
        end
        
        %===============================
        % Show highscores (actually low scores)
        %===============================
        function showScore(obj)
            text(   obj.window.width/2,...
                    obj.window.height/2,...
                    ['Best Score: ',num2str(obj.bestScore)],...
                    'HorizontalAlignment','center',...
                    'fontSize',60)
                
             if (obj.window.hasClicked())
                 obj.gameState = GameStates.MAINMENU;
             end
        end
        
        %===============================
        % Finish game
        %===============================
        function finishGame(obj)
            
            text(obj.window.width/2, obj.window.height/2,   'Success!',...
                                                            'HorizontalAlign','center',...
                                                            'VerticalAlign','middle',...
                                                            'fontSize',100);
            text(obj.window.width/2, obj.window.height/4*3,   'Press m to continue',...
                                                            'HorizontalAlign','center',...
                                                            'VerticalAlign','middle',...
                                                            'fontSize',35);
            if (obj.window.getKeyDown('m'))
                if (obj.totalClicks < obj.bestScore)
                    obj.bestScore = obj.totalClicks;
                end
                obj.resetGame();
                obj.gameState = GameStates.MAINMENU;
            end
        end
        %===============================
        % Next level routine
        %===============================
        function goToNextLevel(obj)
            % Increase level
            obj.currentLevel = obj.currentLevel + 1;
            
            if (obj.currentLevel > obj.maxLevels)
                obj.gameState = GameStates.GAMEOVER;
                return;
            end
            
            % Determine Rows, Cols and shuffles
            size = 3 + floor((obj.currentLevel-1)/5);
            
            % Set rows and cols
            obj.Rows = size;
            obj.Cols = size;
            
            obj.gameState = GameStates.INGAME;
            % Create a clean light matrix
            obj.createMatrix(obj.Cols,obj.Rows);
            % Shuffle matrix
            obj.shuffleMatrix(obj.currentLevel);
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

            % Generate light buttons
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

            % Generate give up button
            tempButton = Button(obj.window.width-200,...
                                obj.window.height-50,...
                                200,...
                                50);
            tempButton.setAllTexts('GIVE UP!')
            tempButton.setAllColors(1,1,1);

            obj.gameMatrixButtons.add(tempButton);

            obj.updateLightButtons();
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
               obj.resetGame(); 
               obj.goToNextLevel();

            elseif (pressedIndex == 2)
                obj.gameState = GameStates.HIGHSCORE;
            elseif (pressedIndex == 3)
                obj.gameState = GameStates.HELP;
            elseif (pressedIndex == 4)
                obj.window.isCloseRequested = 1;
                % save highscore
                dlmwrite('bestscore',obj.bestScore);
            end
        end
        
        %================================
        % In game loop
        %================================
        function inGameLoop(obj)          
            
           
            % Check success
            if (obj.checkWin())              
                
                obj.gameState = GameStates.NEXTLEVEL;
                obj.window.clearInputEvents();
                
            else
                clicked = obj.window.hasClicked();
                if (clicked)
                    clickedIndex = obj.gameMatrixButtons.checkButtons( obj.window.mouseX,...
                                                               obj.window.height - obj.window.mouseY,...
                                                               clicked); 
                    % Light buttons action
                    if (clickedIndex > 0 && clickedIndex <= obj.Rows*obj.Cols)
                        obj.clickAction(floor((clickedIndex-1)/obj.Rows)+1,rem(clickedIndex-1,obj.Rows)+1);
                        obj.updateLightButtons();
                        obj.totalClicks = obj.totalClicks +1;
                    % The give up button
                    elseif (clickedIndex == obj.Rows*obj.Cols+1)
                        obj.gameState = GameStates.MAINMENU;
                        obj.window.clearInputEvents();
                    end
                    
                end
                
                obj.gameMatrixButtons.drawAll();
                text(obj.window.width, 0,...
                     'Level:',...
                     'HorizontalAlignment','right',...
                     'VerticalAlignment','top',...
                     'fontSize',35);
                 text(obj.window.width, 60,...
                     [num2str(obj.currentLevel),'/',num2str(obj.maxLevels)],...
                     'HorizontalAlignment','right',...
                     'VerticalAlignment','top',...
                     'fontSize',35);
                 text(obj.window.width, 120,...
                     'Clicks:',...
                     'HorizontalAlignment','right',...
                     'VerticalAlignment','top',...
                     'fontSize',35);
                 
                 text(obj.window.width, 180,...
                     num2str(obj.totalClicks),...
                     'HorizontalAlignment','right',...
                     'VerticalAlignment','top',...
                     'fontSize',35);
                 
            end
        end
        
        %================================
        % Reset the game
        %================================
        function resetGame(obj)
            obj.currentLevel = 0;
            obj.totalClicks = 0;
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

