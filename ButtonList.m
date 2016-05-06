classdef ButtonList < handle
    %ButtonList List with Button objects
    
    properties
        list;               % List with buttons
    end
    
    methods
        %=====================================
        % Constructor
        %=====================================
        
        function obj = ButtonList()
            obj.list= [];
        end
        
        function add(obj, button)
            if (isa(button,'Button'))
                obj.list = [obj.list, button];
            else
                error('Not a valid button!');
            end
        end
        
        function pressedIndex = checkButtons(obj, mouseX, mouseY, isMouseDown)
            pressedIndex = 0;
            for i = 1:length(obj.list)
                obj.list(i).update(mouseX, mouseY, isMouseDown);
                if (obj.list(i).isClicked)
                    pressedIndex = i;
                end
            end
        end
        
        function drawAll(obj)
            for i=1:length(obj.list)
                obj.list(i).draw();
            end
        end
        
        function clear(obj)
            obj.list = [];
        end
    end
    
end

