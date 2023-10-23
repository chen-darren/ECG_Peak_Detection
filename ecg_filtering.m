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

% Create the transfer function
num_low_pass = [1 0 0 0 0 -2 0 0 0 0 1];  % [1-z^(-5)]^2 = 1 - 2z^(-5) + z^(-10))
den_low_pass = [1 -2 1];  % [1 - z^(-1)]^2 = 1 - 2z^(-1) + z^(-2) 
H_z = tf(num_low_pass, den_low_pass, 1)

% Apply the transfer function H_z to the data using the filter function
% output_data = filter(H_z.Numerator{1}, H_z.Denominator{1}, standardized_ecg_noise);
low_pass_ecg = filter(num_low_pass, den_low_pass, standardized_ecg_noise);

% Plot the input and filtered output data
figure;
subplot(2,1,1);
plot(standardized_ecg_noise);
title('Standardized ECG with Noise');

subplot(2,1,2);
plot(low_pass_ecg);
title('Low Pass ECG');