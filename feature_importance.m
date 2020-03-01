function [theta_] = feature_importance(X_poly, Y_poly)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
lambda = 0.005;
[theta_] = trainLinearReg(X_poly, Y_poly, lambda);
end

