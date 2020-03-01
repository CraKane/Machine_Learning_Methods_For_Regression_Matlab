%% The File For ACO Model 
%  Author: Matsuyama
%  Time: 2020-01-20
%

%% Initialization
clear ; close all; clc

%% =============== Part 1: Train: Read the data ================
fprintf('\nReading the train data from the excel ...\n');
feature = ["KN" "bar" "KN.m" "r.p.m" "mm/r" "mm/min"];

% Create a data variable
A = xlsread('./data/data.xlsx', 'train_data');
X_poly = A(:, 2:7);
X_poly(:,2) = X_poly(:,2).^2; X_poly(:,3) = X_poly(:,3).^1;
X_poly(:,4) = X_poly(:,4).^2; X_poly(:,5) = X_poly(:,5).^1;              %%%%here changed,
X_poly(:,6) = X_poly(:,6).^2;                                            % here is nonlinearization
[X_poly, PSX] = mapminmax(X_poly); X_poly = [X_poly, ones(400, 1)];
Y_poly = A(:, 7);


fprintf('Training the ACO Model ...\n');
alpha = 0.5; % 0~1 -> 0.6
m = 50; 
Q = 1500.0; % 10~10000
rho = 0.7; % 0.1~0.99
max_iter = 20;   % iteration number
% alpha: information  heuristic factor
% m: the number of the ants
% rho: the volatility factor
[theta] = trainAnts(X_poly, Y_poly, alpha, m, rho, Q, max_iter);


%% =============== Part 2: If train, so train the model ================

fprintf('\nTraining the network ...\n');

%% =============== Part 3: Test: Read the data ================
fprintf('\nReading the valid data from the excel ...\n');

% Create a data variable
B = xlsread('./data/data.xlsx', 'valid_data');
Y_valid = B(:, 7);
X_valid = B(:, 2:7);
X_valid_=X_valid;
X_valid(:,2) = X_valid(:,2).^2; X_valid(:,3) = X_valid(:,3).^1;
X_valid(:,4) = X_valid(:,4).^2; X_valid(:,5) = X_valid(:,5).^1;
X_valid(:,6) = X_valid(:,6).^2;
[X_valid, PSXB] = mapminmax(X_valid); X_valid = [X_valid, ones(100, 1)];

% test the ACO model
output = X_valid * theta;
cnter = 0;
for i = 1:100
    if output(i)/Y_valid(i) > 0.95 && output(i)/Y_valid(i) < 1.06
        cnter = cnter + 1;
    end
end

% train_data_correct
output_ = X_poly * theta;
cnter_ = 0;
for i = 1:100
    if output_(i)/Y_poly(i) > 0.95 && output_(i)/Y_poly(i) < 1.06
        cnter_ = cnter_ + 1;
    end
end

%% =============== Part 4: Output the correct rate ================
fprintf('\nPrinting the correct rate ...\n');
fprintf('The train_correct_Rate: %.2f%%\n', cnter_*100/100.0);
fprintf('The valid_correct_Rate: %.2f%%\n', cnter *100/100.0);

%% =============== Part 5: Output the importance of feature ========================
fprintf('\nPrinting the most important feature ...\n');
[value, index] = max(theta(1:end-1));
fprintf('Feature: %s\n', feature(index));
%% =============== Part 6: Plot the regression curve ========================
fprintf('\nPlot the regression curve ...\n');
plotDecisionBoundary(theta(2),X_valid_(:,2), Y_valid);
% pause;