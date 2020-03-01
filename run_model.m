%% The File For Training Model 
%  Author: Matsuyama
%  Time: 2020-01-13
%

%% Initialization
clear ; close all; clc

%% =============== Part 1: Choose the mode: train or test ================
%mm = input('Please choose train or test: [train test]\n', 's');
%if (mm == "train")
%    mo = 1;
%elseif (mm == "test")
%    mo = 2;
%end
%% =============== Part 2: Train: Read the data ================
fprintf('\nReading the train data from the excel ...\n');
feature = ["KN" "bar" "KN.m" "r.p.m" "mm/r" "mm/min"];

% Create a data variable
A = xlsread('./data/data.xlsx', 'train_data');
X_poly = A(:, 2:7);
X_poly(:,2) = X_poly(:,2).^2; X_poly(:,3) = X_poly(:,3).^1;   %%%% Here changed
X_poly(:,4) = X_poly(:,4).^2; X_poly(:,5) = X_poly(:,5).^1;    % here is ?性映射（nonlinearization）
X_poly(:,6) = X_poly(:,6).^2;
[X_poly, PSX] = mapminmax(X_poly); X_poly = [X_poly, ones(400, 1)];
Y_poly = A(:, 7);
% Normalization
[A, PSA] = mapminmax(A);
A_x = A(:, 2:7);
A_y = A(:, 7);
[A_x,valsample.p,testsample.p] =dividerand(A_x,1,0,0);
[A_y,valsample.t,testsample.t] =dividerand(A_y,1,0,0);

% Choose the mode, load the diff network
mode = int16(input('Please Choose the mode: [1, 2, 3]\n'));
if (mode == 1)
    fprintf('Training the 1st Model ...\n');
    model = svr_trainer(X_poly,Y_poly,40,0.001,'gaussian', 0.150);  %%%% Here changed
elseif (mode == 2)
    fprintf('Training the 2nd Model ...\n');
    lambda = 0.0002;           %%%% Here changed， learning rate
    [theta] = trainLinearReg(X_poly, Y_poly, lambda);
elseif (mode == 3)
    fprintf('Training the 3rd Network ...\n');
    setdemorandstream(10.1415);      % initialize the param
    TF1='tansig';TF2='tansig'; TF3='logsig'; TF4='tansig'; TF5='purelin';
    net=newff(A_x', A_y', 200,{TF3 TF2},'traingdm');        %%%% Here changed，1 hidden layer，200 nodes
end


%% =============== Part 3: If train, so train the model ================

fprintf('\nTraining the network ...\n');

%% =============== Part 4: Test: Read the data ================
fprintf('\nReading the valid data from the excel ...\n');

% Create a data variable
B = xlsread('./data/data.xlsx', 'valid_data');
Y_valid = B(:, 7);
X_valid = B(:, 2:7);
X_valid_=X_valid;
X_valid(:,2) = X_valid(:,2).^2; X_valid(:,3) = X_valid(:,3).^1;      %%%% Here changed
X_valid(:,4) = X_valid(:,4).^2; X_valid(:,5) = X_valid(:,5).^1;       % here means ?性映射(nonlinearization)
X_valid(:,6) = X_valid(:,6).^2;
[X_valid, PSXB] = mapminmax(X_valid); X_valid = [X_valid, ones(100, 1)];
    
% Normalization
[B, PSB] = mapminmax(B);
B_x = B(:, 2:7);
B_y = B(:, 7);
if mode == 3
    % fprintf('\nhhhhhh ...\n');
    % Set the training times
    net.trainParam.epochs=100; 

    % Set the goal
    net.trainParam.goal=1e-4;

    % Set the learning rate
    net.trainParam.lr=0.01;

    % Set the dynamic factor ??
    net.trainParam.mc=0.88;

    % Set the show internal
    net.trainParam.show=25;

    net.trainFcn='trainlm';

    [net,tr]=train(net,A_x',A_y');

    % save the model with params
    [normvalid_output,validatePerf]=sim(net,B_x',[],[],B_y');
    [norm_output,Perf]=sim(net,A_x',[],[],A_y');
    output=mapminmax('reverse',norm_output',PSA);
    value=mapminmax('reverse',A_y,PSA);
    valid_output=mapminmax('reverse',normvalid_output',PSB);
    valid_value=mapminmax('reverse',B_y,PSB);
    cnter = 0;
    for i = 1:100
        if valid_output(i)/valid_value(i) > 0.95 && valid_output(i)/valid_value(i) < 1.06
            cnter = cnter + 1;
        end
    end
    
    % train
    cnter_ = 0;
    for i = 1:100
        if output(i)/value(i) > 0.95 && output(i)/value(i) < 1.06
            cnter_ = cnter_ + 1;
        end
    end
elseif mode == 2 
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
        if output_(i)/Y_poly(i) > 0.95 && output_(i)/Y_valid(i) < 1.06
            cnter_ = cnter_ + 1;
        end
    end
else
    output = svr_predict(X_valid, model);
    cnter = 0;
    for i = 1:100
        if output(i)/Y_valid(i) > 0.95 && output(i)/Y_valid(i) < 1.06
            cnter = cnter + 1;
        end
    end
    
    % train_data_correct
    output_ = svr_predict(X_poly, model);
    cnter_ = 0;
    for i = 1:100
        if output_(i)/Y_poly(i) > 0.95 && output(i)/Y_valid(i) < 1.06
            cnter_ = cnter_ + 1;
        end
    end
end


%% =============== Part 5: If test, then load the param & test ================
fprintf('\nPrinting the correct rate ...\n');
fprintf('The train_correct_Rate_: %.2f%%\n', cnter_*100/100.0);    %%%% Here changed
fprintf('The valid_correct_Rate: %.2f%%\n', cnter*100/100.0);
    
%% =============== Part 6: Output the importance of feature ========================
if mode == 1 || mode == 2
    fprintf('\nPrinting the most important feature ...\n');
    theta = feature_importance(X_poly, Y_poly);
    [value, index] = max(theta(1:end-1));
    fprintf('Feature: %s\n', feature(index));
    %% =============== Part 7: Plot the regression curve ========================
    fprintf('\nPlot the regression curve ...\n');
    plotDecisionBoundary(theta(2),X_valid_(:,2), Y_valid);
end


% pause;