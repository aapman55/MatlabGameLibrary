% Lights on and off game
% Turn all lights on
clear classes; close all; clc;

libraryPath = '../..';
addpath(libraryPath);

game = LightsOnOffCore();
try
    game.start();
catch exception
    exception;
    game.window.destroyWindow();
end

rmpath(libraryPath);

