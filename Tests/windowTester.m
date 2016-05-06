% Window Tester
libraryPath = '..';
addpath(libraryPath);

window = Window(500,500, 'WindowTester');
window.setClearColor(0,0,0);
xloc = 250;
yloc = 250;

b1 = Button(100,100,100,100);
b1.setAllTextColors(0,0,0);
b1.setAllTexts('start!');
blist = ButtonList();
blist.add(b1);
blist.add(Button(300,300,100,100));

while (~window.getIsCloseRequested())

    if (window.getKeyDown('a') == 1)
        xloc = xloc - 5;
    end
    if (window.getKeyDown('d') == 1)
        xloc = xloc + 5;
    end
    if (window.getKeyDown('w') == 1)
        yloc = yloc - 5;
    end
    if (window.getKeyDown('s') == 1)
        yloc = yloc + 5;
    end
    
    scatter(xloc,yloc);   
    plot([0,500],[0,500]);
    
    blist.checkButtons(window.mouseX, window.height - window.mouseY, window.isMouseDown);
    blist.drawAll();
    
    if (b1.isClicked)
        disp('You clicked on button 1!');
    end
    
    text(300,300,'TEST','Color',[1,1,1],'HorizontalAlignment','center','fontsize',50)
    
    window.update();
end

window.destroyWindow();


rmpath(libraryPath);