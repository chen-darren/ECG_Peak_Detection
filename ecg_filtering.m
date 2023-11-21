% Darren's paths
%ecg_noise_path = 'C:\Users\dchen\OneDrive - University of Connecticut\Courses\Year 3\Fall 2023\BME 3400 (Chon)\Project\ECG_Peak_Detection';

% Shreya's paths - Darren: please use the same name for the path variables and comment out mine when running
ecg_noise_path = '/Users/shreyanagri/Downloads/'

% Load data - Darren: original data file converted to .csv
ecg_noise_filename = 'ecgwithnoise';
ecg_noise = readmatrix(strcat(ecg_noise_path,filesep,ecg_noise_filename));
ecg_noise = ecg_noise(:,3); % Get rid of the NaN

% Plot original
figure;
plot(ecg_noise);
title('ECG with Noise');

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
% low_pass_ecg = filter(num_low_pass, den_low_pass, standardized_ecg_noise);
% high_pass_ecg = filter(num_high_pass, den_high_pass, standardized_ecg_noise);
% bandpass_ecg = filter(num_high_pass, den_high_pass, low_pass_ecg); % Overlaps filtering from low pass filter with filtering from high pass filter

% Low-pass filter with difference equation
low_pass_ecg = [ecg_noise(1) 2*ecg_noise(1)+ecg_noise(2)]; % Darren: y(1) = x(1), y(2) = 2y(1)+x(2), T = 1
for n = 3:5 % Darren
    low_pass_ecg(n) = 2*low_pass_ecg(n-1) - low_pass_ecg(n-2) + ecg_noise(n); % Darren: y(n) = 2(n-1) - y(n-2) + x(n)
end;

for n = 6:10
    low_pass_ecg(n) = 2*low_pass_ecg(n-1) - low_pass_ecg(n-2) + ecg_noise(n) - 2*ecg_noise(n-5); % Darren: y(n) = 2(n-1) - y(n-2) + x(n) - 2x(n-5)
end;

for n = 11:size(ecg_noise,1)
    low_pass_ecg(n) = 2*low_pass_ecg(n-1) - low_pass_ecg(n-2) + ecg_noise(n) - 2*ecg_noise(n-5) + ecg_noise(n-10); % Darren: y(n) = 2(n-1) - y(n-2) + x(n) - 2x(n-5) + x(n-10)
end;
low_pass_ecg = low_pass_ecg.'; % Transpose into column vector

% High-pass filter with difference equation
bandpass_ecg = [(-1/32)*low_pass_ecg(1)];

for n = 2:16
    bandpass_ecg(n) = bandpass_ecg(n-1) - (1/32)*low_pass_ecg(n);
end;

bandpass_ecg(17) = bandpass_ecg(17-1) - (1/32)*low_pass_ecg(17) + low_pass_ecg(17-16);

for n = 18:32
    bandpass_ecg(n) = bandpass_ecg(n-1) - (1/32)*low_pass_ecg(n) + low_pass_ecg(n-16) - low_pass_ecg(n-17);
end;

for n = 33:size(low_pass_ecg,1)
    bandpass_ecg(n) = bandpass_ecg(n-1) - (1/32)*low_pass_ecg(n) + low_pass_ecg(n-16) - low_pass_ecg(n-17) + (1/32)*low_pass_ecg(n-32);
end;
bandpass_ecg = bandpass_ecg.';

% Plot original input, low-pass, and bandpass
figure;
subplot(2,1,1);
plot(ecg_noise);
title('ECG with Noise');

subplot(2,1,2);
plot(low_pass_ecg);
title('Low-Pass ECG');

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
title('Bandpass ECG');

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
end;

derivative_ecg(4) = (2*bandpass_ecg(4) + bandpass_ecg(4-1) - bandpass_ecg(4-3))/8; % y(n) = [2x(n) + x(n-1) - x(n-3)]/8

for n = 5:size(bandpass_ecg,1)
    derivative_ecg(n) = (2*bandpass_ecg(n) + bandpass_ecg(n-1) - bandpass_ecg(n-3) - 2*bandpass_ecg(n-4))/8; % y(n) = [2x(n) + x(n-1) - x(n-3) - 2x(n-4)]/8
end;
derivative_ecg = derivative_ecg.';

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

for N = 30:30:size(squared_ecg)
    for n = (N-29):N
        for z = (N-29):N
            i(n) = squared_ecg(z);
        end;
        integrated_ecg(n) = sum(i(n));
    end;
end;
figure; 
plot(integrated_ecg);
title('Integrated ECG');