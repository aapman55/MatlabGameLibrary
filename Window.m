classdef Window < handle
    %WINDOW Define the figure window
    
    properties
        resolution;                         % Resolution of your screen
        width;                              % width of the window
        height;                             % Height of the window
        title;                              % title of the window
        h;                                  % Window handle
        isKeyDown = zeros(1,256);           % Array to record if a key has been pressed down
        isCloseRequested = 0;               % Flag to see if the X of the window is pressed
        isMouseDown = 0;                    % Whether a mouse button is clicked
        mouseX;                             % Mouse x location (bottom left is origin)
        mouseY;                             % Mouse y location (bottom left is origin)
        previousTime= cputime;              % Previoustime for the FPS calculator
        targetFPS = 60;                     % Sets the target FPS, might not be achieved in heavy load
        resizable = 0;                      % is the window resizable
    end
    
    properties (Access = private)
        isClicked = 0;                      
        mouseDownX = -1 ;                    % X location of the mouse press event
        mouseDownY = -1 ;                    % Y location of the mouse press event
    end
    
    methods
        function obj = Window(width, height, title)   
            resolution = get(0, 'screensize');
            obj.resolution = resolution([3,4]);
            
            % save the width and height
            obj.width = width;
            obj.height = height;
            
            % save title
            obj.title = title;
            
            % Center the window
            h = figure('position',[ obj.resolution(1)/2-width/2,...  Left side
                                    obj.resolution(2)/2-height/2,... Bottom
                                    width,...
                                    height], ...
                        'name', title);
            hold on;  
            
            obj.h = h;
            
            % get the figure and axes handles
            hFig = gcf;
            hAx  = gca;

            % set the axes to full screen
            set(hAx,'Unit','normalized','Position',[0 0 1 1]);

            % hide the toolbar
            set(hFig,'menubar','none')

            % to hide the title
            set(hFig,'NumberTitle','off');
            
            axis off;
            axis([0 width 0 height]);
            
            % Reverse the Y-axis (to match with the openGL implementation)
            set(gca,'Ydir','reverse');
            %======================================
            % Define callbakc functions
            %======================================
            obj.h.KeyPressFcn = @obj.keyPressEventHandler;
            obj.h.KeyReleaseFcn = @obj.keyReleaseEventHandler;
            obj.h.CloseRequestFcn = @obj.windowCloseRequestEventHandler;
            obj.h.WindowButtonDownFcn = @obj.windowButtonPressEventHandler;
            obj.h.WindowButtonUpFcn = @obj.windowButtonReleaseEventHandler;            
            obj.h.WindowButtonMotionFcn = @obj.windowButtonMotionEventHandler;
                        
        end
        %========================================
        % Set window resizability
        %========================================
        function setResizable(obj, resizable)
            obj.resizable = resizable;
            if resizable
                obj.h.Resize = 'on';
            else
                obj.h.Resize = 'off';
            end
        end
        
        %========================================
        % Set draw canvas clear color
        %========================================
        function setClearColor(obj, r, g, b)
            obj.h.Color = [r,g,b];  
        end
        
        %========================================
        % Set target FPS
        %========================================
        function setFPS(obj,FPS)
            obj.targetFPS = FPS;
        end
        
        %========================================
        % Keyboard keypress callback function
        %========================================
        function keyPressEventHandler(obj, varargin)
           eventKeyData = varargin(2);
           
           obj.isKeyDown(double(eventKeyData{1}.Character)) = 1;
        end
        
        %========================================
        % Keyboard keyrelease callback function
        %========================================
        function keyReleaseEventHandler(obj, varargin)
           eventKeyData = varargin(2);
           
           obj.isKeyDown(double(eventKeyData{1}.Character)) = 0;
        end     
        
        %========================================
        % Window Button press call back function
        %========================================
        function windowButtonPressEventHandler(obj, varargin)
           obj.isMouseDown = 1;
           mouseData = get(gcf,'CurrentPoint');
           obj.mouseDownX = mouseData(1);
           obj.mouseDownY = mouseData(2);
        end
        
        %========================================
        % Window Button release call back function
        %========================================
        function windowButtonReleaseEventHandler(obj, varargin)
           obj.isMouseDown = 0;
           mouseData = get(gcf,'CurrentPoint');
           if (abs(mouseData(1) - obj.mouseDownX) < 3 && abs(mouseData(2) - obj.mouseDownY) < 3)
               obj.isClicked = 1;
           end
           obj.mouseDownX = -1;
           obj.mouseDownY = -1;
        end
        
        %=========================================
        % Click event
        %=========================================
        function clicked = hasClicked(obj)
            clicked = obj.isClicked;
            obj.isClicked = 0;
        end
        
        %========================================
        % Window mouse location. Origin in bottom left
        %========================================
        function windowButtonMotionEventHandler(obj, varargin)
           mouseData = get(gcf,'CurrentPoint');
           obj.mouseX = mouseData(1);
           obj.mouseY = mouseData(2);
        end
        
        %========================================
        % Window close event callback
        %========================================
        function windowCloseRequestEventHandler(obj, varargin)             
            obj.isCloseRequested = 1;
        end
        
        %========================================
        % Queries if a certain button is pressed
        %========================================
        function down = getKeyDown(obj, key)
              down = obj.isKeyDown(double(key));          
        end
        
        %========================================
        % Returns whether the X button of the 
        % window has been pressed.
        %========================================
        function closing = getIsCloseRequested(obj)
           closing = obj.isCloseRequested;            
        end
        
        %========================================
        % Update the screen: draw, wait, 
        % clear screen
        %========================================
        function update(obj)   
            % Make figure active
%             figure(obj.h);            
             
            tic;
            % Put content on the screen
            drawnow;
            elapsed = toc;
            % Pause to stop crashing and to adjust FPS
            pause(max(0,elapsed-1/obj.targetFPS));
            
            % Clear graphics screen
            cla; 
            % calculate FPS
            obj.h.Name = [obj.title,', FPS: ',num2str(obj.getFPS())];  
        end
        
        %========================================
        % get FPS
        %========================================
        function FPS = getFPS(obj)
           currentTime =  cputime;
           FPS = currentTime - obj.previousTime;
           obj.previousTime = currentTime;
           FPS = 1/FPS;
        end
        
        %========================================
        % Clear all input events
        %========================================
        function clearInputEvents(obj)
           obj.isClicked = 0;
           obj.isMouseDown = 0;
           obj.isKeyDown = zeros(1,256);
           obj.mouseDownX = -1;
           obj.mouseDownY = -1;
        end
        
        %========================================
        % Destroy the window
        %========================================
        function destroyWindow(obj)
            delete(obj.h);
        end
        
    end
    
end

