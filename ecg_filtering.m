clear;
close all;

% Darren's paths
ecg_noise_path = 'C:\Users\dchen\OneDrive - University of Connecticut\Courses\Year 3\Fall 2023\BME 3400 (Chon)\Project\ECG_Peak_Detection';

% Shreya's paths - Darren: please use the same name for the path variables and comment out mine when running
% ecg_noise_path = 

% Load data
ecg_noise_filename = 'ecgwithnoise';
ecg_noise = readmatrix(strcat(ecg_noise_path,filesep,ecg_noise_filename));
ecg_noise = ecg_noise(:,3); % Get rid of the NaN

% % Plot original
% figure;
% plot(ecg_noise);
% title('ECG with Noise');

% % Create the low-pass transfer function
% num_low_pass = [1 0 0 0 0 -2 0 0 0 0 1];  % [1-z^(-5)]^2 = 1 - 2z^(-5) + z^(-10)) - Sets up numerator of transfer function
% den_low_pass = [1 -2 1];  % [1 - z^(-1)]^2 = 1 - 2z^(-1) + z^(-2) - Sets up denominator of transfer function
% H_z_low_pass = tf(num_low_pass, den_low_pass, 1); % Creates transfer function for those frequencies between the boundaries
% 
% % Create the high-pass transfer function
% num_high_pass = [-1/32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1/32]; % -1/32 + z^(-16) - z^(-17) + z^(-32)/32 - Sets up numerator
% den_high_pass = [1 -1]; % 1 - z^(-1) - Sets up denominator
% H_z_high_pass = tf(num_high_pass, den_high_pass, 1); % Creates transfer function for frequencies between boundaries
% 
% % Apply the low-pass and high-pass filters to the ECG data
% low_pass_ecg = filter(num_low_pass, den_low_pass, ecg_noise);
% high_pass_ecg = filter(num_high_pass, den_high_pass, ecg_noise);
% bandpass_ecg = filter(num_high_pass, den_high_pass, low_pass_ecg); % Overlaps filtering from low pass filter with filtering from high pass filter

% Low-pass filter with difference equation (5 sample delay)
low_pass_ecg = [ecg_noise(1) 2*ecg_noise(1)+ecg_noise(2)]; % y(1) = x(1), y(2) = 2y(1)+x(2), T = 1
for n = 3:5 % Darren
    low_pass_ecg(n) = 2*low_pass_ecg(n-1) - low_pass_ecg(n-2) + ecg_noise(n); % y(n) = 2(n-1) - y(n-2) + x(n)
end

for n = 6:10
    low_pass_ecg(n) = 2*low_pass_ecg(n-1) - low_pass_ecg(n-2) + ecg_noise(n) - 2*ecg_noise(n-5); % Darren: y(n) = 2(n-1) - y(n-2) + x(n) - 2x(n-5)
end

for n = 11:length(ecg_noise)
    low_pass_ecg(n) = 2*low_pass_ecg(n-1) - low_pass_ecg(n-2) + ecg_noise(n) - 2*ecg_noise(n-5) + ecg_noise(n-10); % y(n) = 2(n-1) - y(n-2) + x(n) - 2x(n-5) + x(n-10)
end
low_pass_ecg = low_pass_ecg.'; % Transpose into column vector

% High-pass filter with difference equation (16 sample delay)
bandpass_ecg = [(-1/32)*low_pass_ecg(1)];

for n = 2:16
    bandpass_ecg(n) = bandpass_ecg(n-1) - (1/32)*low_pass_ecg(n);
end

bandpass_ecg(17) = bandpass_ecg(17-1) - (1/32)*low_pass_ecg(17) + low_pass_ecg(17-16);

for n = 18:32
    bandpass_ecg(n) = bandpass_ecg(n-1) - (1/32)*low_pass_ecg(n) + low_pass_ecg(n-16) - low_pass_ecg(n-17);
end

for n = 33:length(low_pass_ecg)
    bandpass_ecg(n) = bandpass_ecg(n-1) - (1/32)*low_pass_ecg(n) + low_pass_ecg(n-16) - low_pass_ecg(n-17) + (1/32)*low_pass_ecg(n-32);
end
bandpass_ecg = bandpass_ecg.';

% % Plot original input, low-pass, and bandpass
% figure;
% subplot(2,1,1);
% plot(ecg_noise);
% title('ECG with Noise');
% 
% subplot(2,1,2);
% plot(low_pass_ecg);
% title('Low-Pass ECG');
% 
% figure;
% subplot(2,1,1);
% plot(ecg_noise);
% title('ECG with Noise');
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
% plot(bandpass_ecg);
% title('Bandpass ECG');

% % Create derivative transfer function
% num_der = [2 1 0 -1 -2];
% den_der = [1];
% H_z_derivative = tf(num_der, den_der, 0.125); % Creates transfer function for derivative function
% 
% % Apply derivative transfer function to bandpass output
% derivative_ecg = filter(num_der, den_der, bandpass_ecg); % Applies previously created transfer function

% Derivative difference function
derivative_ecg = [2*bandpass_ecg(1)/8]; % y(1) = 2x(n)/8

for n = 2:3
    derivative_ecg(n) = (2*bandpass_ecg(n) + bandpass_ecg(n-1))/8; % y(n) = [2x(n) + x(n-1)]/8
end

derivative_ecg(4) = (2*bandpass_ecg(4) + bandpass_ecg(4-1) - bandpass_ecg(4-3))/8; % y(n) = [2x(n) + x(n-1) - x(n-3)]/8

for n = 5:length(bandpass_ecg)
    derivative_ecg(n) = (2*bandpass_ecg(n) + bandpass_ecg(n-1) - bandpass_ecg(n-3) - 2*bandpass_ecg(n-4))/8; % y(n) = [2x(n) + x(n-1) - x(n-3) - 2x(n-4)]/8
end
derivative_ecg = derivative_ecg.';

% Square the derivative output
squared_ecg = derivative_ecg.^2;

% % Plot bandpass, derivative, and squared
% figure;
% subplot(2,1,1);
% plot(bandpass_ecg);
% title('Bandpass ECG');
% 
% subplot(2,1,2);
% plot(derivative_ecg);
% title('Derivative ECG');
% 
% figure;
% plot(squared_ecg);
% title('Squared ECG');

% Moving-window integration
for N = 1:30:length(squared_ecg)
    if N + 29 < length(squared_ecg)
        end_value = N + 29;
    else
        end_value = length(squared_ecg);
    end
        window_sum = sum(squared_ecg(N:end_value));  % Calculate the sum for the current window
        integrated_ecg(N:end_value) = window_sum;  % Assign the sum to the corresponding positions
end
integrated_ecg = integrated_ecg.';

% % Plot integrated
% figure; 
% plot(integrated_ecg);
% title('Integrated ECG');

% Mask cutoff_initial
cutoff_initial = 450;

for n = 1:length(integrated_ecg)
    if integrated_ecg(n) >= cutoff_initial
        masked_cutoff_initial_ecg(n) = 1;
    else
        masked_cutoff_initial_ecg(n) = 0;
    end
end
masked_cutoff_initial_ecg = masked_cutoff_initial_ecg.';

% % Plot masked
% figure; 
% plot(masked_cutoff_initial_ecg);
% title('Masked ECG');

% Find the start and end indices of each QRS complex
start_pattern = [0,0,0,1,1]; % Pattern of the start of a QRS complex
end_pattern = [1,0,0,0]; % Pattern of end of QRS complex

start_indices = [];
end_indices = [];
startIndex = 1;

zero_padding = 10; % Padding so that the pattern can start at the "first" index
masked_cutoff_initial_ecg_tran = masked_cutoff_initial_ecg.'; % Makes the ECG a horizotnal vector
masked_cutoff_initial_ecg_tran = [zeros(1,zero_padding) masked_cutoff_initial_ecg_tran, zeros(1,zero_padding)];

while true
    occurrence = strfind(masked_cutoff_initial_ecg_tran(startIndex:end), start_pattern); % Returns index of each instance of the start_pattern
    
    if isempty(occurrence)
        break;  % No more occurrences found
    else
        start_indices = [start_indices, startIndex + occurrence - 1]; % The indices are adjusted to represent their positions in the global vector
        startIndex = startIndex + occurrence(end) + 1; % Updates the startIndex to the position immediately after the last occurrence of start_pattern.
    end
end

startIndex = 1;
while true
    occurrence = strfind(masked_cutoff_initial_ecg_tran(startIndex:end), end_pattern); % Returns index of each instance of the end_pattern
    
    if isempty(occurrence)
        break;  % No more occurrences found
    else
        end_indices = [end_indices, startIndex + occurrence - 1]; % The indices are adjusted to represent their positions in the global vector
        startIndex = startIndex + occurrence(end) + 1; % Updates the startIndex to the position immediately after the last occurrence of start_pattern.
    end
end

start_indices = start_indices - zero_padding; % Counters the zero padding
if start_indices(1) <= 0
    start_indices(1) = 1;
end
end_indices = end_indices - zero_padding; % Counters the zero padding

start_indices = start_indices.';
end_indices = end_indices.';

% Find R peaks in original ECG
for i = 1 % For the first subarray or QRS complex, find the index of the max value
    subarray = ecg_noise(start_indices(i):end_indices(i));
    [~, maxIndex] = max(subarray); % Return the index of the max value
    maxIndices_original(i) = start_indices(i) - 1 + maxIndex; % The indices are adjusted to represent their positions in the global vector
end
for i = 2:length(start_indices) % For each subarray or QRS complex and +/- 30 samples (to increase robustness), find the index of the max value
    subarray = ecg_noise(start_indices(i) - 27:end_indices(i) + 30); %
    [~, maxIndex] = max(subarray); % Return the index of the max value
    maxIndices_original(i) = start_indices(i) - 1 - 27 + maxIndex; % The indices are adjusted to represent their positions in the global vector
end

% Find R peaks in bandpass ECG
for i = 1:length(start_indices) % For the first subarray or QRS complex, find the index of the max value
    subarray = bandpass_ecg(start_indices(i):end_indices(i));
    [~, maxIndex] = max(subarray); % Return the index of the max value
    maxIndices_bandpass(i) = start_indices(i) - 1 + maxIndex; % The indices are adjusted to represent their positions in the global vector
end
for i = 2:length(start_indices)
    subarray = bandpass_ecg(start_indices(i) - 27:end_indices(i) + 30); % For each subarray or QRS complex (rather QRS complex +/- 30 samples)...
    [~, maxIndex] = max(subarray); % Return the index of the max value
    maxIndices_bandpass(i) = start_indices(i) - 1 - 27 + maxIndex; % The indices are adjusted to represent their positions in the global vector
end

% Plot R peaks in original and bandpass ECG
figure;
plot((0:length(ecg_noise)-1)/200, ecg_noise); % Sampling rate = 200 samples/s
hold on;    
plot(maxIndices_original/200, ecg_noise(maxIndices_original), 'r.');
title('Peak Detection on Original ECG');
ylabel('Amplitude');
xlabel('Time (s)');

figure;
plot((0:length(bandpass_ecg)-1)/200, bandpass_ecg); % Sampling rate = 200 samples/s
hold on;
plot(maxIndices_bandpass/200, bandpass_ecg(maxIndices_bandpass), 'r.');
title('Peak Detection on Bandpass ECG');
ylabel('Amplitude');
xlabel('Time (s)');