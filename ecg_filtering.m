% Darren's paths
ecg_noise_path = 'C:\Users\dchen\OneDrive - University of Connecticut\Courses\Year 3\Fall 2023\BME 3400 (Chon)\Project\ECG_Peak_Detection';

% Shreya's paths - Darren: please use the same name for the path variables and comment out mine when running
% ecg_noise_path = 

% Load data - Darren: original data file converted to .csv
ecg_noise_filename = 'ECG_with_noise.csv';
ecg_noise = readmatrix(strcat(ecg_noise_path, filesep ,ecg_noise_filename));

% Plot original
figure;
plot(ecg_noise);
title('ECG with Noise');

% % Create the low-pass transfer function
% num_low_pass = [1 0 0 0 0 -2 0 0 0 0 1];  % [1-z^(-5)]^2 = 1 - 2z^(-5) + z^(-10))
% den_low_pass = [1 -2 1];  % [1 - z^(-1)]^2 = 1 - 2z^(-1) + z^(-2) 
% H_z_low_pass = tf(num_low_pass, den_low_pass, 1);
% 
% % Create the high-pass transfer function
% num_high_pass = [-1/32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1/32]; % -1/32 + z^(-16) - z^(-17) + z^(-32)/32
% den_high_pass = [1 -1]; % 1 - z^(-1)
% H_z_high_pass = tf(num_high_pass, den_high_pass, 1);
% 
% % Apply the low-pass and high-pass filters to the ECG data
% low_pass_ecg = filter(num_low_pass, den_low_pass, ecg_noise);
% high_pass_ecg = filter(num_high_pass, den_high_pass, ecg_noise);
% bandpass_ecg = filter(num_high_pass, den_high_pass, low_pass_ecg);

% Low-pass filter with difference equation
low_pass_ecg = [ecg_noise(1) 2*ecg_noise(1)+ecg_noise(2)]; % Darren: y(1) = x(1), y(2) = 2y(1)+x(2), T = 1
for n = 3:5 % Darren
    y = 2*low_pass_ecg(n-1) - low_pass_ecg(n-2) + ecg_noise(n); % Darren: y(n) = 2(n-1) - y(n-2) + x(n)
    low_pass_ecg = [low_pass_ecg y];
end
for n = 6:10
    y = 2*low_pass_ecg(n-1) - low_pass_ecg(n-2) + ecg_noise(n) - 2*ecg_noise(n-5); % Darren: y(n) = 2(n-1) - y(n-2) + x(n) - 2x(n-5)
    low_pass_ecg = [low_pass_ecg y];
end
for n = 11:size(ecg_noise,1)
    y = 2*low_pass_ecg(n-1) - low_pass_ecg(n-2) + ecg_noise(n) - 2*ecg_noise(n-5) + ecg_noise(n-10); % Darren: y(n) = 2(n-1) - y(n-2) + x(n) - 2x(n-5) + x(n-10)
    low_pass_ecg = [low_pass_ecg y];
end
low_pass_ecg = low_pass_ecg.'; % Transpose into column vector

% High-pass filter with difference equation
bandpass_ecg = [(-1/32)*low_pass_ecg(1)];
for n = 2:16
    y = bandpass_ecg(n-1) - (1/32)*low_pass_ecg(n);
    bandpass_ecg = [bandpass_ecg y];
end
y = bandpass_ecg(17-1) - (1/32)*low_pass_ecg(17) + low_pass_ecg(17-16);
bandpass_ecg = [bandpass_ecg y];
for n = 18:32
    y = bandpass_ecg(n-1) - (1/32)*low_pass_ecg(n) + low_pass_ecg(n-16) - low_pass_ecg(n-17);
    bandpass_ecg = [bandpass_ecg y];
end
for n = 33:size(low_pass_ecg,1)
    y = bandpass_ecg(n-1) - (1/32)*low_pass_ecg(n) + low_pass_ecg(n-16) - low_pass_ecg(n-17) + (1/32)*low_pass_ecg(n-32);
    bandpass_ecg = [bandpass_ecg y]; 
end
bandpass_ecg = bandpass_ecg.';

% Plot original input, low-pass, and bandpass
figure;
subplot(2,1,1);
plot(ecg_noise);
title('ECG with Noise');

subplot(2,1,2);
plot(bandpass_ecg);
title('Bandpass ECG');

figure;
subplot(2,1,1);
plot(low_pass_ecg);
title('Low-Pass ECG');

subplot(2,1,2);
plot(bandpass_ecg);
title('Bandpass ECG')

% Create derivative transfer function
num_der = [2 1 0 -1 -2];
den_der = [0.1];
H_z_derivative = tf(num_der, den_der, 1);

% Apply derivative transfer function to bandpass output
derivative_ecg = filter(num_der, den_der, bandpass_ecg);

% Square the derivative output
squared_ecg = derivative_ecg.^2;

% Plot bandpass, derivative, and squared
figure;
subplot(2,1,1);
plot(bandpass_ecg);
title('Bandpass ECG');

subplot(2,1,2);
plot(derivative_ecg);
title('Derivative ECG');

figure;
plot(squared_ecg);
title('Squared ECG');


