clear; clc; close all;

a = csvread('a.csv');
b = csvread('b.csv');
x1 = csvread('x.csv');
y1 = csvread('y.csv');

z = [a;b];

dt = 0.05;     % time interval
N = length(z);  % number of samples

F = [1 dt 0 0; 0 1 0 0; 0 0 1 dt; 0 0 0 1];     % CV motion model
Q = [0.2 0 0 0; 0 0.5 0 0; 0 0 0.2 0; 0 0 0 0.5]; % motion noise

H= [1 0 0 0; 0 0 1 0]; % Cartesian observation model
R= [4 0; 0 4];

x = [0 0 0 0]'; % initial state
P= Q;           % initial state covariance

s = zeros(4,N);
% observation noise
% initial state
% initial state covariance

for i = 1 : N
    [xp, Pp] = kalmanPredict(x, P, F, Q);
    [x, P] = kalmanUpdate(xp, Pp, H, R, z(:,i));
    s(:,i) = x; % save current state
end

px = s(1,:); % NOTE: s(2, :) and s(4, :), not considered here,  contain the velocities on x and y respectively
py = s(3,:);

plot(a,b,'xb');
hold;
plot(px,py,'+r');
figure;
plot(x1,y1,'xb');
hold;
plot(px,py,'+r');

mean_error = 0;
error_array = zeros(100);
y_mean_error = 0;

for i = 1:length(a)
    x_error = (x1(i)-px(i))*(x1(i)-px(i));
    y_error = (py(i)-y1(i))*(py(i)-y1(i));
    error_array(i) = sqrt(x_error + y_error);
    y_mean_error = y_mean_error + y_error;
    mean_error = mean_error + x_error + y_error;
end

disp("Mean Error:")
disp(mean_error/100);
std_dev = std2(error_array);
disp("Standard Deviation:")
disp(std_dev);
error_rms = rms(error_array);
error_rms = error_rms(1);
disp('Root Mean Squared Error:');
disp(error_rms);

x = input(" ");
function [xe, Pe] = kalmanUpdate(x, P, H, R, z)
    % Update step of Kalman filter.
    % x: state vector
    % P: covariance matrix of x
    % H: matrix of observation model
    % R: matrix of observation noise
    % z: observation vector
    % Return estimated state vector xe and covariance Pe
    S = H * P * H' + R;
    K = P * H' * inv(S);
    zp = H * x;
    % innovation covariance
    % Kalman gain
    % predicted observation
    %%%%%%%%% UNCOMMENT FOR VALIDATION GATING %%%%%%%%%%
    %gate = (z - zp)' * inv(S) * (z - zp);
    %if gate > 9.21
    %    warning('Observation outside validation gate');
    % xe = x;
    %    Pe = P;
    %    return
    %end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xe = x + K * (z - zp);  % estimated state
    Pe = P - K * S * K';    % estimated covariance
end

function [xp, Pp] = kalmanPredict(x, P, F, Q)
    % Prediction step of Kalman filter.
    % x: state vector
    % P: covariance matrix of x
    % F: matrix of motion model
    % Q: matrix of motion noise
    % Return predicted state vector xp and covariance Pp
    xp = F * x;             % predict state
    Pp = F * P * F' + Q;    % predict state covariance
end