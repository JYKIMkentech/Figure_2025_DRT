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

%% ====== 5) 플로팅(맨 마지막) ======
figure('Color','w');

% 좌/우축 지정 및 시계열 플롯
yyaxis left
hV = plot(t, V, 'LineWidth', 1.2); hold on;
ylabel('Voltage [V]');
grid on;

yyaxis right
hI = plot(t, I, 'LineWidth', 1.0); hold on;
ylabel('Current [mA]');

% Rest START / END 마커(동그라미)
hStart = plot(t(start_idx), I(start_idx), 'o', ...
    'MarkerSize', 6, 'LineWidth', 1.2, ...
    'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'none');

hEnd = plot(t(end_idx), I(end_idx), 'o', ...
    'MarkerSize', 6, 'LineWidth', 1.2, ...
    'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none');

% ---- Trip 경계(검은색 수직 점선, **REST END 위치**, 굵게) ----
hb = gobjects(0);
for i = 1:Nend
    hb(end+1) = xline(t(end_idx(i)), 'k:', 'LineWidth', 2.0); 
end

% ---- Trip 라벨: 각 구간 중앙 시점에 'Trip k' ----
yyaxis left
yl = ylim;
y_top = yl(2);
y_pos = y_top - 0.03*(yl(2)-yl(1));   % 상단에서 3% 아래

for k = 1:numel(trip_ranges)
    idx = trip_ranges{k};
    if isempty(idx), continue; end
    t_mid = 0.5*(t(idx(1)) + t(idx(end)));
    text(t_mid, y_pos, sprintf('Trip %d', k-1), ...
        'HorizontalAlignment','center', 'VerticalAlignment','top', ...
        'FontWeight','bold', 'FontSize', 9, 'Clipping','on');
end

% 제목/레이블/범례
xlabel('Time [s]');
title('Voltage & Current vs Time (Rest END-based Trips)');
if ~isempty(hb)
    legend([hI, hV, hStart, hEnd, hb(1)], ...
           {'Current','Voltage','Rest START','Rest END','Trip boundary (END)'}, ...
           'Location','best');
else
    legend([hI, hV, hStart, hEnd], ...
           {'Current','Voltage','Rest START','Rest END'}, ...
           'Location','best');
end
grid on;
