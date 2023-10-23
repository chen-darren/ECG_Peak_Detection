% Darren's paths
ecg_noise_path = 'C:\Users\dchen\OneDrive - University of Connecticut\Courses\Year 3\Fall 2023\BME 3400 (Chon)\Project\ECG_Peak_Detection';

% Shreya's paths - Darren: please use the same name for the path variables and comment out mine when running
% ecg_noise_path = 

% Load data - Darren: original data file converted to .csv
ecg_noise_filename = 'ECG_with_noise.csv';
ecg_noise = readmatrix(strcat(ecg_noise_path, filesep ,ecg_noise_filename));
% figure; plot(ecg_noise);

% Standardize data - Darren: ECG data is centered with STD ~ 1
mean_ecg_noise = mean(ecg_noise);
centered_ecg_noise = ecg_noise - mean_ecg_noise;
std_dev_centered = std(centered_ecg_noise);
standardized_ecg_noise = centered_ecg_noise / std_dev_centered;
% figure; plot(standardized_ecg_noise);

% Create the low-pass transfer function
num_low_pass = [1 0 0 0 0 -2 0 0 0 0 1];  % [1-z^(-5)]^2 = 1 - 2z^(-5) + z^(-10))
den_low_pass = [1 -2 1];  % [1 - z^(-1)]^2 = 1 - 2z^(-1) + z^(-2) 
H_z_low_pass = tf(num_low_pass, den_low_pass, 1);

% Create the high-pass transfer function
num_high_pass = [-1/32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1/32]; % -1/32 + z^(-16) - z^(-17) + z^(-32)/32
den_high_pass = [1 -1]; % 1 - z^(-1)
H_z_high_pass = tf(num_high_pass, den_high_pass, 1);

% Apply the low-pass and high-pass filters to the ECG data
low_pass_ecg = filter(num_low_pass, den_low_pass, standardized_ecg_noise);
high_pass_ecg = filter(num_high_pass, den_high_pass, standardized_ecg_noise);
bandpass_ecg = filter(num_high_pass, den_high_pass, low_pass_ecg);

% % Plot original input, low-pass, high-pass, and bandpass
% figure;
% subplot(2,1,1);
% plot(standardized_ecg_noise);
% title('Standardized ECG with Noise');
% 
% subplot(2,1,2);
% plot(bandpass_ecg);
% title('Bandpass ECG');
% 
% figure;
% subplot(2,1,1);
% plot(low_pass_ecg);
% title('Low-Pass ECG');
% 
% subplot(2,1,2);
% plot(high_pass_ecg);
% title('High-Pass ECG');

% Create derivative transfer function
num_der = [2 1 0 -1 -2];
den_der = [0.1];
H_z_derivative = tf(num_der, den_der, 1);

% Apply derivative transfer function to bandpass output
derivative_ecg = filter(num_der, den_der, bandpass_ecg);

% Square the derivative output
squared_ecg = derivative_ecg.^2;

% Plot bandpass and derivative
figure;
subplot(2,1,1);
plot(bandpass_ecg);
title('Bandpass ECG');

subplot(2,1,2);
plot(squared_ecg);
title('Squared ECG');


