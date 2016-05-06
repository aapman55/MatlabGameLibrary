classdef Button < handle
    %BUTTON
    
    properties
        x;                              % Specifies the top left corner
        y;                              % Specifies the top left corner
        width;                          % Width of the button
        height;                         % height of the button
        gl = GL();                      % Initialise gl
        mouseOver = 0;                  % Boolean to save if the mouse is on the button
        isClicked = 0;                  % If this button has been clicked
        
        normalColor = [1,1,1];          % Default button color
        mouseOverColor = [0,1,0];       % Default mouseOver Color
        selectedColor = [0,0,1];        % Default selected color
        
        mouseOverText = '';             % Default mouse over text
        normalText= '';                 % Default mouse text
        selectedText= '';               % Default mouse selected text
        
        normalTextColor = [0,0,0];      % Default button text color
        mouseOverTextColor = [0,0,0];   % Default mouseOver text Color
        selectedTextColor = [0,0,0];    % Default selected text color
        
        fontSize = 15;                  % Default fontsize of the text on the button
    end
    
    methods
        %==================================
        % Constructor
        %==================================
        function obj = Button(x, y, width, height)
           obj.x = x;
           obj.y = y;
           obj.width = width;
           obj.height = height;
        end
        %==================================
        % Setters
        %==================================
        
        % Colors
        function setNormalColor(obj, r, g, b)
            obj.normalColor = [r,g,b];
        end
        
        function setMouseOverColor(obj, r, g, b)
            obj.mouseOverColor = [r,g,b];
        end
        
        function setSelectedColor(obj, r, g, b)
            obj.selectedColor = [r,g,b];
        end
        
        function setAllColors(obj, r, g, b)
            obj.setNormalColor(r,g,b);
            obj.setMouseOverColor(r,g,b);
            obj.setSelectedColor(r,g,b);
        end
        
        % Text Colors
        function setNormalTextColor(obj, r, g, b)
            obj.normalTextColor = [r,g,b];
        end
        
        function setMouseOverTextColor(obj, r, g, b)
            obj.mouseOverTextColor = [r,g,b];
        end
        
        function setSelectedTextColor(obj, r, g, b)
            obj.selectedTextColor = [r,g,b];
        end
        
        function setAllTextColors(obj, r, g, b)
            obj.setNormalTextColor(r,g,b);
            obj.setMouseOverTextColor(r,g,b);
            obj.setSelectedTextColor(r,g,b);
        end
        
        % Text Strings
        function setNormalText(obj, text)
            obj.normalText = text;
        end
        
        function setMouseOverText(obj, text)
            obj.mouseOverText = text;
        end
        
        function setSelectedText(obj, text)
            obj.selectedText = text;
        end
        
        function setAllTexts(obj, text)
            obj.setNormalText(text);
            obj.setMouseOverText(text);
            obj.setSelectedText(text);
        end
        
        function setFontSize(obj, fontSize)
            obj.fontSize = fontSize;
        end
        
        %==================================
        % Draw the button.
        %==================================
        function draw(obj)
            X = obj.x+obj.width/2;
            Y = obj.y+obj.height/2;
            if obj.mouseOver
                obj.gl.rectangle(obj.x, obj.y, obj.x+obj.width, obj.y+obj.height, obj.mouseOverColor);
                text(X,Y,obj.mouseOverText,'Color',obj.mouseOverTextColor,'HorizontalAlignment','center',...
                    'fontSize',obj.fontSize);
            elseif obj.isClicked
                obj.gl.rectangle(obj.x, obj.y, obj.x+obj.width, obj.y+obj.height, obj.selectedColor);
                text(X,Y,obj.selectedText,'Color',obj.selectedTextColor,'HorizontalAlignment','center',...
                    'fontSize',obj.fontSize);
            else
                obj.gl.rectangle(obj.x, obj.y, obj.x+obj.width, obj.y+obj.height, obj.normalColor);
                text(X,Y,obj.normalText,'Color',obj.normalTextColor,'HorizontalAlignment','center',...
                    'fontSize',obj.fontSize);
            end
        end
        
        %==================================
        % Update the button
        %==================================
        function update(obj, mouseX, mouseY, mouseState)
            obj.mouseOver = obj.isButton(mouseX, mouseY);
            obj.isClicked = (obj.mouseOver & mouseState);
        end
        
        %==================================
        % Checks if a coordinate is inside
        % this button.
        %==================================
        function onButton = isButton(obj, X, Y)
            onButton = (X >= obj.x & X <= obj.x+obj.width & Y >= obj.y & Y <= obj.y+obj.height); 
        end
    end
    
end

