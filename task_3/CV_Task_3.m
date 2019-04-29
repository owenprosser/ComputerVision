clear; clc; close all;

a = csvread('a.csv');
b = csvread('b.csv');
x1 = csvread('x.csv');
y1 = csvread('y.csv');

z = [a;b];

dt = 0.05;      % time interval
N = length(z);  % number of samples

F = [1 dt 0 0; 0 1 0 0; 0 0 1 dt; 0 0 0 1];       % motion model
Q = [0.2 0 0 0; 0 0.5 0 0; 0 0 0.2 0; 0 0 0 0.5]; % motion noise

H = [1 0 0 0; 0 0 1 0]; % Cartesian observation model
R = [4 0; 0 4];         % R: matrix of observation noise

x = [0 0 0 0]'; % initial state
P = Q;           % initial state covariance

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
title('Predicted: Red - Noisy: Blue')
hold;
plot(px,py,'+r');
figure;
plot(x1,y1,'xb');
title('Predicted: Red - Real: Blue')
hold;
plot(px,py,'+r');

predicted_mean_error = 0;
noisy_mean_error = 0;
predicted_error_array = zeros(1,100);
noisy_error_array = zeros(1,100);

for i = 1:length(a)
    %Predicted
    x_error = (px(i)-x1(i)).*(px(i)-x1(i));
    y_error = (py(i)-y1(i)).*(py(i)-y1(i));
    predicted_error_array(i) = sqrt(x_error + y_error);
    predicted_mean_error = predicted_error_array(i) + predicted_mean_error;
    %Noisy
    x_error = (px(i)-a(i)).*(px(i)-a(i));
    y_error = (py(i)-b(i)).*(py(i)-b(i));
    noisy_error_array(i) = sqrt(x_error + y_error);
    noisy_mean_error = noisy_error_array(i) + noisy_mean_error;
end

disp("Predicted - Mean Error:")
disp(predicted_mean_error/100);
std_dev = std2(predicted_error_array);
disp("Predicted - Standard Deviation:")
disp(std_dev);
predicted_error_rms = rms(predicted_error_array);
predicted_error_rms = predicted_error_rms(1);
disp('Predicted - Root Mean Squared Error:');
disp(predicted_error_rms);

disp("Noisy - Mean Error:")
disp(noisy_mean_error/100);
std_dev = std2(noisy_error_array);
disp("Noisy - Standard Deviation:")
disp(std_dev);
noisy_error_rms = rms(noisy_error_array);
noisy_error_rms = noisy_error_rms(1);
disp('Noisy - Root Mean Squared Error:');
disp(noisy_error_rms);

%x = input(" ");

function [xe, Pe] = kalmanUpdate(x, P, H, R, z)
    % Update step of Kalman filter.
    % x: state vector
    % P: covariance matrix of x
    % H: matrix of observation model
    % R: matrix of observation noise
    % z: observation vector
    % Return estimated state vector xe and covariance Pe
    S = H * P * H' + R;  %innovation covarience ' = transpose
    K = P * H' * inv(S); %kalman gain
    zp = H * x;          %predicted observation
    % innovation covariance
    % Kalman gain
    % predicted observation
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