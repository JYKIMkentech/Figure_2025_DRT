%% DRT_fit_run.m
clc; clear; close all;

%% ====== 0) 로드 ======
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\Trips.mat', 'data1');
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\rOCV.mat');  % soc_values/ocv_values or OCV_golden.OCVdis

% SOC-OCV 테이블 정리
if exist('OCV_golden','var') && isfield(OCV_golden,'OCVdis')
    soc_values = double(OCV_golden.OCVdis(:,1));
    ocv_values = double(OCV_golden.OCVdis(:,2));
elseif exist('soc_values','var') && exist('ocv_values','var')
    soc_values = double(soc_values(:));
    ocv_values = double(ocv_values(:));
else
    error('SOC-OCV 데이터(soc_values/ocv_values 또는 OCV_golden.OCVdis)가 필요합니다.');
end

%% ====== 1) 파라미터 ======
trip_to_fit = 1;         % 예) Trip1 (Trip 번호만 변경해서 사용)
n           = 21;        % RC 개수
dur         = 3000;        % tau_max [s]
lambda_hat  = 10;        % 규제강도(요청대로 고정)

%% ====== 2) Trip 데이터 준비 ======
tripName = sprintf('Trip%d', trip_to_fit);
socName  = sprintf('%s_SOC', tripName);

assert(isfield(data1, tripName), '존재하지 않는 Trip: %s', tripName);
M   = data1.(tripName);        % [t I V] 또는 [t I V SOC]
t   = M(:,1);
I   = M(:,2);
Vsd = M(:,3);

% --- SOC 벡터 가져오기 (nx4 or 별도 필드 지원) ---
if size(M,2) >= 4 && any(~isnan(M(:,4)))
    SOC = M(:,4);
elseif isfield(data1, socName) && any(~isnan(data1.(socName)))
    SOC = data1.(socName);
else
    error('이 Trip에는 SOC 데이터가 없습니다. 먼저 build_trips_with_soc.m을 실행해 Trips.mat를 갱신하세요: %s', tripName);
end

% dt 벡터
dt = [0; diff(t)];

%% ====== 3) DRT 추정 수행 ======
% 주의: I가 mA면 R0_est 단위는 V/mA(≈kΩ). A 단위를 원하면 I = I/1000; 로 변환 후 실행.
[gamma_est, R0_est, V_est, theta_discrete, W, y, OCV] = ...
    DRT_estimation_aug(t, I, Vsd, lambda_hat, n, dt, dur, SOC, soc_values, ocv_values);

fprintf('Trip %d: R0_est = %.6g (단위는 입력 전류 단위에 의존)\n', trip_to_fit, R0_est);

%% ====== 4) 결과 플롯 ======
% (a) 전압 피팅 + 전류(같은 Figure)
figure('Color','w');

yyaxis left
hV_meas = plot(t, Vsd, 'LineWidth', 1.2); hold on;
hV_est  = plot(t, V_est, 'LineWidth', 1.2);
ylabel('Voltage [V]');
grid on;

yyaxis right
hI = plot(t, I, 'LineWidth', 1.0);
ylabel('Current [mA]');

xlabel('Time [s]');
% title는 생략
legend([hV_meas, hV_est, hI], {'Measured V','Estimated V','Current'}, 'Location','best');

%xlim([3600 3700]);   % 기존 범위 유지

%% ====== 5) 참고: 잔차(RMSE) 출력
rmse = sqrt(mean((Vsd - V_est).^2));
fprintf('Trip %d: Voltage RMSE = %.6g V\n', trip_to_fit, rmse);

