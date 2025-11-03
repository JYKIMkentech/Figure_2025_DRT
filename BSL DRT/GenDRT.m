clc;clear;close all;

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
n           = 201;       % RC 개수
dur         = 300;       % tau_max [s]
lambda_hat  = 1;         % 규제강도(요청대로 고정)

tripLabel = sprintf('Trip %d', trip_to_fit);   % ← 추가: 플롯용 라벨

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
    DRT_estimation_aug2(t, I, Vsd, lambda_hat, n, dt, dur, SOC, soc_values, ocv_values);

fprintf('Trip %d: R0_est = %.6g (단위는 입력 전류 단위에 의존)\n', trip_to_fit, R0_est);

%% ====== 4) 결과 플롯 (시간 리셋) ======
% 색상 지정
cV_meas = [0.0, 0.45, 0.76] * 0.7 ;   % 파랑: Measured V
cV_est  = [0.7,  0,    0   ];   % 초록: Estimated V
cI      = [0,    0.7,  0.7 ];   % 빨강: Current

% --- 플롯 전용: 직전 REST END 한 점을 앞에 1개 덧붙여서
% --- 플롯 전용: 직전 Trip의 마지막 샘플 3개를 앞에 덧붙여서
%     "그 3개 지점에서는 V_est == V_meas"가 보이도록 함 (피팅/RMSE에는 영향 X)
numPrevPlotPts = 2;
usePrevPoints = (trip_to_fit >= 1) && isfield(data1, sprintf('Trip%d',trip_to_fit-1));

if usePrevPoints
    prevTripName = sprintf('Trip%d', trip_to_fit-1);
    Mprev = data1.(prevTripName);

    % prev에서 마지막 3개 행 가져오기 (cols: [t I V (SOC optional)])
    last_idx = max(1, size(Mprev,1) - numPrevPlotPts + 1) : size(Mprev,1);
    prevRows = Mprev(last_idx, :);

    t_prev   = prevRows(:,1);
    I_prev   = prevRows(:,2);
    V_prev   = prevRows(:,3);

    % prev SOC 있으면 사용, 없으면 V->SOC 역보간
    if size(prevRows,2) >= 4 && any(~isnan(prevRows(:,4)))
        SOC_prev = prevRows(:,4);
    else
        % V->SOC 역보간: ocv_values(soc) 단조 가정
        SOC_prev = interp1(ocv_values, soc_values, V_prev, 'linear', 'extrap');
    end

    % prev에서의 OCV (참고용) — 플로팅에는 Vest_prev = V_prev 를 직접 사용
    % OCV_prev = interp1(soc_values, ocv_values, SOC_prev, 'linear', 'extrap');

    % === 플로팅용 벡터 구성 (앞에 prev 3개 + 현 Trip 전 구간)
    t_plot    = [t_prev;   t        ];
    I_plot    = [I_prev;   I        ];
    Vsd_plot  = [V_prev;   Vsd      ];
    Vest_plot = [V_prev;   V_est    ];  % 핵심: prev 3개 지점에서 V_est == V_meas

    % 상대시간(붙인 첫 샘플을 0초로)
    t_rel_plot = t_plot - t_plot(1);

else
    % 이전 포인트가 없으면 원래 벡터 그대로 사용
    t_plot    = t;    I_plot   = I;    Vsd_plot = Vsd;   Vest_plot = V_est;
    t_rel_plot = t - t(1);
end

% ------------------ (a) 전체 구간 (상대시간) ------------------
fig1 = figure('Color','w', 'Name', sprintf('%s - Full Duration', tripLabel));  % ← 창 이름에 Trip 표시

yyaxis left
hV_meas = plot(t_rel_plot, Vsd_plot, 'LineWidth', 1.4, 'Color', cV_meas, 'DisplayName','Measured V'); hold on;
hV_est  = plot(t_rel_plot, Vest_plot,'LineWidth', 1.4, 'Color', cV_est,  'DisplayName','Estimated V');
ylabel('Voltage [V]');
grid on;
ax = gca; ax.YColor = [0.15 0.15 0.15]; % 왼쪽 y축(전압)

yyaxis right
hI = plot(t_rel_plot, I_plot, 'LineWidth', 1.2, 'Color', cI, 'DisplayName','Current');
ylabel('Current [mA]');
ax.YColor = cI; % 오른쪽 y축(전류) 색을 전류색으로

xlabel('Time from trip start [s]');
legend([hV_meas, hV_est, hI], {'Measured V','Estimated V','Current'}, 'Location','best');
title(sprintf('%s | Full duration (from trip start)', tripLabel));   % ← 제목에 Trip 표시

% ------------------ (b) 0~100 s 확대 (상대시간) ------------------
fig2 = figure('Color','w', 'Name', sprintf('%s - Zoom 0–100 s', tripLabel));  % ← 창 이름에 Trip 표시

yyaxis left
hV_meas2 = plot(t_rel_plot, Vsd_plot, 'LineWidth', 1.4, 'Color', cV_meas, 'DisplayName','Measured V'); hold on;
hV_est2  = plot(t_rel_plot, Vest_plot,'LineWidth', 1.4, 'Color', cV_est,  'DisplayName','Estimated V');
ylabel('Voltage [V]');
grid on;
ax2 = gca; ax2.YColor = [0.15 0.15 0.15];

yyaxis right
hI2 = plot(t_rel_plot, I_plot, 'LineWidth', 1.2, 'Color', cI, 'DisplayName','Current');
ylabel('Current [mA]');
ax2.YColor = cI;

xlabel('Time from trip start [s]');
zoom_end = min(100, t_rel_plot(end));   % 데이터가 100s 미만이어도 안전
xlim([0 zoom_end]);
legend([hV_meas2, hV_est2, hI2], {'Measured V','Estimated V','Current'}, 'Location','best');
title(sprintf('%s | Zoom: 0–100 s (from trip start)', tripLabel));  % ← 제목에 Trip 표시


%% ====== 5) 참고: 잔차(RMSE) 출력 ======
rmse = sqrt(mean((Vsd - V_est).^2));
fprintf('Trip %d: Voltage RMSE = %.6g V\n', trip_to_fit, rmse);
