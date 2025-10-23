clc; clear; close all;

%% ====== 0) 경로 ======
file = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\데이터2.xlsx';
assert(exist(file,'file')==2, "파일을 찾을 수 없습니다: %s", file);

load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\rOCV.mat');

%% ====== 1) 엑셀 읽기 (1행 헤더, 2행부터 숫자) ======
% [time/s, Ewe/V, I/mA, Re(Z)/Ohm, -Im(Z)/Ohm]
T = readmatrix(file, 'NumHeaderLines', 1);

% ---- 원천 데이터: 전부 double 배열로만 유지 ----
t      = double(T(:,1));   % [s]
V      = double(T(:,2));   % [V]
I      = double(T(:,3));   % [mA]
ReZ    = double(T(:,4));   
NegImZ = double(T(:,5));   

%% ====== 2) 전류=0 구간(50분 이상 연속) 탐지 -> 결과는 모두 double 배열 ======
I_zero_tol = 1e-3;             % 0 판정 허용오차 [mA]
min_zero_duration_sec = 50*60; % 50분

zero_mask = abs(I) <= I_zero_tol;

d = diff([0; zero_mask; 0]);
start_idx_all = find(d == 1);
end_idx_all   = find(d == -1) - 1;

keep = false(size(start_idx_all));
for k = 1:numel(start_idx_all)
    s = start_idx_all(k); e = end_idx_all(k);
    keep(k) = (t(e) - t(s)) >= min_zero_duration_sec;
end
start_idx = start_idx_all(keep);    % rest START 인덱스(파랑 동그라미)
end_idx   = end_idx_all(keep);      % rest END   인덱스(빨강 동그라미)

fprintf('Zero-runs (>=50min): %d개\n', numel(start_idx));

%% ====== 3) Trip 경계 계산: **REST END 기준** ======
Nend = numel(end_idx);
trip_ranges = {};

if Nend >= 1
    % Trip0: data(1) ~ 첫 번째 rest END (포함)
    s0 = 1;
    e0 = min(end_idx(1), numel(t));
    if s0 <= e0
        trip_ranges{1} = s0:e0;
    else
        trip_ranges{1} = [];
    end

    % Trip1..Trip(Nend-1): 이전 rest END+1 ~ 다음 rest END (포함)
    for i = 1:(Nend-1)
        s = end_idx(i) + 1;
        e = min(end_idx(i+1), numel(t));
        s = max(s, 1);
        if s <= e
            trip_ranges{i+1} = s:e;
        else
            trip_ranges{i+1} = [];
        end
    end

    % 마지막 Trip: 마지막 rest END+1 ~ data(end) (포함)
    sL = max(end_idx(Nend) + 1, 1);
    eL = numel(t);
    if sL <= eL
        trip_ranges{Nend+1} = sL:eL;
    else
        trip_ranges{Nend+1} = [];
    end
else
    % rest END가 없으면 전체를 하나의 Trip(Trip0)
    trip_ranges{1} = 1:numel(t);
end

%% ====== 4) Trips 구조체 생성: 필드명 Trip0..TripN, 값은 nx3 [t I V] ======
Trips = struct();
for k = 1:numel(trip_ranges)
    idx = trip_ranges{k};
    idx = idx(idx>=1 & idx<=numel(t));  % 방어
    Trips.(sprintf('Trip%d', k-1)) = [t(idx), I(idx), V(idx)];  % Trip0부터 시작
end
data1 = Trips;   % data1에는 Trip 정보만 보관

% 로그
fprintf('Trip 개수: %d\n', numel(fieldnames(data1)));
for k = 0:(numel(trip_ranges)-1)
    M = data1.(sprintf('Trip%d',k));
    fprintf('  Trip%d: %d x 3\n', k, size(M,1));
end

%% ====== 4.5) SOC-OCV 테이블에서 Trip SOC 계산 및 부착 (nx4로 갱신) ======
% rOCV.mat에서 SOC-OCV 테이블 확보
if exist('OCV_golden','var') && isfield(OCV_golden,'OCVdis')
    soc_values = double(OCV_golden.OCVdis(:,1));
    ocv_values = double(OCV_golden.OCVdis(:,2));
elseif exist('soc_values','var') && exist('ocv_values','var')
    soc_values = double(soc_values(:));
    ocv_values = double(ocv_values(:));
else
    error('SOC-OCV 데이터(soc_values/ocv_values 또는 OCV_golden.OCVdis)가 필요합니다.');
end

for k = 1:numel(trip_ranges)
    idx = trip_ranges{k};
    if isempty(idx), continue; end

    tTrip = t(idx);  ITrip = I(idx);  VTrip = V(idx);

    % Trip0은 스킵 (SOC 계산하지 않음)
    if k == 1
        data1.(sprintf('Trip%d',k-1)) = [tTrip, ITrip, VTrip, nan(size(tTrip))];
        continue;
    end

    % 이 Trip의 양끝 REST END 인덱스 (왼쪽: soc0, 오른쪽: soc1)
    leftRestIdx  = end_idx(k-1);
    rightHasRest = (k <= Nend);
    if ~rightHasRest
        % 끝 REST가 없으면 SOC 계산 불가
        data1.(sprintf('Trip%d',k-1)) = [tTrip, ITrip, VTrip, nan(size(tTrip))];
        continue;
    end
    rightRestIdx = end_idx(k);

    % OCV->SOC 역보간으로 soc0, soc1
    V0 = V(leftRestIdx);   V1 = V(rightRestIdx);
    soc0 = interp1(ocv_values, soc_values, V0, 'linear', 'extrap');
    soc1 = interp1(ocv_values, soc_values, V1, 'linear', 'extrap');

    % 누적 전하량 Idt (mAh) 및 Trip 총량
    Idt_cum = cumtrapz(tTrip, ITrip) / 3600;   % mA*s -> mAh
    Qtrip   = Idt_cum(end);

    if abs(Qtrip) < eps
        socVec = soc0 * ones(size(tTrip));
    else
        % 진행 비율 r(0->1).  사용자 요청대로 "더하기가 아닌 빼기" 반영:
        % socVec = soc0 - (soc0 - soc1) * r  (== soc0 + (soc1 - soc0) * r)
        r = Idt_cum / Qtrip;        % 부호 상관없이 0~1 진행
        socVec = soc0 - (soc0 - soc1) .* r;
    end

    % nx4: [t, I, V, SOC]
    data1.(sprintf('Trip%d',k-1)) = [tTrip, ITrip, VTrip, socVec];
end



%% ====== 5) 플로팅: (1) Voltage-Current, (2) SOC-Current ======

% --- Trip별 SOC(4번째 열)를 이어붙여 전체 구간 SOC 벡터 구성 ---
SOC_all = nan(size(t));
for k = 1:numel(trip_ranges)
    idx = trip_ranges{k};
    if isempty(idx), continue; end
    Mk = data1.(sprintf('Trip%d',k-1));
    if size(Mk,2) >= 4
        SOC_all(idx) = Mk(:,4);
    end
end

%% (1) Voltage & Current
fig1 = figure('Color','w');
yyaxis left
hV = plot(t, V, 'LineWidth', 1.2); hold on;
ylabel('Voltage [V]');
grid on;

yyaxis right
hI = plot(t, I, 'LineWidth', 1.0); hold on;
ylabel('Current [mA]');

% Rest START / END markers
hStart = plot(t(start_idx), I(start_idx), 'o', ...
    'MarkerSize', 6, 'LineWidth', 1.2, ...
    'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'none');
hEnd = plot(t(end_idx), I(end_idx), 'o', ...
    'MarkerSize', 6, 'LineWidth', 1.2, ...
    'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none');

% Trip boundaries (REST END 위치) - 라벨 텍스트 없음
for i = 1:Nend
    xline(t(end_idx(i)), 'k:', 'LineWidth', 2.0);
end

xlabel('Time [s]');
title('Voltage & Current vs Time');
lg1 = legend([hI, hV, hStart, hEnd], ...
      {'Current','Voltage','Rest START','Rest END'}, 'Location','best');
set(lg1, 'Box','off', 'FontSize',9);

ax1 = gca; ax1.Position = [0.08 0.12 0.86 0.78];  % 여백 축소

%% (2) SOC & Current
fig2 = figure('Color','w');

% SOC는 왼쪽 축(마젠타), Current는 오른쪽 축
yyaxis left
hSOC = plot(t, SOC_all, 'm', 'LineWidth', 1.2); hold on;
ylabel('SOC [-]'); % [%]로 보고 싶으면 100*SOC_all로 바꾸고 라벨을 SOC [%]로 변경
grid on;

yyaxis right
hI2 = plot(t, I, 'LineWidth', 1.0); hold on;
ylabel('Current [mA]');

% 동일한 마커/경계선 오버레이
plot(t(start_idx), I(start_idx), 'o', ...
    'MarkerSize', 6, 'LineWidth', 1.2, ...
    'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'none');
plot(t(end_idx), I(end_idx), 'o', ...
    'MarkerSize', 6, 'LineWidth', 1.2, ...
    'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none');

for i = 1:Nend
    xline(t(end_idx(i)), 'k:', 'LineWidth', 2.0);
end

xlabel('Time [s]');
title('SOC & Current vs Time');
lg2 = legend([hI2, hSOC], {'Current','SOC'}, 'Location','best');
set(lg2, 'Box','off', 'FontSize',9);

ax2 = gca; ax2.Position = [0.08 0.12 0.86 0.78];  % 여백 축소


%% ====== 6) Trips 구조체 저장 (.mat) ======
outfile = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\Trips.mat';
save(outfile, 'data1', '-v7.3');



