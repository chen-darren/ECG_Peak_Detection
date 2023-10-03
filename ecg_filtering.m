% Darren's paths
ecg_noise_path = 'C:\Users\dchen\OneDrive - University of Connecticut\Courses\Year 3\BME 3400 (Chon)\Project\ECG_Peak_Detection';

% Shreya's paths - Darren: please use the same name for the path variables and comment out mine when running
% ecg_noise_path = 

% Load data - Darren: original data file converted to .csv
ecg_noise_filename = 'ECG_with_noise.csv';
ecg_noise = readmatrix(strcat(ecg_noise_path, filesep ,ecg_noise_filename));
% figure; plot(ecg_noise);

% Normalize data - Darren: ECG data is centered with STD ~ 1
mean_ecg_noise = mean(ecg_noise);
centered_ecg_noise = ecg_noise - mean_ecg_noise;
std_dev_centered = std(centered_ecg_noise);
normalized_ecg_noise = centered_ecg_noise / std_dev_centered;
% figure; plot(normalized_ecg_noise);