%% Bouncing ball
% Simulation and animation of a bouncing ball.
%
% Reference
% https://www.mathworks.com/help/matlab/math/ode-event-location.html
% Mark W. Reichelt and Lawrence F. Shampine, 1/3/95
%
%%

clear ; close all ; clc

%% Parameters

% Video
tf  = 30;                   % Final time                    [s]
fR  = 30;                   % Frame rate                    [fps]
dt  = 1/fR;                 % Time resolution               [s]
t   = linspace(0,tf,tf*fR); % Time                          [s]

%% Simulation

% VERTICAL DYNAMICS
% Hit the ground event.
options = odeset('Events',@hit_the_ground);

% Initial conditions [height speed]
h0 = 20;            % Initial height    [m]
v0 = 10;            % Initial speed     [m/s]
z0 = [h0 v0];

% Time span for simulation
TSPAN = t;

% Cumulative output initialization
t_ac = [];
h_ac = [];

% One bounce per loop
for i = 1:12
    
    % Integration until hit the ground
    [tout,zout] = ode45(@(t,z) ball_vertical_dynamics(t,z),TSPAN,z0,options);
    
    % Update next iteration
    % Initial conditions [position speed]
    z0 = [0 -.9*zout(end,2)];   
    % Time
    TSPAN = tout(end) + t;
    
    % Acumulate output
    t_ac = [t_ac ; tout];
    h_ac = [h_ac ; zout(:,1)];
    
end

% LONGITUDINAL DYNAMICS
vx  = 1;                % Horizontal speed      [m/s]
x   = vx*t_ac;          % Horizontal position   [m]

%% Animation

c = cool(6); % Colormap

figure
% set(gcf,'Position',[50 50 1280 720])  % YouTube: 720p
% set(gcf,'Position',[50 50 854 480])   % YouTube: 480p
set(gcf,'Position',[50 50 640 640])     % Social

hold on ; grid on ; axis equal
set(gca,'xlim',[0 x(end)],'ylim',[0 1.1*max(h_ac)])
set(gca,'xtick',0:5:x(end),'ytick',0:5:1.1*max(h_ac))
set(gca,'FontName','Verdana','FontSize',18)

% Create and open video writer object
v = VideoWriter('bouncing_ball.mp4','MPEG-4');
v.Quality   = 100;
v.FrameRate = fR;
open(v);

for i=1:length(t_ac)
    
    cla 
    plot(x(1:i) ,h_ac(1:i)  ,'-','Color',c(5,:),'LineWidth',3)
    plot(x(i)   ,h_ac(i)    ,'o','Color',c(5,:),'MarkerFaceColor',cool(1),'MarkerSize',15)
    xlabel('Horizontal distance [m]');
    ylabel('Height [m]');
    title('Bouncing ball');

    % Adding frames
    frame = getframe(gcf);
    writeVideo(v,frame);
    
end

close(v);

%% Auxiliary functions

function dz = ball_vertical_dynamics(~,z)
    % Constant
    g = -9.81;      % Gravity [m/s]
    % Dynamics
    dz(1,1) = z(2);
    dz(2,1) = g;
end

function [value,isterminal,direction] = hit_the_ground(~,y)
    value       = y(1);     % height = 0
    isterminal  = 1;        % stop the integration
    direction   = -1;       % negative direction
end
